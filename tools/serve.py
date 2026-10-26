from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
import functools
import argparse
from pathlib import Path

class NoCache(SimpleHTTPRequestHandler):
    """开发服务器：禁用一切缓存。
    Cocos 的产物路径固定（assets/main/index.js），浏览器缓存住旧包之后，
    页面跑的是旧代码而服务端是新的——排查时极易误判成「构建没生效」。"""
    def end_headers(self):
        self.send_header('Cache-Control', 'no-store, no-cache, must-revalidate')
        self.send_header('Pragma', 'no-cache')
        self.send_header('Expires', '0')
        super().end_headers()

parser = argparse.ArgumentParser()
parser.add_argument('--port', type=int, default=5185)
args = parser.parse_args()
directory = Path(__file__).resolve().parent.parent / 'reference-projects/catch-big-goose-cocos' / 'build' / 'web-mobile'
if not (directory / 'index.html').is_file() or not (directory / 'jolt-glue.js').is_file():
    raise SystemExit('Missing reference build. Run npm run build first.')
H = functools.partial(NoCache, directory=str(directory))
# 开发预览只允许本机访问，避免把未发布的游戏代码和资源暴露到局域网。
print(f'Serving {directory} at http://127.0.0.1:{args.port}/', flush=True)
ThreadingHTTPServer(('127.0.0.1', args.port), H).serve_forever()
