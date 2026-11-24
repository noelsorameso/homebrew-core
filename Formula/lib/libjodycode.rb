class Libjodycode < Formula
  desc "Shared code used by several utilities written by Jody Bruchon"
  homepage "https://codeberg.org/jbruchon/libjodycode"
  url "https://codeberg.org/jbruchon/libjodycode/archive/v4.2.tar.gz"
  sha256 "eeb54fc50b9ebec4e43c954704e69f56c104fede67aaee9f375fbecbb87933b0"
  license "MIT"
  compatibility_version 1

  livecheck do
    url "https://codeberg.org/api/v1/repos/jbruchon/libjodycode/releases"
    strategy :json do |json|
      json.filter_map { |tag| tag["tag_name"]&.delete_prefix("v") }
    end
  end

  bottle do
    root_url "https://github.com/noelsorameso/intel-bottles/releases/download/bottles"
    sha256 cellar: :any, tahoe: "1bab91b516eb3b9dc2530293a5ddcba9d608de5669a2aa44c484d6bc128ecf29"
  end

  # These files used to be distributed as part of the jdupes formula
  link_overwrite "include/libjodycode.h", "share/man/man7/libjodycode.7", "lib/libjodycode.a"

  deny_network_access!

  def install
    system "make"
    system "make", "install", "PREFIX=#{prefix}"
  end

  test do
    (testpath/"test.c").write <<~C
      #include <stdio.h>
      #include <libjodycode.h>

      int main() {
          int a = jc_strncaseeq("foo", "FOO", 3);
          int b = jc_strncaseeq("foo", "bar", 3);
          int c = jc_strneq("foo", "foo", 3);
          int d = jc_strneq("foo", "FOO", 3);
          printf("%d\\n%d\\n%d\\n%d", a, b, c, d);
      }
    C
    system ENV.cc, "test.c", "-I#{include}", "-L#{lib}", "-ljodycode", "-o", "test"
    assert_equal [0, 1, 0, 1], shell_output("./test").lines.map(&:to_i)
  end
end
