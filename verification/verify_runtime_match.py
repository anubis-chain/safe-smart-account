#!/usr/bin/env python3
import glob
import json
import subprocess
import sys
from pathlib import Path


NAMES = [
    "Safe",
    "SafeL2",
    "SafeProxyFactory",
    "TokenCallbackHandler",
    "MultiSend",
    "MultiSendCallOnly",
    "CompatibilityFallbackHandler",
    "ExtensibleFallbackHandler",
    "SignMessageLib",
    "CreateCall",
    "SafeToL2Setup",
    "SafeMigration",
    "SimulateTxAccessor",
]


def masked(code: str, references: dict) -> bytes:
    raw = bytearray.fromhex(code.removeprefix("0x"))
    for locations in references.values():
        for location in locations:
            start = location["start"]
            length = location["length"]
            raw[start : start + length] = b"\0" * length
    return bytes(raw)


def encoded_address(address: str) -> str:
    return address.removeprefix("0x").lower().rjust(64, "0")


def immutable_values(code: str, references: dict) -> set[str]:
    raw = code.removeprefix("0x")
    values = set()
    for locations in references.values():
        group_values = {
            raw[location["start"] * 2 : (location["start"] + location["length"]) * 2]
            for location in locations
        }
        if len(group_values) != 1:
            raise ValueError("one immutable id resolved to multiple runtime values")
        values.update(group_values)
    return values


def main() -> int:
    if len(sys.argv) != 5:
        print("usage: verify_runtime_match.py <contracts-dir> <manifest> <rpc> <cast>", file=sys.stderr)
        return 2

    contracts_dir = Path(sys.argv[1]).resolve()
    manifest_path = Path(sys.argv[2]).resolve()
    rpc = sys.argv[3]
    cast = sys.argv[4]
    manifest = json.loads(manifest_path.read_text())

    print("name\timmutable_ranges\tlocal_bytes\tchain_bytes\tnormalized_match\timmutable_values_match")
    failures = 0
    for name in NAMES:
        candidates = glob.glob(str(contracts_dir / "out" / "*" / f"{name}.json"))
        if not candidates:
            candidates = glob.glob(str(contracts_dir / "artifacts" / f"{name}.json"))
        if len(candidates) != 1:
            print(f"{name}\tERROR: expected one artifact, got {len(candidates)}", file=sys.stderr)
            return 2

        artifact = json.loads(Path(candidates[0]).read_text())
        deployed = artifact["deployedBytecode"]
        local_code = deployed["object"]
        references = deployed.get("immutableReferences", {})
        chain_code = subprocess.run(
            [cast, "code", manifest[name], "--rpc-url", rpc],
            check=True,
            capture_output=True,
            text=True,
        ).stdout.strip()

        local_masked = masked(local_code, references)
        chain_masked = masked(chain_code, references)
        match = local_masked == chain_masked
        expected_immutables = set()
        if name in {"MultiSend", "SafeToL2Setup", "SimulateTxAccessor"}:
            expected_immutables = {encoded_address(manifest[name])}
        elif name == "SafeMigration":
            expected_immutables = {
                encoded_address(manifest["SafeMigration"]),
                encoded_address(manifest["Safe"]),
                encoded_address(manifest["SafeL2"]),
                encoded_address(manifest["CompatibilityFallbackHandler"]),
            }
        values_match = immutable_values(chain_code, references) == expected_immutables
        ranges = sum(len(locations) for locations in references.values())
        print(f"{name}\t{ranges}\t{len(bytes.fromhex(local_code.removeprefix('0x')))}\t{len(bytes.fromhex(chain_code.removeprefix('0x')))}\t{'yes' if match else 'no'}\t{'yes' if values_match else 'no'}")
        failures += 0 if match and values_match else 1

    return 1 if failures else 0


if __name__ == "__main__":
    raise SystemExit(main())
