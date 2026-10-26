"""Read process working directories and open files below the old project only."""
from pathlib import Path
import json
import sys
ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'work/structure-migration/python-deps'))
import psutil
target = ROOT / 'projects/catch-big-goose-unity'
results = []
for process in psutil.process_iter():
    try:
        paths = [process.cwd()] + [f.path for f in process.open_files()]
        found = sorted({p for p in paths if p and Path(p).is_relative_to(target)})
        if found:
            results.append(dict(pid=process.pid, name=process.name(), parent=process.ppid(), paths=found[:8]))
    except (psutil.Error, OSError):
        pass
print(json.dumps(results, ensure_ascii=False, indent=2))
