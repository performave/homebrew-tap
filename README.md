# homebrew-tap

A [Homebrew](https://brew.sh) tap for Performave tools.

## Install

```sh
brew tap Performave/tap
```

Then install any package below.

## Packages

### peelr

[Peelr](https://github.com/performave/peelr) — a macOS background remover built
for slide-to-notes workflows.

```sh
brew install --cask peelr
```

### yabai-plus

[yabai-plus](https://github.com/Performave/yabai-plus) — a fork of
[yabai](https://github.com/koekeishiya/yabai) with extra patches, shipped as a
universal binary.

```sh
brew install yabai-plus
```

## Upgrade

```sh
brew update
brew upgrade
brew upgrade --cask
```

## Package Notes

### yabai-plus

This conflicts with the upstream `yabai` formula (both install a `yabai` binary).
If you have upstream yabai installed, remove it first:

```sh
brew uninstall yabai
```

`brew info yabai-plus` prints the post-install caveats (config files, launchd
service, and scripting-addition / sudoers setup). In short:

```sh
cp "$(brew --prefix)/opt/yabai-plus/share/yabai-plus/examples/yabairc" ~/.yabairc
yabai --start-service
```

See the [scripting-addition setup](https://github.com/koekeishiya/yabai/wiki/Installing-yabai-(latest-release)#configure-scripting-addition)
for enabling SIP-gated features.

## Signing

There is no paid Apple Developer account behind these releases for now, so
none of them is notarized:

- **rift-plus** and **yabai-plus** are signed with an Apple Development
  certificate. Homebrew does not quarantine what a formula installs, so they
  need no notarization, and the Accessibility grant survives upgrades. If a
  release is ever ad-hoc signed instead, `brew info <name>` says that every
  upgrade then needs the grant again, and what to do.
- **peelr** is ad-hoc signed. Gatekeeper refuses an app like this once Homebrew
  has quarantined it, so the cask removes the quarantine after installing.

Each source repo picks its signature with a `MACOS_SIGNING` Actions variable
(`adhoc`, `signed`, or `notarized`; see its `docs/ci-setup.md`). With a paid
account again, setting it to `notarized` brings back Developer ID signing and
notarization, and nothing in this tap needs to change.

## Maintenance

Each formula or cask's `url`, `version`, and `sha256` are bumped automatically by
the source project's release workflow when a release is tagged. Those workflows
require a `HOMEBREW_TAP_TOKEN` secret (a token with `contents:write` on this tap
repo) configured in the source repo.
