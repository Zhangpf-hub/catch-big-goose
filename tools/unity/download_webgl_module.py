"""Download the official matching WebGL module in verified HTTP byte ranges."""
from concurrent.futures import ThreadPoolExecutor, as_completed
import hashlib, json, time, urllib.request
from pathlib import Path

URL = 'https://download.unity3d.com/download_unity/96770f904ca7/TargetSupportInstaller/UnitySetup-WebGL-Support-for-Editor-2022.3.62f3.exe'
SIZE = 587746032
TARGET = Path('D:/开发/tools/unity/installers/UnitySetup-WebGL-Support-for-Editor-2022.3.62f3.exe')
CHUNK = 4 * 1024 * 1024

def fetch(index):
    start, end = index * CHUNK, min(SIZE, (index + 1) * CHUNK) - 1
    part = TARGET.with_suffix('.range' + str(index))
    if part.exists() and part.stat().st_size == end - start + 1:
        return part
    for attempt in range(6):
        try:
            opener = urllib.request.build_opener(urllib.request.ProxyHandler({}))
            request = urllib.request.Request(URL, headers={'Range': f'bytes={start}-{end}', 'User-Agent': 'UnityModuleDownload/1.0'})
            with opener.open(request, timeout=90) as response:
                if response.status != 206 or response.headers.get('Content-Range') != f'bytes {start}-{end}/{SIZE}':
                    raise RuntimeError('Unexpected HTTP range response')
                data = response.read()
            if len(data) != end - start + 1: raise RuntimeError('Incomplete range')
            part.write_bytes(data)
            return part
        except Exception:
            if attempt == 5: raise
            time.sleep(min(5, attempt + 1))

def main():
    count = (SIZE + CHUNK - 1) // CHUNK
    with ThreadPoolExecutor(max_workers=32) as pool:
        for done, task in enumerate(as_completed([pool.submit(fetch, i) for i in range(count)]), 1):
            task.result()
            if done % 5 == 0 or done == count: print(f'WebGL ranges {done}/{count}', flush=True)
    digest = hashlib.sha256()
    with TARGET.open('wb') as output:
        for i in range(count):
            data = TARGET.with_suffix('.range' + str(i)).read_bytes()
            output.write(data); digest.update(data)
    assert TARGET.stat().st_size == SIZE
    report = dict(source=URL, size=SIZE, sha256=digest.hexdigest())
    (Path(__file__).resolve().parents[2] / 'work/wechat-integration/webgl-download.json').write_text(json.dumps(report, indent=2))
    print('WebGL module downloaded: ' + digest.hexdigest(), flush=True)

if __name__ == '__main__': main()
