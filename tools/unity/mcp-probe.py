"""Exercise the installed MCP protocol and an actual editor tool; fail if Unity is disconnected."""
import asyncio
import json
import sys
from pathlib import Path
from mcp import ClientSession
from mcp.client.streamable_http import streamablehttp_client

ROOT = Path(__file__).resolve().parents[2]


async def main():
    report = {}
    async with streamablehttp_client('http://127.0.0.1:8088/mcp') as (read, write, _):
        async with ClientSession(read, write) as client:
            init = await client.initialize()
            report['server'] = init.serverInfo.model_dump()
            listing = await client.list_tools()
            report['tools'] = [t.name for t in listing.tools]
            resources = await client.list_resources()
            report['resources'] = [str(r.uri) for r in resources.resources]
            instance = await client.read_resource('mcpforunity://instances')
            report['instances'] = instance.model_dump(mode='json')
            instances = json.loads(instance.contents[0].text)
            if not instances.get('success') or instances.get('instance_count', 0) < 1:
                raise RuntimeError('No live Unity editor instance is connected')
            for uri in ('mcpforunity://project/info', 'mcpforunity://editor/state'):
                report[uri] = (await client.read_resource(uri)).model_dump(mode='json')
            scene = await client.call_tool('manage_scene', {'action': 'get_active'})
            report['activeScene'] = scene.model_dump(mode='json')
            if (scene.structuredContent or {}).get('data', {}).get('path') != 'Assets/Scenes/Main.unity':
                raise RuntimeError('The connected editor is not showing our Main scene')
            if '--play-check' in sys.argv:
                state = json.loads(report['mcpforunity://editor/state']['contents'][0]['text'])
                if state.get('data', {}).get('editor', {}).get('play_mode', {}).get('is_playing'):
                    raise RuntimeError('Editor is already playing; preserve its current state')
                report['playCheck'] = {}
                try:
                    for name, tool, args in [('play', 'manage_editor', {'action': 'play'}),
                        ('hierarchy', 'manage_scene', {'action': 'get_hierarchy', 'max_nodes': 15, 'max_depth': 2})]:
                        result = await client.call_tool(tool, args)
                        report['playCheck'][name] = result.model_dump(mode='json')
                        if result.isError or (result.structuredContent or {}).get('success') is not True:
                            raise RuntimeError('Editor play check failed: ' + name)
                finally:
                    stopped = await client.call_tool('manage_editor', {'action': 'stop'})
                    report['playCheck']['stop'] = stopped.model_dump(mode='json')
                    if stopped.isError or (stopped.structuredContent or {}).get('success') is not True:
                        raise RuntimeError('Editor did not confirm leaving play mode')
            console = await client.call_tool('read_console', {'action': 'get', 'count': '5', 'types': ['error', 'warning', 'log']})
            report['console'] = console.model_dump(mode='json')
            if console.isError or (console.structuredContent or {}).get('success') is False:
                raise RuntimeError('Unity tool call failed: ' + str(console.content))
    path = ROOT / 'work/unity-migration/mcp-verification.json'
    path.write_text(json.dumps(report, ensure_ascii=False, indent=2), encoding='utf-8')
    print(json.dumps(report, ensure_ascii=False, indent=2))


if __name__ == '__main__':
    asyncio.run(main())
