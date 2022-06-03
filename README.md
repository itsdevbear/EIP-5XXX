# EIP-5XXX

EIP-5XXX extends ERC4626 to allow for shareholders to earn rewards in an arbitrary number of additional assets in addition to the underlying asset.

## Motivation

ERC4626 is limited to distributing yield in the underlying asset denomination, which can create situations where it cannot be utilized. Earning a second (or third or fourth) reward token is an important piece of decentralized finance and having a composable and standardized means to do so feels as if it is a natural extension to the goal of ERC4626. Some example use cases for EIP-5XXX are:

- Liquidity Mining Programs
- Bribe Marketplaces
- Distribution of Block Rewards for a Proof of Stake Blockchain

<!-- ## Getting Started

```
mkdir my-project
cd my-project
forge init --template https://github.com/FrankieIsLost/forge-template
git submodule update --init --recursive  ## initialize submodule dependencies
npm install ## install development dependencies
make build
make test
```

## Features

### Testing Utilities

Includes a `Utilities.sol` contract with common testing methods (like creating users with an initial balance), as well as various other utility contracts.

### Preinstalled dependencies

`ds-test` for testing, `forge-std` for better cheatcode UX, and `solmate` for optimized contract implementations.

### Linting

Pre-configured `solhint` and `prettier-plugin-solidity`. Can be run by

```
make solhint
make prettier
```

### CI with Github Actions

Automatically run linting and tests on pull requests.

### Default Configuration

Including `.gitignore`, `.vscode`, `foundry.toml`

## Acknowledgement

Inspired by great dapptools templates like https://github.com/gakonst/forge-template, https://github.com/gakonst/dapptools-template and https://github.com/transmissions11/dapptools-template -->
