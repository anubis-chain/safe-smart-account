# Verification notes

Date: 2026-08-27. Target: Safe v1.5.0 suite on Anubis Chain `6714`.

## What was checked

- Production config addresses for Safe, SafeProxyFactory, CompatibilityFallbackHandler, MultiSend, and MultiSendCallOnly match this repo’s deployment list.
- `Safe.VERSION()` returns `1.5.0`.
- All 13 deploy receipts have `status=0x1` and `contractAddress` equal to the list.
- On-chain runtime bytecode matches the Foundry artifacts in this repository.
- For contracts with immutables (`MultiSend`, `SafeToL2Setup`, `SafeMigration`, `SimulateTxAccessor`), bytecode matches after stripping immutable slots, and on-chain immutable values match the deployed addresses / constructor arguments.

Supporting tables live under `verification/`.

## Reproduce

```bash
cast chain-id --rpc-url https://rpc.anubispace.org
cast call 0xe9c0dcAEAeD249730E4364F81DB565517F920e46 'VERSION()(string)' \
  --rpc-url https://rpc.anubispace.org

python3 verification/verify_runtime_match.py \
  . \
  deployment/safe-v1.5.0-production-chain-6714.json \
  https://rpc.anubispace.org \
  "$(command -v cast)"
```

## Out of scope

No private keys, frontend, transaction service, or per-wallet owner/threshold review. Integrators should still confirm factory, singleton, and fallback handler addresses in their own UI/config before creating Safes.
