class RiftPlus < Formula
  desc "Tiling window manager for macOS (rift fork with extra patches)"
  homepage "https://github.com/ericwang401/rift"
  version "0.5.3-plus.1"
  # Interpolated so the release workflow only has to rewrite `version`.
  url "https://github.com/ericwang401/rift/releases/download/v#{version}/rift-plus-universal-macos-#{version}.tar.gz"
  sha256 "0000000000000000000000000000000000000000000000000000000000000000"
  license "Apache-2.0"

  # Only a --HEAD build compiles anything; release installs are a prebuilt
  # universal binary and must not drag in a Rust toolchain.
  head do
    url "https://github.com/ericwang401/rift.git", branch: "main"
    depends_on "rust" => :build
  end

  # No version floor. The one macOS 26 API in rift (NSGlassEffectView, behind
  # the opt-in drop overlay) is guarded at run time and degrades to no overlay,
  # so nothing here hard-requires Tahoe -- but that is also the only version
  # this fork is developed and tested against.

  # NOTE: this installs `rift` and `rift-cli` binaries and so collides with the
  # upstream `rift` formula in acsandmann/tap. As with yabai-plus we do NOT use
  # `conflicts_with`: naming a formula in another third-party tap makes
  # `brew info`/install try to auto-load that tap, which modern Homebrew
  # refuses. Homebrew's keg link-collision check covers this case instead.

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

  def caveats
    <<~EOS
      This is rift-plus, a fork of rift. It installs `rift` and `rift-cli` and
      conflicts with the upstream `rift` formula (acsandmann/tap).

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
      the `-arm64e_preview_abi` boot-arg. Once:
        sudo rift sa install-sudoers

      Then have rift re-inject it on every start -- it does not survive a reboot
      or a Dock restart -- in ~/.config/rift/config.toml:
        run_on_start = ["sudo rift sa load"]

      Check it with:
        rift sa status
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
