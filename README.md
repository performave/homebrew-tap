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
Developer ID-signed, notarized universal binary.

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

## Maintenance

Each formula or cask's `url`, `version`, and `sha256` are bumped automatically by
the source project's release workflow when a release is tagged. Those workflows
require a `HOMEBREW_TAP_TOKEN` secret (a token with `contents:write` on this tap
repo) configured in the source repo.
