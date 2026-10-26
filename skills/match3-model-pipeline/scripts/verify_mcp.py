"""Verify actual MCP stdio -> Blender socket -> bpy -> GLB import roundtrip.

Run with the Python environment used by the installed mcp-for-blender package.
"""
import argparse
import asyncio
import json
import os
from datetime import timedelta
from pathlib import Path

from mcp import ClientSession, StdioServerParameters
from mcp.client.stdio import stdio_client

parser = argparse.ArgumentParser()
parser.add_argument('--server', required=True)
parser.add_argument('--candidate', type=Path, required=True)
args = parser.parse_args()


def plain(result):
    return result.model_dump(mode='json', exclude_none=True)


async def main():
    candidate = args.candidate.resolve()
    params = StdioServerParameters(command=args.server,
        args=['--host', '127.0.0.1', '--port', '9876'],
        env={**os.environ, 'BLENDER_MCP_DISABLE_TELEMETRY': '1'})
    async with stdio_client(params) as (read, write):
        async with ClientSession(read, write, read_timeout_seconds=timedelta(seconds=120)) as client:
            initialized = await client.initialize()
            tools = await client.list_tools()
            names = [tool.name for tool in tools.tools]
            assert 'get_scene_info' in names and 'execute_blender_code' in names
            # Only use files produced by this task. Startup Blender instance is dedicated to this pipeline.
            code = f'''import bpy, json
from mathutils import Vector
bpy.ops.object.select_all(action='SELECT')
bpy.ops.object.delete(use_global=False)
bpy.ops.import_scene.gltf(filepath={str(candidate / 'models/phone.glb')!r})
o = next(o for o in bpy.context.scene.objects if o.type == 'MESH')
o.name = 'mcp_verified_phone'
pts = [o.matrix_world @ v.co for v in o.data.vertices]
size = [max(p[i] for p in pts)-min(p[i] for p in pts) for i in range(3)]
assert abs(max(size)-1) < 0.0001
bpy.ops.wm.save_as_mainfile(filepath={str(candidate / 'source/mcp-verified-phone.blend')!r})
print(json.dumps({{'marker':'MCP_GLB_ROUNDTRIP_PASS','object':o.name,'dimensions':size,'version':bpy.app.version_string}}))
'''
            execution = await client.call_tool('execute_blender_code', {'code': code,
                'user_prompt': '安装一下blender已经相关mcp功能，并参考项目已有模型规格，整理三消物品模型生成规范和管线skill，并完成首批电子产品生成验证'})
            assert not execution.isError, execution
            assert 'MCP_GLB_ROUNDTRIP_PASS' in json.dumps(plain(execution)), execution
            scene = await client.call_tool('get_scene_info', {})
            assert not scene.isError, scene
            assert 'mcp_verified_phone' in json.dumps(plain(scene)), scene
            report = dict(status='passed', initialize=plain(initialized), toolCount=len(names),
                verifiedTools=['get_scene_info', 'execute_blender_code'],
                execution=plain(execution), sceneInfo=plain(scene))
            (candidate / 'qa/mcp-verification.json').write_text(json.dumps(report, indent=2), encoding='utf-8')
            print(json.dumps({'status': 'PASS', 'toolCount': len(names), 'GLBRoundtrip': True}))


if __name__ == '__main__':
    asyncio.run(main())
