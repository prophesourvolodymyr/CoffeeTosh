class Coffeetosh < Formula
  desc "Mac session manager – Lid Closed mode, Keep Awake timer, and system daemon"
  homepage "https://github.com/prophesourvolodymyr/CoffeeTosh"
  url "https://github.com/prophesourvolodymyr/CoffeeTosh/releases/download/v1.2.0/Coffeetosh-v1.2.0-macos.tar.gz"
  sha256 "abfb07332c844539edaea13de1848fdd984a3202873e708aaa0646f77f1009dc"
  license "MIT"
  version "1.2.0"

  # macOS 13 Ventura or newer required
  depends_on :macos => :ventura

  def install
    # CLI binary — available as `coffeetosh` in PATH
    bin.install "coffeetosh"

    # Daemon + cleanup — live in libexec, not directly in PATH
    libexec.install "coffeetosh-daemon"
    libexec.install "coffeetosh-cleanup"

    # Plist templates (brew services uses the service block below;
    # these are kept as reference for manual launchctl installs)
    (share/"coffeetosh").install "Resources/com.coffeetosh.daemon.plist"
    (share/"coffeetosh").install "Resources/com.coffeetosh.cleanup.plist"
  end

  # `brew services start coffeetosh` — runs daemon at login
  service do
    run        [opt_libexec/"coffeetosh-daemon"]
    keep_alive true
    log_path        var/"log/coffeetosh-daemon.log"
    error_log_path  var/"log/coffeetosh-daemon.log"
  end

  def caveats
    <<~EOS
      To start the daemon now and at every login:
        brew services start coffeetosh

      CLI usage:
        coffeetosh start 8                   # Lid Closed, 8 hours
        coffeetosh start 2 --mode keep-awake # Keep Awake, 2 hours
        coffeetosh status
        coffeetosh stop
        coffeetosh battery
        coffeetosh mac-temp

      For the menu bar app, download Coffeetosh.app from:
        https://github.com/prophesourvolodymyr/CoffeeTosh/releases
    EOS
  end

  test do
    system "#{bin}/coffeetosh", "help"
  end
end
