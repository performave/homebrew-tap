class YabaiPlus < Formula
  desc "Tiling window manager for macOS (yabai fork with extra patches)"
  homepage "https://github.com/Performave/yabai-plus"
  url "https://github.com/Performave/yabai-plus/releases/download/v7.1.25-plus.2/yabai-v7.1.25-plus.2.tar.gz"
  version "7.1.25-plus.2"
  sha256 "d58de35b51fbc2f2be2c51657813e0b8cce62f6c4128bbcf332ecd0e24066e02"
  head "https://github.com/Performave/yabai-plus.git", branch: "master"

  depends_on macos: :big_sur

  # NOTE: this installs a `yabai` binary and so collides with the upstream
  # `yabai` formula. We deliberately do NOT use `conflicts_with "yabai"`: the
  # upstream formula lives in a third-party tap (koekeishiya/formulae) that
  # modern Homebrew refuses to auto-load, which would break `brew info`/install.
  # Homebrew's automatic keg link-collision check covers this case instead.

  def install
    # Release tarballs ship a notarized, Developer ID-signed universal binary.
    # `head` builds compile from source and get an ad-hoc signature instead.
    if build.head?
      system "make", "-j1", "install"
      system "codesign", "-fs", "-", "#{buildpath}/bin/yabai"
    end

    bin.install "#{buildpath}/bin/yabai"
    (pkgshare/"examples").install "#{buildpath}/examples/yabairc"
    (pkgshare/"examples").install "#{buildpath}/examples/skhdrc"
    man1.install "#{buildpath}/doc/yabai.1"
  end

  def caveats
    <<~EOS
      This is yabai-plus, a fork of yabai. It installs a `yabai` binary and
      conflicts with the upstream `yabai` formula.

      Copy the example configuration into your home directory:
        cp #{opt_pkgshare}/examples/yabairc ~/.yabairc
        cp #{opt_pkgshare}/examples/skhdrc ~/.skhdrc

      If you want yabai to be managed by launchd (start automatically upon login):
        yabai --start-service

      When running as a launchd service logs will be found in:
        /tmp/yabai_<user>.[out|err].log

      If you are using the scripting-addition, remember to update your sudoers file:
        sudo visudo -f /private/etc/sudoers.d/yabai

      Build the configuration row by running:
        echo "$(whoami) ALL=(root) NOPASSWD: sha256:$(shasum -a 256 $(\\which yabai) | cut -d " " -f 1) $(\\which yabai) --load-sa"

      README: https://github.com/koekeishiya/yabai/wiki/Installing-yabai-(latest-release)#configure-scripting-addition
    EOS
  end

  test do
    # Release artifacts report the upstream base version (e.g. "yabai-v7.1.25"),
    # without the fork's "-plus.N" suffix.
    base = version.to_s.split("-").first
    assert_match "yabai-v#{base}", shell_output("#{bin}/yabai --version")
  end
end
