cask "peelr" do
  version "1.0.0"
  sha256 "5d7cb52c11e4ef43f53718572153d993ea5ae1a34f91cd38d558d6dd20cad077"

  url "https://github.com/performave/peelr/releases/download/v1.0.0/Peelr-1.0.0.zip"
  name "Peelr"
  desc "Background remover for macOS slide-to-notes workflows"
  homepage "https://github.com/performave/peelr"

  depends_on macos: ">= :sonoma"

  app "Peelr.app"

  # Releases are ad-hoc signed and not notarized while the Peelr repo has no
  # paid Apple Developer account behind it (its MACOS_SIGNING variable). Once
  # Homebrew has quarantined such an app, Gatekeeper refuses to open it, and
  # since macOS 15 right-click > Open no longer gets past that. The release
  # workflow pins the download's sha256 above, so lift the quarantine. This is
  # harmless for a notarized release, and can go once releases are notarized
  # again. Homebrew deprecated `postflight` blocks, and a declarative step
  # cannot ask Gatekeeper first, so it runs for every release.
  postflight_steps do
    run "/usr/bin/xattr",
        args:           ["-dr", "com.apple.quarantine", "{{appdir}}/Peelr.app"],
        writable_paths: ["{{appdir}}/Peelr.app"]
  end

  zap trash: "~/Library/Preferences/com.performave.peelr.plist"
end
