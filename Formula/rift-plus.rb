class RiftPlus < Formula
  desc "Tiling window manager for macOS (rift fork with extra patches)"
  homepage "https://github.com/performave/rift-plus"
  version "0.5.3-plus.1"
  # Interpolated so the release workflow only has to rewrite `version`.
  url "https://github.com/performave/rift-plus/releases/download/v#{version}/rift-plus-universal-macos-#{version}.tar.gz"
  sha256 "60c6f0e4c0c5f139df10eeac3c8beef8a0c3fa95d503a85178eeb2a33270b798"
  license "Apache-2.0"

  # Only a --HEAD build compiles anything; release installs are a prebuilt
  # universal binary and must not drag in a Rust toolchain.
  head do
    url "https://github.com/performave/rift-plus.git", branch: "main"
    depends_on "rust" => :build
  end

  # No version floor. The one macOS 26 API in rift (NSGlassEffectView, behind
  # the opt-in drop overlay) is guarded at run time and degrades to no overlay,
  # so nothing here hard-requires Tahoe -- but that is also the only version
  # this fork is developed and tested against.

  # NOTE: this installs `rift` and `rift-cli` and so collides with the upstream
  # `rift` formula in acsandmann/tap. We deliberately do NOT declare
  # `conflicts_with "acsandmann/tap/rift"`: resolving it loads that formula,
  # and Homebrew's tap trust refuses to load anything from an untrusted
  # third-party tap with an UntrustedTapError the conflict check does not
  # rescue -- so on a machine that has acsandmann/tap tapped but not trusted
  # (the default) the install dies before it starts. Homebrew's keg
  # link-collision check covers the collision instead, and the caveats below
  # spell out the migration.

  def install
    if build.head?
      system "cargo", "build", "--release", "--locked", "--bins"
      bin.install "target/release/rift", "target/release/rift-cli"
      # A source build is unsigned, and macOS pins the Accessibility grant to
      # the binary's designated requirement -- an ad-hoc signature ties it to a
      # cdhash that every rebuild changes, so Accessibility is lost on each
      # upgrade. Release tarballs avoid this entirely: they ship Developer ID
      # signed and notarized from CI.
      ["rift", "rift-cli"].each do |program|
        system "codesign", "--force", "--sign", "-", bin/program
      end
      opoo "a --HEAD build is ad-hoc signed; expect to re-grant Accessibility after every upgrade"
    else
      bin.install "rift", "rift-cli"
    end
    pkgshare.install "rift.default.toml"
  end

  # The text bends to what is actually on the machine: a leftover upstream
  # keg, or a sudoers rule pinned to whatever binary was here before. Each of
  # those is a step people otherwise find out about from a silent failure.
  def caveats
    text = <<~EOS
      This is rift-plus, a fork of rift. It installs `rift` and `rift-cli` and
      conflicts with the upstream `rift` formula (acsandmann/tap).
    EOS

    if (HOMEBREW_CELLAR/"rift").directory?
      text += <<~EOS

        The upstream `rift` formula is still installed. Nothing here needs it,
        and its service, if running, is a second window manager fighting this
        one. Remove it:
          brew services stop rift
          brew uninstall rift
        rift-plus reads the same ~/.config/rift/config.toml, so the config
        carries over. macOS may ask for the Accessibility grant once more, as
        the binary's path changed.
      EOS
    end

    text += <<~EOS

      Grant Accessibility to rift the first time, or it runs and silently does
      nothing:
        System Settings > Privacy & Security > Accessibility

      Copy the example configuration:
        mkdir -p ~/.config/rift
        cp #{opt_pkgshare}/rift.default.toml ~/.config/rift/config.toml

      To run it under launchd:
        brew services start rift-plus

      Logs are at /tmp/rift_<user>.[out|err].log

      This fork ships its own scripting addition, which is what makes moving a
      window to another space, and creating/destroying spaces, work at all on
      macOS 26. It needs SIP's filesystem and debugging protections disabled and
      the `-arm64e_preview_abi` boot-arg. Let rift re-inject it on every start
      -- it does not survive a reboot or a Dock restart -- in
      ~/.config/rift/config.toml:
        run_on_start = ["sudo rift sa load"]

      launchd has no tty for sudo's password, so install the passwordless rule.
      It is pinned to this exact binary, so this has to run again after every
      install or upgrade of rift-plus:
        sudo rift sa install-sudoers
    EOS

    if File.exist?("/private/etc/sudoers.d/rift")
      text += <<~EOS
        There is already such a rule, pinned to the binary that was here
        before; it does not authorize this one until you do.
      EOS
    end

    text + <<~EOS

      Check both the payload and the rule with:
        rift sa status

      Uninstalling: `brew uninstall` cannot reach the root-owned bundle and
      sudoers rule, so take them out first, while `rift` is still here to do it:
        sudo rift sa uninstall
        brew services stop rift-plus
        brew uninstall rift-plus
    EOS
  end

  service do
    run "#{opt_bin}/rift"
    environment_variables PATH: std_service_path_env, LANG: "en_US.UTF-8"
    keep_alive true
    process_type :interactive
    require "etc"
    user = begin
      Etc.getpwuid(Process.uid).name
    rescue
      "unknown"
    end
    log_path "/tmp/rift_#{user}.out.log"
    error_log_path "/tmp/rift_#{user}.err.log"
  end

  test do
    assert_match "rift", shell_output("#{bin}/rift-cli --help")
  end
end
