"""Small client for the project's local Unity MCP endpoint."""
import asyncio, json, sys
from mcp import ClientSession
from mcp.client.streamable_http import streamablehttp_client

async def main():
    async with streamablehttp_client('http://127.0.0.1:8088/mcp') as (read, write, _):
        async with ClientSession(read, write) as client:
            await client.initialize()
            if sys.argv[1] == 'schema':
                listing = await client.list_tools()
                result = [t.model_dump(mode='json') for t in listing.tools if t.name in sys.argv[2:]]
            elif sys.argv[1] == 'resource':
                result = (await client.read_resource(sys.argv[2])).model_dump(mode='json')
            else:
                result = (await client.call_tool(sys.argv[1], json.loads(sys.argv[2]))).model_dump(mode='json')
            print(json.dumps(result, ensure_ascii=False, indent=2))

asyncio.run(main())
