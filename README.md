# Anubis Chain Safe v1.5.0

[![CI](https://github.com/anubis-chain/safe-smart-account/actions/workflows/ci.yml/badge.svg)](https://github.com/anubis-chain/safe-smart-account/actions/workflows/ci.yml)
[![License: LGPL-3.0-only](https://img.shields.io/badge/license-LGPL--3.0--only-blue.svg)](LICENSE)

Verified **Safe smart-account contracts** deployed on Anubis Chain mainnet (chain ID `6714`).

This repository is the **verified contract source** plus the production deployment record for Anubis Chain. It is not the hosted wallet UI.

**[GuardSafe](https://guardsafe.org/)** is the live multisig dapp. **[AnubisScan](https://anubisscan.io/)** is the explorer. RPC: `https://rpc.anubispace.org`

The contracts are Safe v1.5.0 from upstream tag `v1.5.0` (`dc437e8fba8b4805d76bcbd1c668c9fd3d1e83be`), compiled with Solidity `0.7.6`, optimizer off, EVM `istanbul`. They were deployed directly (not at Safe canonical addresses).

## Production addresses (chain 6714)

| Contract | Address |
| --- | --- |
| Safe | [`0xe9c0dcAEAeD249730E4364F81DB565517F920e46`](https://anubisscan.io/address/0xe9c0dcAEAeD249730E4364F81DB565517F920e46) |
| SafeL2 | [`0x43fF9804a12c4edEaf3990964f7bAB672309fD6A`](https://anubisscan.io/address/0x43fF9804a12c4edEaf3990964f7bAB672309fD6A) |
| SafeProxyFactory | [`0x34fAEC3BD5fD968f58E5bC4E945230c0fA7979C7`](https://anubisscan.io/address/0x34fAEC3BD5fD968f58E5bC4E945230c0fA7979C7) |
| TokenCallbackHandler | [`0x00D39329F84aaa6aC48716bA0769531E4944eb3c`](https://anubisscan.io/address/0x00D39329F84aaa6aC48716bA0769531E4944eb3c) |
| MultiSend | [`0x0aB6AEd0C8c5b1AAc245acfe450091aC80ad6D6e`](https://anubisscan.io/address/0x0aB6AEd0C8c5b1AAc245acfe450091aC80ad6D6e) |
| MultiSendCallOnly | [`0x74dc591CD6aEFFE853223F38530583365e377eea`](https://anubisscan.io/address/0x74dc591CD6aEFFE853223F38530583365e377eea) |
| CompatibilityFallbackHandler | [`0xdd5b51bce0C7abC83e508396b182F7c092AB6697`](https://anubisscan.io/address/0xdd5b51bce0C7abC83e508396b182F7c092AB6697) |
| ExtensibleFallbackHandler | [`0x507Fd39838783cB7bf53e7a499ADC7b63f298671`](https://anubisscan.io/address/0x507Fd39838783cB7bf53e7a499ADC7b63f298671) |
| SignMessageLib | [`0x791889dF025AC8f2c0D96E6a102390370e2778DE`](https://anubisscan.io/address/0x791889dF025AC8f2c0D96E6a102390370e2778DE) |
| CreateCall | [`0xbEC915289d6FbeeDF8EB3b6f59C4AF4f805453fF`](https://anubisscan.io/address/0xbEC915289d6FbeeDF8EB3b6f59C4AF4f805453fF) |
| SafeToL2Setup | [`0x8AA24682dD2B9d5D8116137A17D5509ebbEa6641`](https://anubisscan.io/address/0x8AA24682dD2B9d5D8116137A17D5509ebbEa6641) |
| SafeMigration | [`0x66D7CCFa5F218cb396358Fad882f2314b4FC2B9A`](https://anubisscan.io/address/0x66D7CCFa5F218cb396358Fad882f2314b4FC2B9A) |
| SimulateTxAccessor | [`0xbD73aFD8fe9e45047599bf41Ce44E713e4Cf9EaF`](https://anubisscan.io/address/0xbD73aFD8fe9e45047599bf41Ce44E713e4Cf9EaF) |

`SafeProxy` has no single suite address. Each wallet proxy is created by `SafeProxyFactory`. Source, ABI, and runtime hash for `SafeProxy` are included so a given proxy can be checked.

The deployment JSON still contains the historical `environment: "test"` label written by the deploy script. That label does not change chain ID, addresses, receipts, or bytecode. These addresses are the production suite used on chain 6714.

## Layout

| Path | Purpose |
| --- | --- |
| `source/safe-smart-account/contracts/` | Safe v1.5.0 Solidity for the deployed suite |
| `source/deployment/DeploySafe.s.sol` | Snapshot of the deploy script |
| `abi/` | JSON ABIs |
| `artifacts/` | Foundry artifacts (bytecode + metadata) |
| `deployment/safe-v1.5.0-production-chain-6714.json` | Addresses and deploy tx hashes |
| `build-config/` | Compiler settings used for the verified build |
| `verification/` | On-chain bytecode match evidence |
| `docs/VERIFICATION.md` | How the match was checked |

## Build

Requires [Foundry](https://book.getfoundry.sh/). The root `foundry.toml` compiles the published source tree without extra downloads:

```bash
forge build
```

## Verify on-chain match

```bash
shasum -a 256 -c FILES.sha256
python3 verification/verify_runtime_match.py \
  . \
  deployment/safe-v1.5.0-production-chain-6714.json \
  https://rpc.anubispace.org \
  "$(command -v cast)"
```

This proves the artifacts in this repo match runtime bytecode on chain 6714. It is **not** a full security audit of a specific Safe proxy (owners, threshold, modules, guards, or balances).

## License

LGPL-3.0-only, same as [Safe smart account](https://github.com/safe-global/safe-smart-account). See [LICENSE](LICENSE).

## Security

Please report Anubis deployment or integration vulnerabilities privately as described in [SECURITY.md](SECURITY.md). Vulnerabilities in the upstream Safe contracts should also follow [Safe's security policy](https://github.com/safe-global/safe-smart-account/security/policy).
