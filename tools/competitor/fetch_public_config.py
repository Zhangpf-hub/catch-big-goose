"""Read only the two public URLs assembled by the frozen 402 client."""
import datetime
import hashlib
import json
import urllib.request
from pathlib import Path

root = Path(__file__).resolve().parents[2] / 'competitor-analysis/artifacts/competitor-runtime-trace/public-config'
root.mkdir(parents=True, exist_ok=True)
base = 'https://cdn-zhuadae.lanfeitech.com/GMVersion/prod/26102019/'
results = []
for name in ['ABTestData.config', 'HotFixLevelHard.txt']:
    entry = dict(url=base+name, fetchedAtUtc=datetime.datetime.now(datetime.timezone.utc).isoformat(),
                 scope='Current public CDN response, not proof of this account or historical runtime values')
    try:
        with urllib.request.urlopen(base+name, timeout=25) as response:
            body = response.read(4*1024*1024)
            (root/name).write_bytes(body)
            entry.update(status=response.status, bytes=len(body), sha256=hashlib.sha256(body).hexdigest(),
                         headers={k:v for k,v in response.headers.items() if k.lower() in ['date','last-modified','etag','content-type']})
    except Exception as error:
        entry.update(error=type(error).__name__ + ': ' + str(error))
    results.append(entry)
(root/'fetch-report.json').write_text(json.dumps(results, ensure_ascii=False, indent=2), 'utf-8')
print(json.dumps(results, ensure_ascii=True))
