cask "peelr" do
  version "1.0.0"
  sha256 :no_check

  url "https://github.com/performave/peelr/releases/download/v#{version}/Peelr-#{version}.zip"
  name "Peelr"
  desc "Background remover for macOS slide-to-notes workflows"
  homepage "https://github.com/performave/peelr"

  depends_on macos: ">= :sonoma"

  app "Peelr.app"

  zap trash: "~/Library/Preferences/com.performave.peelr.plist"
end
