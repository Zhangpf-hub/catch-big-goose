"""Read-only evidence collector for one fixed stability build; never builds or runs QA.

Only <build>/delivery-verification.json is written. Raw reports are never changed.
Release defaults: release/ + windows-release-files.json; WeChat defaults: wechat/
(or the warm workspace export) + wechat-files.json + wechat-package-audit.json.
File manifests accept a path map, a list of path/bytes/sha256 rows, or {files: ...}.
Delivery manifests must also bind nativeBuildInputsSha256; WeChat additionally
binds auditSha256 so an old audit cannot be silently paired with a new export.
"""
import argparse
import datetime as dt
import hashlib
import json
import math
import re
import sys
import xml.etree.ElementTree as ET
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
WORK = ROOT / 'work/stable-visibility-stage-two-20261026'
PROJECT = Path(json.loads((ROOT / 'workspace.json').read_text('utf-8-sig'))['paths']['unity'])
GENERATED = {'Assets/Scenes/Main.unity', 'Assets/WX-WASM-SDK-V2/Editor/MiniGameConfig.asset'}
QA_REVISION_PATHS = {'Assets/Scripts/GooseStageTwoStabilityAcceptance.cs',
                     'Assets/Scripts/GooseRevealStabilityAcceptance.cs'}
QA_REPORTS = {'stage-two-stability.json', 'reveal-stability.json'}
FIXTURE_NEGATIVES = {
    'shake-lock': 'shakeLock', 'helper-lock': 'helperLock', 'depth-lock': 'depthLock', 'outside-band': 'boundsMax',
    'not-exposed': 'surfaceExposed', 'not-known': 'surfaceKnown', 'not-surface': 'surfaceActive', 'raw-miss': 'raw',
    'independent-miss': 'independent', 'expired': 'nextCheck', 'not-reprobed': 'previousNextCheck',
    'not-current-positive-probe': 'nextCheck', 'wrong-fixed-clock': 'fixedTime', 'old-pose-moved': 'positionDelta',
    'old-angle-moved': 'angleDelta', 'original-selected': 'selected', 'identity-mismatch': 'currentId',
    'other-round': 'sameRound', 'not-original-lower': 'initialHeld', 'original-dynamic': 'initialKinematic',
    'original-gravity': 'initialGravity', 'not-held-transition': 'previousHeld', 'still-held': 'currentHeld',
    'still-kinematic': 'currentKinematic', 'no-restored-gravity': 'currentGravity', 'disabled-collider': 'colliderEnabled',
    'animation-owner': 'surfaceAnimating', 'not-prephysics': 'prePhysics', 'not-fixed-step': 'inFixedStep'}
REPORTS = ('visibility-stability.json', 'stage-two-stability.json',
           'surface-acceptance.json', 'interaction.json', 'acceptance.json', 'reveal-stability.json')


def read(path):
    return json.loads(path.read_text('utf-8-sig'))


def sha(path):
    digest = hashlib.sha256()
    with path.open('rb') as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b''):
            digest.update(block)
    return digest.hexdigest()


def files(directory):
    return {p.relative_to(directory).as_posix(): {'bytes': p.stat().st_size, 'sha256': sha(p)}
            for p in sorted(directory.rglob('*')) if p.is_file()}


def inputs(project):
    return {prefix + '/' + name: row for prefix in ('Assets', 'Packages', 'ProjectSettings')
            for name, row in files(project / prefix).items()}


def manifest(data):
    if isinstance(data, dict) and 'files' in data:
        data = data['files']
    if isinstance(data, list):
        pairs = [(row['path'], row) for row in data]
    elif isinstance(data, dict):
        pairs = list(data.items())
    else:
        raise ValueError('Manifest must be a file map or a list of path/bytes/sha256 rows')
    result = {}
    for name, row in pairs:
        name = str(name).replace('\\', '/')
        if name.startswith('/') or ':' in name or '..' in name.split('/') or name in result:
            raise ValueError('Unsafe or duplicate manifest path: ' + name)
        if not isinstance(row, dict) or not re.fullmatch('[0-9a-fA-F]{64}', str(row.get('sha256', ''))):
            raise ValueError('Missing complete SHA-256 for ' + name)
        result[name] = {'bytes': int(row['bytes']), 'sha256': row['sha256'].lower()}
    if not result:
        raise ValueError('Empty file manifest')
    return result


def differences(expected, actual):
    return [{'path': name, 'kind': 'added' if name not in expected else 'removed' if name not in actual else 'modified',
             'expected': expected.get(name), 'actual': actual.get(name)}
            for name in sorted(expected.keys() | actual.keys()) if expected.get(name) != actual.get(name)]


def production_path(name):
    return name.startswith(('Assets/Scripts/', 'Assets/Resources/', 'Assets/Plugins/',
                            'Assets/StreamingAssets/', 'Assets/MobileContact/',
                            'Assets/Mascots/', 'Assets/WebGLTemplates/'))


def relative(path):
    try:
        return path.relative_to(ROOT).as_posix()
    except ValueError:
        return str(path)


def production_digest(mapping):
    # Exclude exactly the two guarded QA sources, including no .meta or folder.
    return hashlib.sha256(json.dumps({k: mapping[k] for k in sorted(mapping) if k not in QA_REVISION_PATHS},
                                    sort_keys=True, separators=(',', ':')).encode()).hexdigest()


def qa_only_changes(old, new):
    changed = differences(old, new)
    return changed, [row for row in changed if row['path'] not in QA_REVISION_PATHS or row['kind'] != 'modified']


def guarded_qa(text):
    lines = [line.strip() for line in text.lstrip('\ufeff').splitlines() if line.strip()]
    if not lines or re.sub(r'\s+', '', lines[0]) != '#if(UNITY_EDITOR||DEVELOPMENT_BUILD)&&!UNITY_WEBGL':
        return False
    depth = 0
    for index, line in enumerate(lines):
        if re.match(r'#if\b', line):
            depth += 1
        elif re.match(r'#(?:else|elif)\b', line) and depth == 1:
            return False
        elif re.match(r'#endif\b', line):
            depth -= 1
            if depth < 0 or (depth == 0 and index != len(lines) - 1):
                return False
    return depth == 0


def method_digest(text, name):
    match = re.search(r'^\s*(?:static\s+)?[\w.<>]+\s+' + re.escape(name) + r'\([^\n;]*\)\s*\{', text, re.M)
    if not match:
        raise ValueError('Required actual source method absent: ' + name)
    start, pos, depth = match.start(), text.index('{', match.start()), 0
    quoted = None
    while pos < len(text):
        char = text[pos]
        if quoted:
            if char == '\\':
                pos += 2; continue
            if char == quoted:
                quoted = None
        elif text.startswith('//', pos):
            pos = text.find('\n', pos)
            if pos < 0:
                break
            continue
        elif text.startswith('/*', pos):
            end = text.find('*/', pos + 2)
            if end < 0:
                break
            pos = end + 2; continue
        elif char in ('"', "'"):
            quoted = char
        elif char == '{':
            depth += 1
        elif char == '}':
            depth -= 1
            if depth == 0:
                return hashlib.sha256(text[start:pos + 1].encode('utf-8')).hexdigest()
        pos += 1
    raise ValueError('Unterminated source method: ' + name)


def timing_witness(raw):
    if raw.get('completed') is not True or raw.get('passed') is not False or not raw.get('errors'):
        raise ValueError('Timing witness must retain its completed original false QA result')
    accepted = set(raw.get('acceptedIds') or []) | set(raw.get('fixedStepIds') or [])
    for pre in raw.get('fixedPromotions', []):
        old, now = pre.get('oldState') or {}, pre.get('currentState') or {}
        identity = pre.get('instanceId')
        ft = pre.get('fixedTime', math.nan)
        if not (identity not in accepted and pre.get('originalAccepted') is False
                and pre.get('phase') == 'FixedUpdate observer(-99), after Depth(-100), before physics'
                and pre.get('beforeSimulation') is True and pre.get('inFixedStep') is True
                and all(pre.get(k) is False for k in ('shakeLock', 'helperLock', 'depthLock', 'qaLocked'))
                and pre.get('previousKnown') is True and pre.get('previousExposed') is False
                and pre.get('previousNextCheck', math.inf) <= ft and pre.get('previousFixedTime', math.inf) < ft
                and pre.get('inBand') is True and pre.get('productionProbe') is True and pre.get('independentProbe') is True
                and pre.get('positionDelta') == 0 and pre.get('angle') == 0
                and old.get('instanceId') == identity and now.get('instanceId') == identity
                and old.get('held') is True and old.get('kinematic') is True and old.get('gravity') is False
                and now.get('held') is False and now.get('kinematic') is False and now.get('gravity') is True
                and all(now.get(k) is True for k in ('surface', 'surfaceKnown', 'surfaceExposed'))
                and math.isclose(now.get('nextSurfaceCheck', math.nan), ft + .25, abs_tol=.00001)
                and math.isclose(pre.get('time', math.nan), ft, abs_tol=.000001)
                and len(pre.get('samples', [])) == 5
                and any(s.get('ownHit') is True and s.get('firstIsSelf') is True and s.get('firstId') == identity
                        for s in pre.get('samples', []))):
            continue
        for eof in raw.get('lowerOffenders', []):
            current = eof.get('currentState') or {}
            if (eof.get('instanceId') == identity and eof.get('frame') == pre.get('frame')
                    and eof.get('phase') == 'WaitForEndOfFrame after production LateUpdate'
                    and eof.get('beforeSimulation') is False and eof.get('inFixedStep') is False
                    and math.isclose(eof.get('fixedTime', math.nan), ft, abs_tol=.000001)
                    and eof.get('time', -math.inf) > pre['time'] and eof.get('originalAccepted') is False
                    and all(eof.get(k) is False for k in ('shakeLock', 'helperLock', 'depthLock', 'qaLocked'))
                    and eof.get('productionProbe') is False and eof.get('independentProbe') is False
                    and eof.get('positionDelta', 0) > .0005 and eof.get('angle', 0) > .05
                    and eof.get('violatingSamples', 0) > 0
                    and current.get('surfaceExposed') is True and current.get('surfaceKnown') is True
                    and current.get('nextSurfaceCheck') == now['nextSurfaceCheck']):
                return {'instanceId': identity, 'item': pre.get('item'), 'frame': pre['frame'], 'fixedTime': ft,
                        'previousNextCheck': pre['previousNextCheck'], 'newDeadline': now['nextSurfaceCheck'],
                        'beforeSimulationTime': pre['time'], 'beforeSimulationPositionDelta': pre['positionDelta'],
                        'beforeSimulationAngle': pre['angle'], 'eofTime': eof['time'],
                        'eofPositionDelta': eof['positionDelta'], 'eofAngle': eof['angle'],
                        'rawProductionExposureBeforeSimulation': True, 'independentFiveRayExposureBeforeSimulation': True,
                        'bothEofProbesFalseAfterPhysics': True, 'nonAcceptedIdentity': True}
    raise ValueError('No complete same-identity/same-frame fresh Fixed-before-physics to EOF timing witness')


def derive_timing_evidence(raw_path, diagnostic_build, diagnostic_source, base_native_path):
    raw = read(raw_path); witness = timing_witness(raw)
    native_path = diagnostic_build / 'native-build-inputs.json'
    native, base = manifest(read(native_path)), manifest(read(base_native_path))
    diff, forbidden = qa_only_changes(base, native)
    if forbidden:
        raise ValueError('Diagnostic full source has differences outside the two guarded QA paths')
    source_key = 'Assets/Scripts/GooseStageTwoStabilityAcceptance.cs'
    source_sha = sha(diagnostic_source)
    text = diagnostic_source.read_text('utf-8-sig')
    if source_sha != native[source_key]['sha256'] or not guarded_qa(text):
        raise ValueError('Diagnostic actual source is not the guarded source bound to its full native inputs')
    player_manifest = raw_path.parent / 'player-files.json'
    expected = manifest(read(player_manifest)); actual = files(diagnostic_build / 'player')
    if differences(expected, actual):
        raise ValueError('Raw diagnostic used a different complete player file set')
    return {'schema': 'qa-promotion-timing-evidence-v1',
            'scope': 'One directly observed QA sampling-time defect. Old untraced toy61/BBQ1 counters are not individually explained; new QA reruns replace those gates.',
            'passed': True, 'errors': [], 'checks': ['raw false preserved', 'fresh legitimate promotion before simulation',
                'same identity/frame exposed before physics but covered/moved at EOF', 'full diagnostic source and player bound'],
            'rawReport': {'path': relative(raw_path), 'sha256': sha(raw_path), 'originalPassed': raw['passed'],
                          'originalErrors': raw['errors'], 'originalLowerViolations': raw.get('lowerViolations')},
            'diagnosticNativeInputs': {'path': relative(native_path), 'sha256': sha(native_path), 'files': len(native)},
            'baseNativeInputs': {'path': relative(base_native_path), 'sha256': sha(base_native_path)},
            'diagnosticSource': {'path': relative(diagnostic_source), 'sha256': source_sha, 'nativeInputKey': source_key},
            'sourceMethods': {name: method_digest(text, name) for name in ('CaptureLowerDiagnostic', 'ObserveFixedPromotions')},
            'methodHashNormalization': 'UTF8-SIG decoded, universal newlines, actual method signature through paired closing brace',
            'fullInputDifferences': diff, 'sharedProductionSha256': production_digest(native),
            'playerFilesManifest': {'path': relative(player_manifest), 'sha256': sha(player_manifest)},
            'diagnosticPlayerDirectory': relative(diagnostic_build / 'player'), 'diagnosticPlayerFiles': actual,
            'witness': witness}


def sampling_failure_signature(data, name, build_id):
    signatures = {'stage-two-stability.json': 'challenge toss preserves the original container, lower supports, floor and boundary',
                  'reveal-stability.json': 'animation leaves lower fixed and never supplements target identities'}
    motion = data.get('motion') or {}
    common = (name in signatures and data.get('build') == build_id and data.get('completed') is True
              and data.get('passed') is False and data.get('errors') == [signatures.get(name)]
              and data.get('lowerViolations', 0) > 0
              and data.get('floorViolations') == 0 and data.get('boundaryViolations') == 0
              and all(value == 0 for key, value in data.items() if key.endswith('Violations') and key != 'lowerViolations')
              and data.get('accepted') is True and data.get('observedToss') is True
              and motion.get('mode') == 'controlled-pan-toss' and motion.get('tossCompleted') is True
              and not motion.get('interrupted') and not motion.get('tossFailure') and motion.get('affected', 0) > 0)
    if not common:
        return False
    if name == 'stage-two-stability.json':
        original, selected = data.get('acceptedIds') or [], data.get('fixedStepIds') or []
        return (data.get('warmupStock') == 15 and data.get('tutorialPicks') == 15 and data.get('secondStock') == 300
                and data.get('candidateCoverage', 0) >= .8 and bool(original)
                and 0 < len(selected) <= 48 and set(selected) <= set(original))
    original, selected = data.get('originalSurfaceIds') or [], data.get('fixedIds') or []
    picks, phases = data.get('picks') or [], data.get('phases') or []
    return (data.get('initialStock') == 300 and 1 <= len(picks) <= 3
            and data.get('finalStock') == 300 - len(picks) and data.get('sustainedReveals', 0) > 0
            and data.get('targetReplacementViolations') == 0
            and all(all(p.get(k) is True for k in ('began', 'accepted', 'pickedStateObserved', 'exitedInventory'))
                    and p.get('after') == p.get('before', 0) - 1 for p in picks)
            and [p.get('name') for p in phases] == ['initial'] + ['after-pick-' + str(i + 1) for i in range(len(picks))] + ['after-toss']
            and all(p.get('completed') is True and p.get('inconclusive') is False and p.get('stableSeconds', 0) >= 12
                    and p.get('maxProbes', 257) <= 256 and p.get('stationaryFlips') == 0
                    and all((p.get('colorGeometryReference') or {}).get(k) is True for k in
                            ('passed', 'noisePassed', 'rendererStateRestored', 'casterControlApplicable', 'casterStateRestored'))
                    for p in phases)
            and bool(original) and 0 < len(selected) <= 48 and set(selected) <= set(original)
            and len(selected) / len(original) >= .8)


def fixture_cases_valid(data):
    if not isinstance(data, dict):
        return False
    rows = data.get('cases') or []
    if data.get('completed') is not True or data.get('passed') is not True or data.get('errors') != [] or not isinstance(rows, list) or len(rows) != 30 or not all(isinstance(row, dict) for row in rows):
        return False
    by_name = {row.get('name'): row for row in rows}
    if len(by_name) != 30 or set(by_name) != set(FIXTURE_NEGATIVES) | {'actual-native-v2-prephysics-positive'}:
        return False
    for name, row in by_name.items():
        positive = name == 'actual-native-v2-prephysics-positive'
        if row.get('expected') is not positive or row.get('actual') is not positive or row.get('passed') is not True:
            return False
        if row.get('changedField') != ('' if positive else FIXTURE_NEGATIVES[name]):
            return False
    return True


def fixture_source_hashes(path):
    # Match the actually executed PowerShell extractor exactly: raw CR/LF,
    # literal public signature, matched closing brace, no BOM or extra newline.
    text = path.read_bytes().decode('utf-8-sig')
    start = text.index('public static class GooseLowerPromotionWitnessPolicy')
    end = text.index('    [DefaultExecutionOrder(-99)]', start)
    policy = text[start:end]
    start = policy.index('public static bool Accept(')
    pos, depth = policy.index('{', start), 0
    while pos < len(policy):
        if policy[pos] == '{':
            depth += 1
        elif policy[pos] == '}':
            depth -= 1
            if depth == 0:
                return (hashlib.sha256(policy[start:pos + 1].encode()).hexdigest(),
                        hashlib.sha256(policy.encode()).hexdigest(), text)
        pos += 1
    raise ValueError('Actual shared predicate closing brace absent')


def positive_from_raw(pre):
    old, current = pre['oldState'], pre['currentState']
    bounds = current['colliderBounds']
    return dict(initialId=old['instanceId'], currentId=current['instanceId'], sameRound=True, exists=pre['exists'],
        initialHeld=old['held'], initialKinematic=old['kinematic'], initialGravity=old['gravity'], previousHeld=True,
        selected=pre['originalAccepted'], prePhysics=pre['beforeSimulation'], inFixedStep=pre['inFixedStep'],
        shakeLock=pre['shakeLock'], helperLock=pre['helperLock'], depthLock=pre['depthLock'],
        currentHeld=current['held'], currentKinematic=current['kinematic'], currentGravity=current['gravity'],
        surfaceActive=current['surface'], surfaceKnown=current['surfaceKnown'], surfaceExposed=current['surfaceExposed'],
        colliderEnabled=current['colliderEnabled'], surfaceAnimating=current['surfaceAnimating'], active=True, picked=False,
        raw=pre['productionProbe'], independent=pre['independentProbe'], time=pre['time'], fixedTime=pre['fixedTime'],
        nextCheck=current['nextSurfaceCheck'], previousNextCheck=pre['previousNextCheck'],
        boundsMax=bounds['m_Center']['y'] + bounds['m_Extent']['y'], band=pre['band'],
        positionDelta=pre['positionDelta'], angleDelta=pre['angle'])


def single_rotation_errors(report, context):
    """Validate the four executed single-rotation cases; no synthetic pass or 2ms hard cap."""
    errors = []
    def need(ok, label):
        if not ok:
            errors.append(label)
    def number(row, key):
        value = row.get(key)
        return value if isinstance(value, (int, float)) and not isinstance(value, bool) and math.isfinite(value) else None
    def near_vector(a, b, maximum):
        if not isinstance(a, dict) or not isinstance(b, dict):
            return False
        values = [number(row, key) for row in (a, b) for key in ('x', 'y', 'z')]
        return None not in values and sum((values[i] - values[i + 3]) ** 2 for i in range(3)) <= maximum ** 2
    def near_rotation(a, b, maximum_degrees):
        if not isinstance(a, dict) or not isinstance(b, dict):
            return False
        av = [number(a, key) for key in ('x', 'y', 'z', 'w')]
        bv = [number(b, key) for key in ('x', 'y', 'z', 'w')]
        if None in av or None in bv:
            return False
        aa, bb = sum(x*x for x in av), sum(x*x for x in bv)
        return .99 <= aa <= 1.01 and .99 <= bb <= 1.01 and abs(sum(x*y for x, y in zip(av, bv))) / math.sqrt(aa*bb) >= math.cos(math.radians(maximum_degrees / 2))
    need(isinstance(context, dict) and context.get('part') == 'single-rotation', 'runner part is single-rotation')
    checks = report.get('checks') or []
    need(report.get('completed') is True and report.get('passed') is True and report.get('errors') == []
         and len(checks) >= 67, 'completed/passed/errors and all 67 current checks')
    cases = report.get('singleRotationCases') or []
    names = ('actual-tilted-book-success', 'actual-tilted-book-cancel', 'actual-tilted-book-reject', 'actual-double-envelope-budget')
    need(len(cases) == 4 and {c.get('name') for c in cases if isinstance(c, dict)} == set(names), 'exact four named cases')
    if len(cases) != 4 or any(not isinstance(c, dict) for c in cases) or {c.get('name') for c in cases} != set(names):
        return errors
    by_name = {c['name']: c for c in cases}
    for name, row in by_name.items():
        scale, seconds = number(row, 'itemScale'), number(row, 'seconds')
        need(scale is not None and scale > 0 and seconds is not None and 0 <= seconds <= 1.51,
             name + ': finite scale and unchanged 1.51s deadline')
        need(row.get('began') is True and row.get('uprightUsed') is True and row.get('envelopePasses') == 2
             and row.get('lowerViolations') == 0, name + ': accepted two-pose planning and zero lower violations')
        need(all(number(row, key) is not None and number(row, key) >= 0 for key in ('planningMs', 'maxSliceMs')),
             name + ': actual planning/slice cost is recorded without a new hard slice threshold')
        need(row.get('item') == ('ref_bfsesameball' if name == names[3] else 'ref_gtstickerbook')
             and row.get('vertices') == (100 if name == names[3] else 9), name + ': unchanged actual convex fixture')
    positive = by_name[names[0]]
    scale = number(positive, 'itemScale')
    need(positive.get('success') is True and positive.get('cancelled') is False and positive.get('jointAirborne') is True
         and not positive.get('failure'), 'positive: actual completed simultaneous airborne flip')
    if scale is not None and scale > 0:
        net, settled = number(positive, 'netXZ'), number(positive, 'settledNetXZ')
        gap_min, gap_max = number(positive, 'settledMinGap'), number(positive, 'settledMaxGap')
        penetration = number(positive, 'settledPenetration')
        need(net is not None and .2*scale - .002 <= net <= .3*scale + .002,
             'positive: original 0.2–0.3 scale endpoint tolerance')
        need(settled is not None and settled >= .12*scale, 'positive: settled net XZ remains at least 0.12 scale')
        need(gap_min is not None and gap_max is not None and -.02 <= gap_min <= gap_max <= min(.065, max(.025, scale*.06))
             and penetration is not None and 0 <= penetration <= .002, 'positive: true settled support gap and penetration')
    positive_checks = ('lands in the validated new orientation', 'restores unconstrained gravity after landing',
                       'settles naturally without a rotation lock', 'settled hull and center stay within floor and bowl limits',
                       'lower support remains unchanged after settling', 'settled collision query is complete')
    need(all(names[0] + ' ' + label in checks for label in positive_checks)
         and all(names[0] + ' actual settled support and hull gap ' + str(i) in checks for i in range(5)),
         'positive: executed orientation, ordinary physics, five real support probes and complete collision query')
    cancel = by_name[names[1]]
    need(cancel.get('cancelled') is True and cancel.get('success') is False and cancel.get('cancelledWhilePaused') is True
         and near_vector(cancel.get('startPosition'), cancel.get('endPosition'), .0005)
         and near_rotation(cancel.get('startRotation'), cancel.get('restoredRotation'), .05),
         'cancel: paused in-progress cancellation restores original pose')
    need(all(names[1] + ' ' + label in checks for label in (
        'synchronous cancellation restores original position and rotation',
        'cancellation restores original collision, gravity and velocity state',
        'cancellation also covers the paused new-orientation state', 'cancellation exercised the new pose path')),
        'cancel: executed synchronous pose/collision/velocity restoration checks')
    for name in names[2:]:
        row = by_name[name]
        need(row.get('success') is False and row.get('cancelled') is False
             and 'single_unstable_com_support' in str(row.get('failure', ''))
             and 'timeout' not in str(row.get('failure', '')).lower()
             and name + ' rejects both completed envelope poses for the actual unsafe support rather than a timeout' in checks,
             name + ': actual support rejection after both envelopes, not completed animation')
    return errors


class Collector:
    def __init__(self, args):
        self.args = args
        self.build = WORK / args.build
        self.snapshot = Path(args.snapshot).resolve() if args.snapshot else WORK / 'build-workspace' / PROJECT
        self.errors, self.missing, self.checks = [], [], []
        self.result = {'buildName': args.build, 'createdUtc': dt.datetime.now(dt.timezone.utc).isoformat(),
                       'scope': 'Fixed native evidence and optional export/publication verification; no build or QA executed.',
                       'phoneAcceptancePassed': False, 'realWechatSensorAcceptancePassed': None}
        self.runs = []
        self.revision_build = WORK / args.qa_revision_build if args.qa_revision_build else None
        self.revision_snapshot = Path(args.qa_revision_snapshot).resolve() if args.qa_revision_snapshot else None
        self.superseded_refs, self.deferred_failures = {}, []
        self.review_valid = False

    def check(self, ok, label):
        (self.checks if ok else self.errors).append(label)
        return bool(ok)

    def load(self, path, required=True):
        if not path.is_file():
            if required:
                self.missing.append(relative(path))
            return None
        try:
            return read(path)
        except (ValueError, OSError) as error:
            self.errors.append(f'{relative(path)}: {error}')
            return None

    def identity(self, path, actual, label):
        data = self.load(path)
        if data is None:
            return False
        try:
            diff = differences(manifest(data), actual)
            self.check(not diff, label + ': complete file set and SHA-256 match')
            return {'manifest': relative(path), 'manifestSha256': sha(path), 'differences': diff}
        except (ValueError, KeyError, TypeError) as error:
            self.errors.append(label + ': invalid manifest: ' + str(error))
            return False

    def artifact_binding(self, path, audit_path=None):
        data = self.load(path)
        if not isinstance(data, dict):
            if data is not None:
                self.missing.append(relative(path) + ':nativeBuildInputsSha256')
            return
        expected = self.build / 'native-build-inputs.json'
        binding = data.get('nativeBuildInputsSha256')
        if not binding:
            self.missing.append(relative(path) + ':nativeBuildInputsSha256')
        elif expected.is_file():
            self.check(binding.lower() == sha(expected), relative(path) + ': artifact bound to tested native inputs')
        if audit_path is not None:
            binding = data.get('auditSha256')
            if not binding:
                self.missing.append(relative(path) + ':auditSha256')
            elif audit_path.is_file():
                self.check(binding.lower() == sha(audit_path), relative(path) + ': complete export bound to successful audit')
    def source(self):
        original = self.load(self.build / 'source-inputs.json')
        native = self.load(self.build / 'native-build-inputs.json')
        if original is None or native is None:
            return
        original, native = manifest(original), manifest(native)
        initial_diff = differences(original, native)
        self.check(not initial_diff, 'Copied source inputs exactly match native build inputs')
        live = inputs(ROOT / PROJECT)
        warm = inputs(self.snapshot)
        revision_native = self.revision_source(native) if self.revision_build else None
        comparisons = {}
        candidates = [('currentMain', live), ('warmSnapshot', warm)]
        if self.args.webgl_snapshot:
            candidates.append(('webglSnapshot', inputs(Path(self.args.webgl_snapshot).resolve())))
        for label, actual in candidates:
            expected = revision_native if label == 'currentMain' and revision_native is not None else native
            diff = differences(expected, actual)
            allowed = [row for row in diff if row['path'] in GENERATED and row['kind'] == 'modified'
                       and not (label == 'currentMain' and self.revision_build)]
            unexpected = [row for row in diff if row not in allowed]
            production = [row for row in diff if production_path(row['path'])]
            self.check(not unexpected, label + ': no unapproved source/input additions, removals or changes')
            self.check(not production, label + ': production runtime and resources have zero differences')
            comparisons[label] = {'files': len(actual), 'differences': diff,
                                  'expectedInputBuild': self.args.qa_revision_build if expected is revision_native else self.args.build,
                                  'allowedWebglGeneratedChanges': allowed,
                                  'unexpectedDifferences': unexpected, 'productionDifferences': production}
        self.result['sourceVerification'] = {'copiedFiles': len(original), 'nativeFiles': len(native),
            'sourceManifestSha256': sha(self.build / 'source-inputs.json'),
            'nativeManifestSha256': sha(self.build / 'native-build-inputs.json'),
            'copyToNativeDifferences': initial_diff, **comparisons}
        theme_data = self.load(self.snapshot / 'Assets/Resources/Data/themes.json')
        self.themes = [t['id'] for t in theme_data['themes']] if theme_data else []
        self.check(len(self.themes) == 5, 'Exactly five themes in tested snapshot')
        performance = self.snapshot / 'Assets/Scripts/GooseRuntimePerformance.cs'
        if performance.is_file():
            match = re.search(r'BuildId\s*=\s*"([^"]+)"', performance.read_text('utf-8-sig'))
            self.build_id = match.group(1) if match else None
            self.check(bool(self.build_id), 'Tested snapshot has a runtime BuildId')
            self.result['buildId'] = self.build_id

    def evidence_ref(self, ref, label, within=None, read_json=True):
        if not isinstance(ref, dict) or not isinstance(ref.get('path'), str):
            self.errors.append(label + ': path/SHA-256 reference required')
            return None
        path = Path(ref['path'])
        path = (ROOT / path).resolve() if not path.is_absolute() else path.resolve()
        if not path.is_relative_to((within or WORK).resolve()):
            self.errors.append(label + ': reference outside approved evidence directory')
            return None
        if not path.is_file():
            self.missing.append(relative(path))
            return None
        if not re.fullmatch('[0-9a-fA-F]{64}', str(ref.get('sha256', ''))) or sha(path) != ref['sha256'].lower():
            self.errors.append(label + ': evidence SHA-256 mismatch: ' + relative(path))
            return None
        data = self.load(path) if read_json else None
        return {'path': relative(path), 'sha256': sha(path), 'data': data, 'absolute': path} if data is not None or not read_json else None

    def revision_source(self, native):
        original_path = self.revision_build / 'source-inputs.json'
        native_path = self.revision_build / 'native-build-inputs.json'
        original, newer = self.load(original_path), self.load(native_path)
        if original is None or newer is None:
            return None
        original, newer = manifest(original), manifest(newer)
        self.check(not differences(original, newer), 'QA revision copied inputs exactly match its own native build inputs')
        changed, unexpected = qa_only_changes(native, newer)
        self.check(bool(changed) and not unexpected, 'Old/new full inputs differ only in the exact two QA .cs paths, modified only')
        self.check(not differences(newer, inputs(self.revision_snapshot)), 'QA revision full snapshot exactly matches its native input manifest')
        for snapshot in (self.snapshot, self.revision_snapshot):
            for name in sorted(QA_REVISION_PATHS):
                path = snapshot / name
                self.check(path.is_file() and guarded_qa(path.read_text('utf-8-sig')),
                           relative(path) + ': whole QA source guarded EDITOR/DEVELOPMENT and !WEBGL')
        old_digest, new_digest = production_digest(native), production_digest(newer)
        self.check(old_digest == new_digest, 'Old/new production inputs including .meta/hooks/packages/settings are identical')
        self.result['qaRevision'] = {'baseBuild': self.args.build, 'revisionBuild': self.args.qa_revision_build,
            'baseNativeInputManifestSha256': sha(self.build / 'native-build-inputs.json'),
            'revisionSourceInputManifestSha256': sha(original_path), 'revisionNativeInputManifestSha256': sha(native_path),
            'fullInputDifferences': changed, 'unexpectedDifferences': unexpected,
            'productionDigestExcludedPaths': sorted(QA_REVISION_PATHS), 'baseProductionSha256': old_digest,
            'revisionProductionSha256': new_digest, 'sameBinaryClaimed': False,
            'artifactSourceBuild': self.args.build, 'transitionAndRevealEvidenceBuild': self.args.qa_revision_build,
            'scope': 'Old release/WebGL retain old complete input identity; only production inputs are shared.'}
        review_path = Path(self.args.qa_revision_review).resolve()
        review = self.load(review_path)
        if review is not None:
            if not isinstance(review, dict):
                self.errors.append('QA revision review must be a JSON object of explicit path/SHA references')
                return newer
            self.result['qaRevision']['review'] = {'path': relative(review_path), 'sha256': sha(review_path)}
            refs = review.get('superseded', [])
            if self.check(isinstance(refs, list) and len(refs) == 2, 'QA revision review explicitly lists exactly the two old false reports'):
                for ref in refs:
                    proof = self.evidence_ref(ref, 'Superseded sampling report', self.build)
                    if proof is None:
                        continue
                    data = proof['data']
                    performance = self.snapshot / 'Assets/Scripts/GooseRuntimePerformance.cs'
                    match = re.search(r'BuildId\s*=\s*"([^"]+)"', performance.read_text('utf-8-sig'))
                    base_id = match.group(1) if match else None
                    ok = self.check(sampling_failure_signature(data, proof['absolute'].name, base_id),
                                    proof['path'] + ': exact approved lower-sampling-only failure, correct base build, other gates intact')
                    if ok:
                        self.superseded_refs[proof['absolute']] = proof
            self.v2_proof = self.evidence_ref(review.get('v2Evidence'), 'V2 confirmation evidence')
            self.fixture_proof = self.evidence_ref(review.get('freshFixFixture'), 'Fresh-fix sampling fixture')
            self.review_valid = len(self.superseded_refs) == 2 and self.validate_revision_witnesses()
        return newer

    def validate_revision_witnesses(self):
        if not self.v2_proof or not self.fixture_proof:
            return False
        data = self.v2_proof['data']
        if not self.check(isinstance(data, dict) and data.get('schema') == 'qa-promotion-timing-evidence-v1',
                          'V2 confirmation has the actual approved timing witness schema'):
            return False
        raw = self.evidence_ref(data.get('rawReport'), 'V2 original raw report')
        native = self.evidence_ref(data.get('diagnosticNativeInputs'), 'V2 diagnostic full inputs')
        base = self.evidence_ref(data.get('baseNativeInputs'), 'V2 reference base full inputs', self.build)
        source = self.evidence_ref(data.get('diagnosticSource'), 'V2 actual diagnostic source', read_json=False)
        player_manifest = self.evidence_ref(data.get('playerFilesManifest'), 'V2 complete diagnostic player identity')
        if not all((raw, native, base, source, player_manifest)):
            return False
        base_ok = self.check(base['absolute'] == (self.build / 'native-build-inputs.json').resolve(),
                             'V2 witness is compared with this exact original delivery native source')
        expected = derive_timing_evidence(raw['absolute'], native['absolute'].parent,
                                          source['absolute'], base['absolute'])
        v2_ok = self.check(data == expected, 'V2 confirmation revalidated from raw same-ID Fixed-to-EOF witness and full source/player hashes')
        self.result.setdefault('qaRevision', {})['v2TimingEvidence'] = {
            'path': self.v2_proof['path'], 'sha256': self.v2_proof['sha256'],
            'rawReport': expected['rawReport'], 'witness': expected['witness'], 'scope': expected['scope']}
        fixture = self.fixture_proof['data']
        fixture_ok = self.check(fixture_cases_valid(fixture), 'Fresh-fix actual C# predicate executed one real positive and all 29 distinct required negatives')
        if not isinstance(fixture, dict):
            return False
        stage = self.evidence_ref({'path': fixture.get('stageSource'), 'sha256': fixture.get('stageSha256')},
                                  'Fresh-fix actual Stage source', read_json=False)
        reveal = self.evidence_ref({'path': fixture.get('revealSource'), 'sha256': fixture.get('revealSha256')},
                                   'Fresh-fix actual Reveal source', read_json=False)
        positive = self.evidence_ref({'path': fixture.get('evidencePath'), 'sha256': fixture.get('evidenceSha256')},
                                     'Fresh-fix real positive evidence')
        script = self.evidence_ref(fixture.get('executionScript'), 'Fresh-fix actually executed extraction script', read_json=False)
        if not all((stage, reveal, positive, script)):
            return False
        revision_native = manifest(read(self.revision_build / 'native-build-inputs.json'))
        hashes_match = self.check(stage['sha256'] == revision_native['Assets/Scripts/GooseStageTwoStabilityAcceptance.cs']['sha256']
            and reveal['sha256'] == revision_native['Assets/Scripts/GooseRevealStabilityAcceptance.cs']['sha256'],
            'Actual fixture full Stage/Reveal sources match the exact revision native inputs')
        method_sha, policy_sha, stage_text = fixture_source_hashes(stage['absolute'])
        reveal_text = reveal['absolute'].read_text('utf-8-sig')
        method_ok = self.check(fixture.get('method') == 'CatchGoose.GooseLowerPromotionWitnessPolicy.Accept'
            and fixture.get('methodSha256') == method_sha and fixture.get('policySha256') == policy_sha
            and 'GooseLowerPromotionWitnessPolicy.Accept(d.witness)' in stage_text
            and 'GooseLowerPromotionWitnessPolicy.Accept(evidence)' in reveal_text,
            'Fresh-fix compiled actual shared predicate/method hashes and both QA call sites agree')
        witness = expected['witness']; raw_data = raw['data']; positive_data = positive['data']
        pre = next(p for p in raw_data['fixedPromotions'] if p['instanceId'] == witness['instanceId'] and p['frame'] == witness['frame'])
        eof = next(p for p in raw_data['lowerOffenders'] if p['instanceId'] == witness['instanceId'] and p['frame'] == witness['frame'])
        raw_ref_ok = self.check(Path(fixture.get('rawPath', '')).resolve() == raw['absolute']
            and fixture.get('rawSha256') == raw['sha256'] and fixture.get('instanceId') == witness['instanceId']
            and fixture.get('frame') == witness['frame'] and positive_data.get('rawSha256') == raw['sha256']
            and Path(positive_data.get('rawPath', '')).resolve() == raw['absolute']
            and positive_data.get('prePhysics') == pre and positive_data.get('eof') == eof
            and positive_data.get('positive') == positive_from_raw(pre),
            'Actual executed positive fields are derived from the same bound raw prephysics/EOF witness')
        self.result['qaRevision']['freshFixFixture'] = {'path': self.fixture_proof['path'], 'sha256': self.fixture_proof['sha256'],
            'methodSha256': method_sha, 'policySha256': policy_sha, 'stageSource': stage['path'], 'stageSha256': stage['sha256'],
            'revealSource': reveal['path'], 'revealSha256': reveal['sha256'], 'executionScript': fixture['executionScript'],
            'cases': fixture['cases'], 'scope': fixture.get('scope')}
        return bool(base_ok and v2_ok and fixture_ok and hashes_match and method_ok and raw_ref_ok)

    def report_ok(self, report, path, complete=True):
        ok = report.get('passed') is True and report.get('errors') == [] and bool(report.get('checks'))
        if complete:
            ok = ok and report.get('completed') is True
        if 'build' in report and self.build_id:
            ok = ok and report['build'] == self.build_id
        return self.check(ok, relative(path) + ': completed/passed/errors/build are valid')

    def picture(self, directory, name):
        path = directory / name
        if not path.resolve().is_relative_to(directory.resolve()) or not path.is_file() or path.stat().st_size == 0:
            self.missing.append(relative(path))
            return False
        return True

    def pictures(self, directory, report, field, minimum=1):
        rows = report.get(field, [])
        self.check(len(rows) >= minimum, directory.name + ': sufficient ' + field)
        for row in rows:
            self.picture(directory, row['file'])

    def collect_runs(self):
        self.collect_build_runs(self.build, 'base')
        if self.revision_build:
            self.collect_build_runs(self.revision_build, 'qa-revision')
        self.result['runs'] = [{k: v for k, v in run.items() if k not in ('directory', 'data')}
                               for run in self.runs]

    def collect_build_runs(self, build, role):
        player_dir = build / 'player'
        if not (player_dir / 'catch-big-goose.exe').is_file():
            self.missing.append(relative(player_dir / 'catch-big-goose.exe'))
            return
        player = files(player_dir)
        if role == 'base':
            self.result['qaPlayerFiles'] = player
        else:
            self.result.setdefault('qaRevision', {})['playerFiles'] = player
        for directory in sorted(build.iterdir()):
            if not directory.is_dir() or not directory.name.startswith(('visibility-', 'transition-', 'regression-', 'reveal-')):
                continue
            names = [name for name in REPORTS if (directory / name).is_file()]
            if not names:
                self.missing.append(relative(directory) + '/acceptance-report')
                continue
            for name in names:
                path = directory / name
                report = self.load(path)
                if report is None:
                    continue
                proof = self.superseded_refs.get(path.resolve()) if role == 'base' else None
                if proof:
                    self.check(sha(path) == proof['sha256'], relative(path) + ': listed original false report hash is unchanged')
                    self.check(sampling_failure_signature(report, name, self.build_id),
                               relative(path) + ': retained exact lower-sampling-only failure and base BuildId')
                    # Preserve original false status. Final adjudication occurs
                    # only after all new QA evidence and coverage have passed.
                    ok = False
                    self.deferred_failures.append({'path': relative(path), 'sha256': sha(path),
                        'originalPassed': report.get('passed'), 'originalErrors': report.get('errors'),
                        'status': 'unresolved-old-failure'})
                else:
                    ok = self.report_ok(report, path, name not in ('interaction.json', 'acceptance.json'))
                bound = self.identity(directory / 'player-files.json', player, directory.name)
                after = directory / 'player-files-after.json'
                if after.exists():
                    self.identity(after, player, directory.name + ' after-run')
                receipt = self.load(directory / 'run-result.json', required=False)
                context = self.load(directory / 'run-context.json', required=False)
                if receipt is not None:
                    receipt_ok = not receipt.get('timedOut') and receipt.get('playerUnchanged') is True
                    if proof:
                        receipt_ok = receipt_ok and receipt.get('passed') is False and receipt.get('exitCode') not in (None, 0)
                    else:
                        receipt_ok = receipt_ok and receipt.get('passed') is True and receipt.get('completed') is True and receipt.get('exitCode') == 0
                    ok = self.check(receipt_ok, directory.name + ': runner receipt matches retained outcome and immutable player') and ok
                eligible = (name not in QA_REPORTS if role == 'base' else name in QA_REPORTS) if self.revision_build else True
                self.runs.append({'directory': directory, 'name': name, 'data': report,
                                  'ok': bool(ok and bound and not bound['differences']),
                                  'coverageEligible': eligible, 'binaryRole': role,
                                  'historyOnly': not eligible, 'originalPassed': report.get('passed'),
                                  'playerIdentity': bound, 'path': relative(path), 'sha256': sha(path), 'context': context})

    def require(self, label, predicate):
        matches = [run for run in self.runs if run['ok'] and run.get('coverageEligible', True) and predicate(run)]
        if not matches:
            self.missing.append('coverage:' + label)
        else:
            self.checks.append('Coverage: ' + label)
        return matches

    def coverage(self):
        self.result['visibilityExperiments'] = []
        for theme in self.themes:
            for mode in ('natural', 'frozen'):
                matches = self.require('visibility/' + theme + '/' + mode, lambda r, t=theme, m=mode:
                    r['name'] == 'visibility-stability.json' and r['data'].get('theme') == t
                    and r['data'].get('mode') == m)
                for run in matches:
                    d = run['data']
                    self.check(d.get('difficulty') == 1 and d.get('itemCount') == 300
                               and d.get('coverageSufficient') is True and d.get('requestedSeconds', 0) >= 20
                               and d.get('observedSeconds', 0) + .1 >= d.get('requestedSeconds', 0),
                               run['directory'].name + ': real second-stage long visual coverage')
                    self.pictures(run['directory'], d, 'captures')
                    experiment = {'report': run['path'], 'reportSha256': run['sha256']}
                    for field in ('reference', 'shadowControl', 'colorGeometryReference'):
                        ref = d.get(field)
                        if isinstance(ref, dict):
                            # Raw all-caster lighting and no-shadow are retained
                            # experiments, including failed comparisons. Only the
                            # approved caster-preserving color test gates delivery.
                            experiment[field] = ref
                            self.check(all(isinstance(ref.get(k), bool) for k in
                                           ('passed', 'noisePassed', 'rendererStateRestored')),
                                       run['directory'].name + ': ' + field + ' records independent outcome/noise/restore')
                            if field == 'reference':
                                self.check(ref.get('noisePassed') is True and ref.get('rendererStateRestored') is True,
                                           run['directory'].name + ': original reference self-noise and restore pass')
                            elif field == 'colorGeometryReference':
                                self.check(ref.get('passed') is True and ref.get('casterControlApplicable') is True
                                           and ref.get('casterStateRestored') is True,
                                           run['directory'].name + ': approved production-caster color gate passes')
                            for key in ('actualFile', 'referenceFile', 'noiseFile'):
                                if ref.get(key):
                                    self.picture(run['directory'], ref[key])
                        else:
                            self.missing.append(run['path'] + ':' + field)
                    self.result['visibilityExperiments'].append(experiment)
            self.require('transition/sensor/' + theme, lambda r, t=theme:
                r['name'] == 'stage-two-stability.json' and r['data'].get('theme') == t
                and r['data'].get('input') == 'sensor' and r['data'].get('requestedDelay') == 0
                and r['data'].get('readyFrame') == r['data'].get('injectionFrame'))
        self.require('transition/desktop-manual', lambda r: r['name'] == 'stage-two-stability.json'
                     and r['data'].get('input') == 'manual' and '-desktop-' in r['directory'].name
                     and isinstance(r.get('context'), dict) and r['context'].get('mobileProfile') is False)
        for run in self.runs:
            if run['name'] != 'stage-two-stability.json' or not run['ok'] or not run.get('coverageEligible', True):
                continue
            d = run['data']; motion = d.get('motion') or {}
            accepted = d.get('acceptedIds') or []
            selected = d.get('fixedStepIds') or []
            self.check(d.get('warmupStock') == 15 and d.get('tutorialPicks') == 15 and d.get('secondStock') == 300
                       and d.get('accepted') is True and d.get('observedToss') is True
                       and motion.get('tossCompleted') is True and not motion.get('interrupted')
                       and not motion.get('tossFailure') and d.get('candidateCoverage', 0) >= .8
                       and bool(accepted) and 0 < len(selected) <= 48 and set(selected) <= set(accepted)
                       and all(d.get(k) == 0 for k in ('lowerViolations', 'floorViolations', 'boundaryViolations')),
                       run['directory'].name + ': genuine tutorial-to-challenge and safe accepted toss')
            self.pictures(run['directory'], d, 'clipFrames', 20)
        matrices = self.require('matrix/full-five-themes-95-rows', lambda r:
            r['name'] == 'surface-acceptance.json' and len(r['data'].get('rows', [])) == 95)
        for run in matrices:
            rows = run['data']['rows']
            for theme in self.themes:
                for stock in (300, 71, 70, 69, 18, 3):
                    selected = [row for row in rows if row['theme'] == theme and row['stock'] == stock]
                    operations = {row['operation'] for row in selected}
                    expected = {'idle', 'sensor', 'sensor-moderate'} if stock == 300 else {'idle', 'button'}
                    self.check(expected <= operations and bool({'shuffle', 'shuffle-unavailable-single'} & operations),
                               f'Matrix operations: {theme}/{stock}')
            self.check(all(row.get('lowerViolations') == 0 for row in rows), 'Matrix lower-state violations are zero')
        fallback = self.require('fallback/physical-shapes-and-budget', lambda r: r['name'] == 'surface-acceptance.json'
            and 'fixture-pinned-three' in {row['operation'] for row in r['data'].get('rows', [])})
        expected = {'fixture-pinned-three', 'fixture-free-three', 'fixture-pinned-single',
                    'fixture-actual-tilted-steamer-single', 'fixture-actual-max-unique-single', 'fixture-actual-max-raw-single'}
        for run in fallback:
            self.check(expected <= {row['operation'] for row in run['data']['rows']}, 'All real convex and fallback fixtures exist')
        self.require('interrupt/all-five-themes', lambda r: r['name'] == 'surface-acceptance.json'
                     and sum(c == 'home interrupts a genuinely active paid shuffle rather than an unavailable operation'
                             for c in r['data'].get('checks', [])) == 5)
        for stock, theme in ((3, self.themes[0] if self.themes else ''), (18, 'barbecue'),
                             (300, self.themes[0] if self.themes else '')):
            matches = self.require('toss/' + str(stock), lambda r, s=stock, t=theme:
                r['name'] == 'surface-acceptance.json' and len(r['data'].get('rows', [])) == 1
                and r['data']['rows'][0].get('operation') == 'sensor-moderate-toss'
                and r['data']['rows'][0].get('stock') == s and r['data']['rows'][0].get('theme') == t)
            for run in matches:
                d = run['data']; row = d['rows'][0]; selected = row.get('targetIds') or []
                needed = max(1, math.ceil(len(selected) * .6))
                self.check(row.get('motionMode') == 'controlled-pan-toss' and row.get('tossCompleted') is True
                           and not row.get('tossFailure') and row.get('controlledTossObserved') is True
                           and row.get('jointEnough', 0) >= needed and row.get('visibleArcEnough', 0) >= needed
                           and all(row.get(k) == 0 for k in ('lowerViolations', 'tossFloorViolations', 'tossBoundaryViolations')),
                           run['directory'].name + ': airborne flip, visible arc, completed safe toss')
                traces = row.get('tossTargets', [])
                self.check(0 < len(selected) <= 48 and len(traces) == len(selected)
                           and {t.get('instanceId') for t in traces} == set(selected)
                           and row.get('planarMovedEnough', 0) >= max(1, math.ceil(len(selected) * .5))
                           and sum(t.get('airborneFlip') is True and t.get('maxRise', 0) >= .6 * row['itemScale']
                                   and t.get('maxTurn', 0) >= 75 for t in traces) >= needed
                           and sum(t.get('peakXZ', 0) >= .18 * row['itemScale'] and t.get('peakXZPixels', 0) >= 15
                                   for t in traces) >= needed,
                           run['directory'].name + ': independent target traces and final net planar motion pass')
                self.check(len(d.get('clipFrames', [])) == 33, run['directory'].name + ': exactly 33 captured toss frames')
                self.pictures(run['directory'], d, 'clipFrames', 33); self.picture(run['directory'], 'clip-before.png')
        clips = self.require('clip/production-camera', lambda r: r['name'] == 'surface-acceptance.json'
            and any(row.get('operation') == 'sensor-moderate-clip' for row in r['data'].get('rows', [])))
        for run in clips:
            self.check(len(run['data'].get('clipFrames', [])) == 33, run['directory'].name + ': exactly 33 clip frames')
            self.pictures(run['directory'], run['data'], 'clipFrames', 33); self.picture(run['directory'], 'clip-before.png')
        for name, minimum in (('interaction.json', 61), ('acceptance.json', 122)):
            self.require(name, lambda r, n=name, m=minimum: r['name'] == n and len(r['data'].get('checks', [])) >= m)
        self.reveal_coverage()
        if getattr(self.args, 'require_single_rotation', False):
            self.single_rotation_coverage()

    def single_rotation_coverage(self):
        matches = self.require('single-rotation/actual-upright-cancel-reject-budget', lambda run:
            run['name'] == 'surface-acceptance.json' and run.get('binaryRole') == 'base'
            and isinstance(run.get('context'), dict) and run['context'].get('part') == 'single-rotation')
        self.result['singleRotationReports'] = []
        for run in matches:
            failures = single_rotation_errors(run['data'], run['context'])
            self.check(not failures, run['directory'].name + ': single-rotation contract: ' + ('; '.join(failures) if failures else 'all four cases pass'))
            self.result['singleRotationReports'].append({'path': run['path'], 'sha256': run['sha256'],
                'playerIdentity': run['playerIdentity'], 'passed': not failures, 'errors': failures,
                'cases': run['data'].get('singleRotationCases')})

    def reveal_coverage(self):
        self.result['revealReports'] = []
        for theme in self.themes:
            matches = self.require('reveal/real-pick-and-toss/' + theme, lambda r, t=theme:
                r['name'] == 'reveal-stability.json' and r['data'].get('theme') == t)
            for run in matches:
                d = run['data']; picks = d.get('picks') or []; phases = d.get('phases') or []
                self.check(d.get('initialStock') == 300 and 1 <= len(picks) <= 3
                           and d.get('finalStock') == 300 - len(picks) and d.get('sustainedReveals', 0) > 0,
                           run['directory'].name + ': real stock300 picks leave sustained newly revealed inventory')
                for index, pick in enumerate(picks):
                    self.check(all(pick.get(k) is True for k in
                                   ('began', 'accepted', 'pickedStateObserved', 'exitedInventory'))
                               and pick.get('before') == 300 - index and pick.get('after') == pick.get('before', 0) - 1,
                               run['directory'].name + ': production pointer pick identity/removal ' + str(index + 1))
                expected_names = ['initial'] + ['after-pick-' + str(i + 1) for i in range(len(picks))] + ['after-toss']
                self.check([phase.get('name') for phase in phases] == expected_names,
                           run['directory'].name + ': initial, every real pick, and toss phases are all present')
                for phase in phases:
                    label = run['directory'].name + '/' + str(phase.get('name'))
                    self.check(phase.get('completed') is True and phase.get('inconclusive') is False
                               and phase.get('stableSeconds', 0) >= 12 and phase.get('maxProbes', 257) <= 256
                               and phase.get('stationaryFlips') == 0,
                               label + ': conclusive twelve-second stable window within original query budget')
                    color = phase.get('colorGeometryReference')
                    self.check(isinstance(color, dict) and all(color.get(k) is True for k in
                               ('passed', 'noisePassed', 'rendererStateRestored', 'casterControlApplicable', 'casterStateRestored')),
                               label + ': approved production-caster color/noise/restore gate passes')
                    if isinstance(color, dict):
                        for key in ('actualFile', 'referenceFile', 'noiseFile'):
                            if color.get(key):
                                self.picture(run['directory'], color[key])
                            else:
                                self.missing.append(run['path'] + ':' + label + '/' + key)
                    if phase.get('name') in expected_names:
                        self.picture(run['directory'], phase['name'] + '.png')
                original = d.get('originalSurfaceIds') or []; accepted = d.get('acceptedIds') or []
                selected = d.get('fixedIds') or []; traces = [t for t in d.get('traces', []) if t.get('selected') is True]
                needed = max(1, math.ceil(len(traces) * .6)); motion = d.get('motion') or {}
                self.check(d.get('accepted') is True and bool(original) and set(accepted) == set(original)
                           and 0 < len(selected) <= 48 and set(selected) <= set(original)
                           and len(selected) / max(1, len(original)) >= .8
                           and len(traces) == len(selected) and {t.get('instanceId') for t in traces} == set(selected),
                           run['directory'].name + ': nonempty original snapshot subset, eighty-percent coverage and body cap')
                self.check(d.get('observedToss') is True and motion.get('mode') == 'controlled-pan-toss'
                           and motion.get('tossCompleted') is True and not motion.get('interrupted') and not motion.get('tossFailure')
                           and sum(t.get('airborneFlip') is True for t in traces) >= needed,
                           run['directory'].name + ': real selected cohort completes original sixty-percent joint airborne flip')
                # This frozen report schema does not serialize ItemScale. Keep
                # the actual QA's .18/.12-scale arc/net-XZ gates, not an invented
                # scale or a stricter cohort size, and bind them to its full hash.
                self.check({'existing visible horizontal arc', 'existing settled net-XZ rearrangement'} <= set(d.get('checks', [])),
                           run['directory'].name + ': existing scale-relative arc and half-cohort net-XZ QA gates passed')
                self.check(all(d.get(k) == 0 for k in
                               ('lowerViolations', 'floorViolations', 'boundaryViolations', 'targetReplacementViolations')),
                           run['directory'].name + ': lower, floor, boundary and original target identities remain safe')
                self.result['revealReports'].append({'report': run['path'], 'sha256': run['sha256'],
                    'theme': theme, 'picks': len(picks), 'sustainedReveals': d.get('sustainedReveals'),
                    'phases': phases, 'originalSurfaceIds': original, 'selectedIds': selected, 'selectedTraces': traces,
                    'arcNetEvidence': 'Hash-bound original QA checks; this report does not serialize ItemScale.'})

    def edit_tests(self):
        paths = sorted(self.build.glob('editmode*.xml'))
        if not paths:
            self.missing.append(relative(self.build / 'editmode.xml'))
        results = []
        for path in paths:
            node = ET.parse(path).getroot()
            self.check(node.attrib.get('result') == 'Passed' and int(node.attrib.get('failed', '1')) == 0
                       and int(node.attrib.get('passed', '0')) > 0, relative(path) + ': edit tests pass')
            results.append({'path': relative(path), 'sha256': sha(path), 'attributes': node.attrib})
        self.result['editTests'] = results

    def release(self):
        directory = Path(self.args.release_dir) if self.args.release_dir else self.build / 'release'
        path = Path(self.args.release_manifest) if self.args.release_manifest else self.build / 'windows-release-files.json'
        if not (directory / 'catch-big-goose.exe').is_file():
            self.missing.append(relative(directory / 'catch-big-goose.exe'))
            return
        actual = files(directory)
        identity = self.identity(path, actual, 'Windows release')
        self.artifact_binding(path)
        dll = directory / 'catch-big-goose_Data/Managed/CatchGoose.Runtime.dll'
        if dll.is_file():
            binary = dll.read_bytes()
            self.check(self.build_id is not None and self.build_id.encode('utf-16le') in binary, 'Windows release BuildId matches tested snapshot')
            self.check(not any(marker in binary for marker in (b'GooseSurfacePerformanceAcceptance',
                       b'GooseStageTwoStabilityAcceptance', b'GooseVisibilityStabilityAcceptance', b'GooseSelectionAcceptance')),
                       'Windows release contains no development acceptance classes')
        else:
            self.missing.append(relative(dll))
        self.result['windowsRelease'] = {'directory': relative(directory), 'files': actual, 'identity': identity}

    def wechat(self):
        required = self.args.require_wechat or self.args.require_published
        directory = Path(self.args.wechat_dir) if self.args.wechat_dir else self.build / 'wechat'
        if not directory.exists() and not self.args.wechat_dir:
            directory = WORK / 'build-workspace/builds/catch-big-goose-wechat'
        if not required:
            self.result['wechat'] = {'required': False, 'directory': relative(directory), 'verified': False}
            return
        if not (directory / 'game.js').is_file():
            self.missing.append(relative(directory / 'game.js'))
            return
        actual = files(directory)
        path = Path(self.args.wechat_manifest) if self.args.wechat_manifest else self.build / 'wechat-files.json'
        identity = self.identity(path, actual, 'WeChat complete exported package')
        audit_path = Path(self.args.audit) if self.args.audit else self.build / 'wechat-package-audit.json'
        self.artifact_binding(path, audit_path)
        audit = self.load(audit_path)
        if audit is not None:
            self.check(audit.get('localPackagePassed') is True and audit.get('errors') == [], 'WeChat package audit passed')
            self.check(audit.get('appId') == 'wx60b50db2472c4782', 'WeChat audit uses the project AppID')
        project = self.load(directory / 'project.config.json')
        self.check(project is not None and project.get('appid') == 'wx60b50db2472c4782', 'Export project AppID is correct')
        result = {'required': True, 'directory': relative(directory), 'files': actual, 'identity': identity,
                  'auditPath': relative(audit_path), 'auditSha256': sha(audit_path) if audit_path.exists() else None}
        if self.args.require_published:
            live = ROOT / 'builds/catch-big-goose-wechat'
            live_files = files(live)
            diff = differences(actual, live_files)
            self.check(not diff, 'Published WeChat complete file set exactly matches tested export')
            result.update(publishedFiles=live_files, publishedDifferences=diff)
        self.result['wechat'] = result

    def run(self):
        self.themes, self.build_id = [], None
        for label, operation in (('source', self.source), ('edit tests', self.edit_tests), ('runs', self.collect_runs),
                                 ('coverage', self.coverage), ('release', self.release), ('wechat', self.wechat)):
            try:
                operation()
            except (OSError, ValueError, KeyError, TypeError, ET.ParseError) as error:
                self.errors.append(label + ': ' + str(error))
        self.finalize_revision()
        self.result.update(completed=True, passed=not self.errors and not self.missing,
                           checks=self.checks, errors=self.errors, missing=self.missing)
        output = self.build / 'delivery-verification.json'
        # This is a derived current verification, not a raw run or build report.
        output.write_text(json.dumps(self.result, ensure_ascii=False, indent=2), 'utf-8')
        print(json.dumps({'passed': self.result['passed'], 'checks': len(self.checks),
                          'errors': self.errors, 'missing': self.missing, 'output': relative(output)}, ensure_ascii=False))
        return 0 if self.result['passed'] else 1

    def finalize_revision(self):
        if not self.revision_build:
            return
        review = self.result.setdefault('qaRevision', {})
        seen = {row['path'] for row in self.deferred_failures}
        expected = {proof['path'] for proof in self.superseded_refs.values()}
        self.check(seen == expected and len(seen) == 2, 'All and only the review-listed original false reports were retained')
        accepted = self.review_valid and not self.errors and not self.missing
        for row in self.deferred_failures:
            if accepted:
                row['status'] = 'superseded-qa-sampling-defect'
            else:
                self.errors.append(row['path'] + ': original false report remains unresolved; no valid complete QA revision proof')
        review['supersededReports'] = self.deferred_failures
        review['reuseAuthorizedByVerifiedEvidence'] = accepted


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--build', required=True, help='Existing lowercase-kebab-case fixed BuildName')
    parser.add_argument('--require-wechat', action='store_true')
    parser.add_argument('--require-published', action='store_true')
    parser.add_argument('--require-single-rotation', action='store_true', help='Require the same-player four-case single-rotation QA contract')
    parser.add_argument('--snapshot', help='Exact native Unity snapshot directory; defaults to the historical build-workspace')
    parser.add_argument('--webgl-snapshot', help='Optional separate Unity export snapshot; only the two declared generated files may differ')
    parser.add_argument('--release-dir')
    parser.add_argument('--release-manifest')
    parser.add_argument('--wechat-dir')
    parser.add_argument('--wechat-manifest')
    parser.add_argument('--audit')
    parser.add_argument('--qa-revision-build', help='Separate build providing all fresh StageTwo/Reveal evidence')
    parser.add_argument('--qa-revision-snapshot', help='Exact full Unity snapshot for the QA-only revision')
    parser.add_argument('--qa-revision-review', help='Explicit path/SHA evidence refs; no old failure is silently ignored')
    args = parser.parse_args()
    if not re.fullmatch('[a-z0-9]+(?:-[a-z0-9]+)*', args.build):
        parser.error('--build must use lowercase kebab-case')
    if not (WORK / args.build).is_dir():
        parser.error('Fixed build directory does not exist; collector never creates a build')
    revision_flags = (args.qa_revision_build, args.qa_revision_snapshot, args.qa_revision_review)
    if any(revision_flags) and not all(revision_flags):
        parser.error('All three --qa-revision-* arguments must be supplied together')
    if args.qa_revision_build:
        if not re.fullmatch('[a-z0-9]+(?:-[a-z0-9]+)*', args.qa_revision_build) or args.qa_revision_build == args.build:
            parser.error('--qa-revision-build must name a different lowercase-kebab-case build')
        if not (WORK / args.qa_revision_build).is_dir() or not Path(args.qa_revision_snapshot).is_dir():
            parser.error('QA revision build and exact snapshot must already exist')
    return Collector(args).run()


if __name__ == '__main__':
    sys.exit(main())
