# homebrew-yabai-plus

A [Homebrew](https://brew.sh) tap for [yabai-plus](https://github.com/Performave/yabai-plus) —
a fork of [yabai](https://github.com/koekeishiya/yabai) with extra patches, shipped
as a Developer ID-signed, notarized universal binary.

## Install

```sh
brew install Performave/yabai-plus/yabai-plus
```

This conflicts with the upstream `yabai` formula (both install a `yabai` binary).
If you have upstream yabai installed, remove it first:

```sh
brew uninstall yabai
```

## Upgrade

```sh
brew update && brew upgrade yabai-plus
```

## After installing

`brew info yabai-plus` prints the post-install caveats (config files, launchd
service, and scripting-addition / sudoers setup). In short:

```sh
cp "$(brew --prefix)/opt/yabai-plus/share/yabai-plus/examples/yabairc" ~/.yabairc
yabai --start-service
```

See the [scripting-addition setup](https://github.com/koekeishiya/yabai/wiki/Installing-yabai-(latest-release)#configure-scripting-addition)
for enabling SIP-gated features.

## Maintenance

The formula's `url`, `version`, and `sha256` are bumped automatically by the
[`release` workflow](https://github.com/Performave/yabai-plus/blob/master/.github/workflows/release.yml)
in the main repo whenever a `v*` tag is pushed. That step requires a
`HOMEBREW_TAP_TOKEN` secret (a token with `contents:write` on this tap repo) in
the yabai-plus repo.
