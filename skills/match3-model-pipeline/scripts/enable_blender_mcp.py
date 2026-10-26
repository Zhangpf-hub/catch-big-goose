"""Run with Blender --python to enable the installed local MCP addon persistently."""
import addon_utils
import bpy

addon_utils.enable('blender_mcp', default_set=True, persistent=True)
import blender_mcp

bpy.context.preferences.addons['blender_mcp'].preferences.telemetry_consent = False
bpy.context.scene.blendermcp_port = 9876
bpy.context.scene.blendermcp_auto_start_server = True
bpy.ops.wm.save_userpref()
if not bpy.app.background:
    blender_mcp._blendermcp_ensure_server_running()
print('BLENDER_MCP_READY', bpy.app.version_string, flush=True)
