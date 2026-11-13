class YabaiPlus < Formula
  desc "Tiling window manager for macOS (yabai fork with extra patches)"
  homepage "https://github.com/Performave/yabai-plus"
  url "https://github.com/performave/yabai-plus/releases/download/v7.1.25-plus.7/yabai-v7.1.25-plus.7.tar.gz"
  version "7.1.25-plus.7"
  sha256 "0235da90fd7505ea44edb392ae977fbe0c25c0ba44c9328f9b66a1cb247494af"
  head "https://github.com/Performave/yabai-plus.git", branch: "master"

  depends_on macos: :big_sur

  # NOTE: this installs a `yabai` binary and so collides with the upstream
  # `yabai` formula. We deliberately do NOT use `conflicts_with "yabai"`: the
  # upstream formula lives in a third-party tap (koekeishiya/formulae) that
  # modern Homebrew refuses to auto-load, which would break `brew info`/install.
  # Homebrew's automatic keg link-collision check covers this case instead.

  def install
    # Release tarballs ship a universal binary signed in CI, as the source
    # repo's MACOS_SIGNING variable says. `head` builds compile from source
    # and get an ad-hoc signature instead.
    if build.head?
      system "make", "-j1", "install"
      system "codesign", "-fs", "-", "#{buildpath}/bin/yabai"
    end

    bin.install "#{buildpath}/bin/yabai"
    (pkgshare/"examples").install "#{buildpath}/examples/yabairc"
    (pkgshare/"examples").install "#{buildpath}/examples/skhdrc"
    man1.install "#{buildpath}/doc/yabai.1"
  end

  # Asked of the binary itself rather than assumed, so the caveats follow
  # whatever the release actually is.
  def adhoc_signed?
    return false unless (bin/"yabai").exist?

    Utils.safe_popen_read("/usr/bin/codesign", "-dv", (bin/"yabai").to_s, err: :out)
         .include?("Signature=adhoc")
  rescue ErrorDuringExecution
    false
  end

  def caveats
    text = <<~EOS
      This is yabai-plus, a fork of yabai. It installs a `yabai` binary and
      conflicts with the upstream `yabai` formula.

      Copy the example configuration into your home directory:
        cp #{opt_pkgshare}/examples/yabairc ~/.yabairc
        cp #{opt_pkgshare}/examples/skhdrc ~/.skhdrc

      If you want yabai to be managed by launchd (start automatically upon login):
        yabai --start-service

      When running as a launchd service logs will be found in:
        /tmp/yabai_<user>.[out|err].log

      If you are using the scripting-addition, set up the passwordless `--load-sa`
      sudoers rule. The easiest way is to let yabai write the sha256-pinned rule
      for you (re-run it whenever the binary is upgraded):
        sudo yabai --install-sudoers

      Or do it by hand:
        sudo visudo -f /private/etc/sudoers.d/yabai

      Build the configuration row by running:
        echo "$(whoami) ALL=(root) NOPASSWD: sha256:$(shasum -a 256 $(\\which yabai) | cut -d " " -f 1) $(\\which yabai) --load-sa"

      README: https://github.com/koekeishiya/yabai/wiki/Installing-yabai-(latest-release)#configure-scripting-addition
    EOS

    return text unless adhoc_signed?

    text + <<~EOS

      This yabai is ad-hoc signed. macOS ties an
      ad-hoc binary's Accessibility grant to that exact build, so after every
      upgrade the entry no longer matches, even if it still shows as allowed.
      After each upgrade, remove yabai from
        System Settings > Privacy & Security > Accessibility
      add #{opt_bin}/yabai back, and restart the service:
        yabai --restart-service
    EOS
  end

  test do
    # Release artifacts report the upstream base version (e.g. "yabai-v7.1.25"),
    # without the fork's "-plus.N" suffix.
    base = version.to_s.split("-").first
    assert_match "yabai-v#{base}", shell_output("#{bin}/yabai --version")
  end
end
