"""Save the simulator evidence addendum without replacing the R4 source freeze."""
from pathlib import Path
from datetime import datetime
import hashlib
import json
import shutil
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[2]
WORK = ROOT / 'work/r4-interaction-20261025'
SIM = WORK / 'wechat/simulator-touch'
OUT = WORK / 'delivery/simulator-addendum'
OUT.mkdir(parents=True, exist_ok=True)
now = datetime.now().astimezone().isoformat()

def read(path):
    return json.loads(path.read_text(encoding='utf-8-sig'))

def save(path, data):
    path.write_text(json.dumps(data, ensure_ascii=False, indent=2), encoding='utf-8')

def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

touch = read(SIM / 'touch-acceptance.json')
assert touch['touchSuitePassed'] and touch['persistenceRestartVerified']
assert not touch['sensorAcceptancePassed'] and not touch['overallPassed']
filename = 'a66948f0142406aa.webgl.wasm.code.unityweb.wasm.br'
current = ROOT / 'builds/catch-big-goose-wechat/wasmcode' / filename
frozen = WORK / 'release-wechat-floor/wasmcode' / filename
assert sha(current) == sha(frozen) == '9086f6ab4a8612d38d0240cbf150648888c5165769640465508d19bb78d7e5d3'
build_match = dict(timestamp=now, current=str(current.relative_to(ROOT)), frozen=str(frozen.relative_to(ROOT)), sha256=sha(current), matches=True, scope='Exact WASM code identity; no new runtime build in this acceptance addendum.')
save(SIM / 'build-match.json', build_match)

simulator = read(WORK / 'wechat/simulator-r4.json')
simulator.update(timestamp=now, firewallResolved=True, touchWalkthroughPassed=True,
                 currentFloorExportTouchPassed=True, physicalPhonePassed=False,
                 sensorAcceptancePassed=False, overallPassed=False,
                 persistenceRestartVerified=True, blocker=touch['sensorBlocker'],
                 scope=touch['coverage'], touchReport='wechat/simulator-touch/touch-acceptance.json')
simulator['observed'] += [x for x in [
    'User dismissed firewall permission prompt; actual touch walkthrough resumed',
    'Five tutorial themes and breakfast challenge manually operated',
    'Triple animation accepted the next world pick; tutorial cleared 15/15',
    'Props, free shake button, pause/resume and process-restart persistence passed',
    'Actual wx.startAccelerometer rejected by account privacy declaration; sensor acceptance failed'
] if x not in simulator['observed']]
save(WORK / 'wechat/simulator-r4.json', simulator)

audit = read(WORK / 'requirement-audit.json')
for entry in audit['requirements']:
    key = entry['id']
    if key in ('theme-scenes', 'concurrent-triples', 'opening', 'builds-and-preview', 'delivery-evidence'):
        entry.setdefault('evidence', [])
        evidence = 'work/r4-interaction-20261025/wechat/simulator-touch/touch-acceptance.json'
        if evidence not in entry['evidence']:
            entry['evidence'].append(evidence)
        entry['simulator'] = 'Five tutorial themes plus breakfast challenge actual touch walkthrough passed; scope is not all five challenge completions.'
    if key == 'concurrent-triples':
        entry['state'] = 'native-and-simulator-verified-phone-pending'
        entry['remaining'] = 'Actual simulator double-click completed triple and picked underlying item; phone touch chain pending.'
    elif key == 'shake':
        entry['state'] = 'sensor-blocked-by-wechat-account-privacy-declaration'
        entry['remaining'] = 'Button physical shake passed in tutorial and challenge; wx.startAccelerometer rejected with: ' + touch['sensorBlocker'] + '. Account declaration and actual phone shake acceptance required.'
        entry['evidence'].append('work/r4-interaction-20261025/wechat/simulator-touch/runtime-console.txt') if 'work/r4-interaction-20261025/wechat/simulator-touch/runtime-console.txt' not in entry['evidence'] else None
    elif key == 'builds-and-preview':
        entry['remaining'] = 'Exact frozen WASM identity confirmed; simulator touch passed; sensor and phone acceptance pending.'
audit.update(updatedAt=now, simulatorTouchAcceptance='passed', simulatorSensorAcceptance='failed-account-privacy-declaration', deviceAcceptance='pending', complete=False)
save(WORK / 'requirement-audit.json', audit)

subprocess.run([sys.executable, str(ROOT / 'tools/unity/report_r4_delivery.py')], check=True, stdout=subprocess.DEVNULL)
summary = read(WORK / 'delivery-summary.json')
status = read(WORK / 'delivery/status.json')
status.pop('goalState', None)
status.update(updatedAt=now, simulator=summary['simulator'], remaining=summary['outstanding'],
              complete=False, physicalPhoneVerified=False, acceptanceState='sensor-declaration-blocked-phone-pending')
save(WORK / 'delivery/status.json', status)

previous = read(WORK / 'blocked-audit.json')
history = WORK / 'delivery/firewall-blocked-audit-historical.json'
if not history.exists():
    save(history, previous)
save(WORK / 'blocked-audit.json', dict(timestamp=now, goal='完成计划内容', complete=False,
     previousAudit='delivery/firewall-blocked-audit-historical.json', userResumed=True,
     firewallResolved=True, currentTurn='Meaningful progress: actual simulator touch suite and restart persistence completed; new account privacy declaration error diagnosed.',
     sameBlockerConsecutiveGoalTurns=1,
     blockers=['Actual wx.startAccelerometer rejected by account privacy declaration', 'Physical phone shake, cold startup and sustained performance/memory not yet measured'],
     nextRequired=['Account administrator declares accelerometer use in WeChat privacy guide and completes platform effective/review flow', 'Retest sensor API and actual phone shake using unchanged final R4 preview'],
     note='Fresh blocker audit after user resume; no new blocked goal tool update was requested in this turn.'))

for rel in ['requirement-audit.json', 'delivery-summary.json']:
    shutil.copy2(WORK / rel, WORK / 'delivery/reports' / rel)

selected = [SIM / name for name in ['README.md', 'touch-acceptance.json', 'runtime-console.txt', 'official-sources.json', 'build-match.json']]
selected += sorted(SIM.glob('*.jpg')) + sorted(SIM.glob('*.png'))
selected += [ROOT / rel for rel in ['docs/development-reports/27-R4微信模拟器触控与传感器验收.md', 'tools/unity/report_r4_delivery.py', 'tools/unity/finalize_r4_simulator.py', 'tools/unity/freeze_r4_delivery.py']]
selected += [WORK / rel for rel in ['wechat/simulator-r4.json', 'delivery-summary.json', 'requirement-audit.json']]
entries = []
for source in selected:
    relative = source.relative_to(ROOT)
    dest = OUT / relative
    dest.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(source, dest)
    entries.append(dict(path=relative.as_posix(), bytes=source.stat().st_size, sha256=sha(source)))
save(OUT / 'manifest.json', dict(timestamp=now, build='20261025-R4', scope='Incremental simulator evidence, documentation and reporting-tool changes. Historical source-map and frozen runtime package retained.',
     complete=False, touchSuitePassed=True, sensorAcceptancePassed=False, physicalPhoneVerified=False, buildMatch=build_match, files=entries))
print(json.dumps(dict(touchChecks=len(touch['checks']), incrementFiles=len(entries), wasmMatches=True, touchSuitePassed=True, sensorAcceptancePassed=False, physicalPhoneVerified=False), ensure_ascii=False))
