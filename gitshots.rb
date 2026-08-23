# typed: false
# frozen_string_literal: true

class Gitshots < Formula
  desc "Webcam frame on every git commit, date-stamped like a 1993 point-and-shoot"
  homepage "https://github.com/wilbeibi/gitshots"
  url "https://github.com/wilbeibi/gitshots/archive/refs/tags/v0.1.2.tar.gz"
  sha256 "71326c3b89f07d191702fdae41672189ff72e66157fd63dc1b30d1f28434ed69"
  license "MIT"

  # Pillow and piexif are fetched by uv at first run, so there is no Python
  # dependency to declare here beyond uv itself.
  depends_on "uv"

  on_macos do
    depends_on "imagesnap"
  end

  def install
    # capture.sh finds fonts, LUTs, and the test card beside itself, so the
    # whole asset tree has to stay together in libexec.
    libexec.install "capture.sh", "annotate.py", "config", "fonts", "luts", "testcard"
    bin.install "bin/gitshots"
  end

  def caveats
    s = <<~EOS
      gitshots is installed but not yet wired to git. To claim git's global
      core.hooksPath and start taking frames:

        gitshots install

      Existing hooks are preserved and keep firing; `gitshots uninstall` puts
      them back. Frames land in ~/Pictures/gitshots/.
    EOS
    on_linux do
      s += <<~EOS

        For an actual photo on Linux, install fswebcam from your distro
        (it is not in homebrew-core). Without it every frame is a test card,
        which is a legitimate way to run gitshots.
      EOS
    end
    s
  end

  test do
    assert_match "gitshots #{version}", shell_output("#{bin}/gitshots version")

    # doctor exits nonzero when the hook is not wired, which is exactly the
    # state a fresh install is in, so only assert that it reports on itself.
    output = shell_output("#{bin}/gitshots doctor", 1)
    assert_match "gitshots #{version}", output
    assert_match "not installed", output

    # The asset tree must survive relocation into the Cellar.
    assert_path_exists libexec/"testcard/pm5544.png"
    assert_path_exists libexec/"fonts/DSEG7Classic-Bold.ttf"
  end
end
