class Spek < Formula
  desc "Acoustic spectrum analyser"
  homepage "https://www.spek.cc"
  url "https://github.com/alexkay/spek/releases/download/v0.8.5/spek-0.8.5.tar.xz"
  sha256 "1bccf85a14a01af8f2f30476cbad004e8bf6031f500e562bbe5bbd1e5eb16c59"
  license "GPL-3.0-or-later"
  revision 9

  bottle do
    root_url "https://github.com/noelsorameso/intel-bottles/releases/download/bottles"
    sha256 cellar: :any, tahoe: "6c1b2c60b3708e5576835c140b046765b248208b99a55f643414439383548c29"
  end

  depends_on "gettext" => :build
  depends_on "pkgconf" => :build
  depends_on "ffmpeg"
  depends_on "wxwidgets"

  on_linux do
    depends_on "xorg-server" => :test
  end

  # Apply commit from open PR for FFmpeg 8 support similar to FreeBSD and NixOS.
  patch do
    url "https://github.com/alexkay/spek/commit/df8402575f1550d79c751051e9006fd3b7fa0fe0.patch?full_index=1"
    sha256 "1ec33c6a2c0dd6d445368e233a3c0855c4607af902e2ca5dd48b2472df7df797"
    type :unofficial
    resolves "https://github.com/alexkay/spek/pull/338"
  end

  deny_network_access!

  def install
    system "./configure", "--disable-silent-rules", *std_configure_args
    system "make", "install"
  end

  test do
    # Cannot run any useful test within macOS sandbox
    spek = bin/"spek"
    assert_path_exists spek
    return if OS.mac?

    IO.pipe do |read_io, write_io|
      pid = spawn(formula_opt_bin("xorg-server")/"Xvfb", "-displayfd", write_io.fileno.to_s, write_io => write_io)
      write_io.close
      ENV["DISPLAY"] = ":#{read_io.read.strip}"
      assert_match "Spek version #{version}", shell_output("#{spek} --version")
    ensure
      if pid
        Process.kill "TERM", pid
        Process.wait pid
      end
    end
  end
end
