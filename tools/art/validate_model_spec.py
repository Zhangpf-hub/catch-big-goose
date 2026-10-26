"""Portable quality-contract gate for the deterministic Blender refresh generators."""
import argparse
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]


def validate(path):
    spec = json.loads(Path(path).read_text(encoding="utf-8"))
    errors = []
    def check(condition, message):
        if not condition:
            errors.append(message)
    check(spec.get("schemaVersion") == 1, "schemaVersion must be 1")
    check(spec.get("id") and Path(spec["id"]).name == spec["id"], "invalid model id")
    check((ROOT / spec.get("reference", "missing")).is_file(), "missing reference image")
    contract = spec.get("qualityContract", {})
    for key in ("purpose", "recognition", "approximations", "stopConditions"):
        check(bool(contract.get(key)), f"missing qualityContract.{key}")
    for key in ("maxTriangles", "maxMaterials", "maxTextureSize"):
        check(isinstance(contract.get(key), int) and contract[key] > 0, f"invalid {key}")
    check(contract.get("normalizedMaxEdge") == 1, "maximum edge must be normalized to 1")
    parts = spec.get("components", [])
    names = [part.get("name") for part in parts]
    check(bool(parts) and len(set(names)) == len(parts), "component names must be unique")
    for part in parts:
        for key in ("name", "topology", "dimensions", "material", "connection", "features"):
            check(bool(part.get(key)), f"incomplete component {part.get('name')}: {key}")
        parent = part.get("parent")
        check(parent == spec.get("id") or parent in names, f"unknown parent: {parent}")
        seen = {part.get("name")}
        while parent in names:
            if parent in seen:
                errors.append("component hierarchy contains a cycle")
                break
            seen.add(parent)
            parent = parts[names.index(parent)].get("parent")
    inventory = spec.get("detailInventory", [])
    check(bool(inventory), "missing detail inventory")
    for detail in inventory:
        check(detail.get("component") in names and bool(detail.get("implementation")),
              f"unmapped detail: {detail}")
    if errors:
        raise ValueError("\n".join(errors))
    return spec


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("spec", type=Path)
    parser.add_argument("--strict-quality", action="store_true", required=True)
    args = parser.parse_args()
    validate(args.spec)
    print(f"PASS: {args.spec}")
