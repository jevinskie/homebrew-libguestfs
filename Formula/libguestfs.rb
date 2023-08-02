require "digest"

class OsxfuseRequirement < Requirement
  fatal true

  satisfy(build_env: false) { self.class.binary_osxfuse_installed? }

  def self.binary_osxfuse_installed?
    File.exist?("/usr/local/include/fuse/fuse.h") &&
      !File.symlink?("/usr/local/include/fuse")
  end

  env do
    unless HOMEBREW_PREFIX.to_s == "/usr/local"
      ENV.append_path "HOMEBREW_LIBRARY_PATHS", "/usr/local/lib"
      ENV.append_path "HOMEBREW_INCLUDE_PATHS", "/usr/local/include/fuse"
    end
  end

  def message
    "macFUSE is required to build libguestfs. Please run `brew install --cask macfuse` first."
  end
end

class Libguestfs < Formula
  desc "Set of tools for accessing and modifying virtual machine (VM) disk images"
  homepage "https://libguestfs.org/"
  url "https://github.com/ByteCellar/homebrew-libguestfs/releases/download/libguestfs-1.50.0/libguestfs-1.50.0.tar.gz"
  sha256 "9a4048255bc1681cea972f3ab37dc89849e82347845f43bf0a1d0124315146f5"

  bottle do
    root_url "https://github.com/ByteCellar/homebrew-libguestfs/releases/download/libguestfs-1.50.0/libguestfs-1.50.0.arm64_ventura.bottle.tar.gz"
    sha256 cellar: :any, arm64_ventura: "00e651bf1f15860f9203ffda1dd8122c69120ca81cb5a91f5fcc0bacf0265051"
  end

  depends_on "automake" => :build
  depends_on "autoconf" => :build
  depends_on "libtool" => :build
  depends_on "pkg-config" => :build
  depends_on "truncate" => :build
  depends_on "augeas"
  depends_on "cdrtools"
  depends_on "gettext"
  depends_on "glib"
  depends_on "hivex"
  depends_on "jansson"
  depends_on "libvirt"
  depends_on "ncurses"
  depends_on "ocaml"
  depends_on "ocaml-findlib"
  depends_on "pcre2"
  depends_on "qemu"
  depends_on "readline"
  depends_on "xz"
  depends_on "yajl"

  on_macos do
    depends_on OsxfuseRequirement => :build
  end

  # the linux support is a bit of a guess, since homebrew doesn't currently build bottles for libvirt
  # that means brew test-bot's --build-bottle will fail under ubuntu-latest runners
  on_linux do
    depends_on "libfuse"
  end

  # Since we can't build an appliance, the recommended way is to download a fixed one.
  resource "fixed_appliance" do
    url "file:///opt/homebrew/appliance-1.50.1.tar.xz"
    sha256 "32afe334eccf57fbce9fa03c753c3486dd2b5a7d63db1dd9005158d4584ab4c4"
  end

  #patch do
    # Change program_name to avoid collision with gnulib
    #url "https://gist.github.com/zchee/2845dac68b8d71b6c1f5/raw/ade1096e057711ab50cf0310ceb9a19e176577d2/libguestfs-gnulib.patch"
    #sha256 "b88e85895494d29e3a0f56ef23a90673660b61cc6fdf64ae7e5fecf79546fdd0"
  #end

  def install
    ENV["PATH"] = "/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/System/Cryptexes/App/usr/bin:/usr/bin:/bin:/usr/sbin:/sbin:/Applications/VMware Fusion.app/Contents/Public:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/local/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/appleinternal/bin"
    ENV["CFLAGS"] = "-I/opt/homebrew/opt/gettext/include -I/opt/homebrew/opt/readline/include -I/opt/homebrew/opt/libmagic/include -I/opt/homebrew/Cellar/pcre2/10.42/include"
    ENV["LDFLAGS"] = "-L/opt/homebrew/opt/gettext/lib -L/opt/homebrew/opt/readline/lib -L/opt/homebrew/opt/libmagic/lib -L/opt/homebrew/Cellar/pcre2/10.42/lib"
    ENV["LIBS"] = "-framework CoreFoundation"

    ENV["AUGEAS_CFLAGS"] = "-I/opt/homebrew/opt/augeas/include"
    ENV["AUGEAS_LIBS"] = "-L/opt/homebrew/opt/augeas/lib -laugeas -lfa"

    ENV["FUSE_CFLAGS"] = "-D_FILE_OFFSET_BITS=64 -D_DARWIN_USE_64_BIT_INODE -I/usr/local/include/fuse"
    ENV["FUSE_LIBS"] = "-L/usr/local/lib -lfuse -pthread -liconv"

    ENV["HIVEX_CFLAGS"] = "-I/opt/homebrew/Cellar/hivex/1.3.23/include"
    ENV["HIVEX_LIBS"] = "-L/opt/homebrew/Cellar/hivex/1.3.23/lib -lhivex"

    ENV["JANSSON_CFLAGS"] = "-I/opt/homebrew/Cellar/jansson/2.14/include"
    ENV["JANSSON_LIBS"] = "-L/opt/homebrew/Cellar/jansson/2.14/lib -ljansson"

    ENV["LIBTINFO_CFLAGS"] = "-I/opt/homebrew/opt/ncurses/include"
    ENV["LIBTINFO_LIBS"] = "-L/opt/homebrew/opt/ncurses/lib -lncurses"

    ENV["LIBVIRT_CFLAGS"] = "-I/opt/homebrew/Cellar/libvirt/9.5.0/include"
    ENV["LIBVIRT_LIBS"] = "-L/opt/homebrew/Cellar/libvirt/9.5.0/lib -lvirt-admin -lvirt-lxc -lvirt-qemu -lvirt"

    ENV["PCRE2_CFLAGS"] = "-I/opt/homebrew/Cellar/pcre2/10.42/include"
    ENV["PCRE2_LIBS"] = "-L/opt/homebrew/Cellar/pcre2/10.42/lib -lpcre2-8 -lpcre2-16 -lpcre2-32"

    ENV["YAJL_CFLAGS"] = "-I/opt/homebrew/opt/yajl/include"
    ENV["YAJL_LIBS"] = "-L/opt/homebrew/opt/yajl/lib -lyajl"

    args = [
      "--disable-appliance",
      "--disable-daemon",
      "--disable-ocaml",
      "--disable-lua",
      "--disable-haskell",
      "--disable-erlang",
      "--disable-gobject",
      "--disable-php",
      "--disable-perl",
      "--disable-golang",
      "--disable-python",
      "--disable-ruby",
    ]

    system "./configure", 
           "--with-default-backend=libvirt", 
           "--disable-dependency-tracking",
           "--disable-silent-rules",
           "--prefix=#{prefix}",
           *args

    system "make"

    ENV["REALLY_INSTALL"] = "yes"
    system "make", "install"

    libguestfs_path = "#{prefix}/var/libguestfs-appliance-1.50.1-arm64"
    mkdir_p libguestfs_path
    resource("fixed_appliance").stage(libguestfs_path)

    bin.install_symlink Dir["bin/*"]
  end

  def caveats
    <<~EOS
      A fixed appliance is required for libguestfs to work on Mac OS X.
      This formula downloads the appliance and places it in:
        #{prefix}/var/libguestfs-appliance-1.50.1-arm64

      To use the appliance, add the following to your shell configuration:
        export LIBGUESTFS_PATH=#{prefix}/var/libguestfs-appliance-1.50.1-arm64
      and use libguestfs binaries in the normal way.

      For compilers to find libguestfs you may need to set:
        export LDFLAGS="-L#{prefix}/lib"
        export CPPFLAGS="-I#{prefix}/include"

      For pkg-config to find libguestfs you may need to set:
        export PKG_CONFIG_PATH="#{prefix}/lib/pkgconfig"

    EOS
  end

  test do
    ENV["LIBGUESTFS_PATH"] = "#{prefix}/var/libguestfs-appliance-1.50.1-arm64"
    system "#{bin}/libguestfs-test-tool", "-t 180"
  end
end

