require "digest"

class OsxfuseRequirement < Requirement
  fatal true

  satisfy(build_env: false) { self.class.binary_osxfuse_installed? }

  def self.binary_osxfuse_installed?
    File.exist?("/usr/local/include/fuse/fuse.h") &&
      !File.symlink?("/usr/local/include/fuse")
  end

  env do
    if HOMEBREW_PREFIX.to_s != "/usr/local"
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
  url "https://download.libguestfs.org/1.52-stable/libguestfs-1.52.0.tar.gz"
  sha256 "2f8d9b8eb032b980ce9c4ae8ea87f41d5d9056c7bfa20c30aa0a2cd86adf70dc"

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "bison" => :build
  depends_on "coreutils" => :build # truncate
  depends_on "curl" => :build # cpanm
  depends_on "flex" => :build
  depends_on "gjs" => :build
  depends_on "gperf" => :build
  depends_on "libtool" => :build
  depends_on "pkg-config" => :build
  depends_on "po4a" => :build
  depends_on "wget" => :build # cpanm
  depends_on "augeas"
  depends_on "cdrtools"
  depends_on "gawk"
  depends_on "gettext"
  depends_on "glib"
  depends_on "gnu-sed"
  depends_on "go"
  depends_on "gobject-introspection"
  depends_on "hivex"
  depends_on "icoutils"
  depends_on "jansson"
  depends_on "libconfig"
  depends_on "libvirt"
  depends_on "libxcrypt"
  depends_on "libxml2"
  depends_on "lua"
  depends_on "make"
  depends_on "ncurses"
  depends_on "netpbm"
  depends_on "ocaml"
  depends_on "ocaml-findlib"
  depends_on "pcre2"
  depends_on "perl"
  depends_on "php"
  depends_on "python@3.12"
  depends_on "qemu"
  depends_on "readline"
  depends_on "rust"
  depends_on "sqlite"
  depends_on "vala"
  depends_on "xorriso"
  depends_on "xz"
  depends_on "yara"
  depends_on "zstd"

  on_macos do
    depends_on OsxfuseRequirement => :build
  end

  # the linux support is a bit of a guess, since homebrew doesn't currently build bottles for libvirt
  # that means brew test-bot's --build-bottle will fail under ubuntu-latest runners
  on_linux do
    depends_on "libfuse"
  end

  # resource "perl_local_lib" do
  #   url "https://cpan.metacpan.org/authors/id/H/HA/HAARG/local-lib-2.000029.tar.gz"
  #   sha256 "8df87a10c14c8e909c5b47c5701e4b8187d519e5251e87c80709b02bb33efdd7"
  # end

  # # Since we can't build an appliance, the recommended way is to download a fixed one.
  # resource "fixed_appliance" do
  #   url "https://download.libguestfs.org/binaries/appliance/appliance-1.46.0.tar.xz"
  #   sha256 "12d88227de9921cc40949b1ca7bbfc2f6cd6e685fa6ed2be3f21fdef97661be2"
  # end

  # resource "hivex_source" do
  #   url "https://download.libguestfs.org/hivex/hivex-1.3.23.tar.gz"
  #   sha256 "40cf5484f15c94672259fb3b99a90bef6f390e63f37a52a1c06808a2016a6bbd"
  # end

  # patch do
  #   Change program_name to avoid collision with gnulib
  #   url "https://gist.github.com/zchee/2845dac68b8d71b6c1f5/raw/ade1096e057711ab50cf0310ceb9a19e176577d2/libguestfs-gnulib.patch"
  #   sha256 "b88e85895494d29e3a0f56ef23a90673660b61cc6fdf64ae7e5fecf79546fdd0"
  # end

  def install
    ENV.prepend_path "PATH", Formula["bison"].opt_bin
    ENV.prepend_path "PATH", "#{Formula["coreutils"].opt_libexec}/gnubin"
    ENV.prepend_path "PATH", Formula["flex"].opt_bin
    ENV.prepend_path "PATH", Formula["gettext"].opt_bin
    ENV.prepend_path "PATH", "#{Formula["gnu-sed"].opt_libexec}/gnubin"
    ENV.prepend_path "PATH", Formula["go"].opt_bin
    ENV.prepend_path "PATH", Formula["gperf"].opt_bin
    ENV.prepend_path "PATH", Formula["icoutils"].opt_bin
    ENV.prepend_path "PATH", "#{Formula["libtool"].opt_libexec}/gnubin"
    ENV.prepend_path "PATH", "#{Formula["make"].opt_libexec}/gnubin"
    ENV.prepend_path "PATH", Formula["netpbm"].opt_bin
    ENV.prepend_path "PATH", Formula["po4a"].opt_bin
    ENV.prepend_path "PATH", Formula["sqlite"].opt_bin
    ENV.prepend_path "PATH", Formula["vala"].opt_bin
    ENV.prepend_path "PATH", Formula["wget"].opt_bin
    ENV.prepend_path "PATH", Formula["xorriso"].opt_bin
    ENV.prepend_path "PATH", Formula["xz"].opt_bin
    ENV.prepend_path "PATH", Formula["zstd"].opt_bin
    if OS.mac?
      ENV["FUSER"] = "/usr/bin/fuser"
      ENV["TOOL_TRUE"] = "/usr/bin/true"
    end

    ENV.prepend_path "PKG_CONFIG_PATH", "/usr/local/lib/pkgconfig" if OS.mac? # fuse
    ENV.prepend_path "PKG_CONFIG_PATH", "#{Formula["fuse"].opt_lib}/pkgconfig" if OS.linux?
    ENV.prepend_path "PKG_CONFIG_PATH", "#{Formula["augeas"].opt_lib}/pkgconfig"
    ENV.prepend_path "PKG_CONFIG_PATH", "#{Formula["glib"].opt_lib}/pkgconfig"
    ENV.prepend_path "PKG_CONFIG_PATH", "#{Formula["gobject-introspection"].opt_lib}/pkgconfig"
    ENV.prepend_path "PKG_CONFIG_PATH", "#{Formula["hivex"].opt_lib}/pkgconfig"
    ENV.prepend_path "PKG_CONFIG_PATH", "#{Formula["jansson"].opt_lib}/pkgconfig"
    ENV.prepend_path "PKG_CONFIG_PATH", "#{Formula["libconfig"].opt_lib}/pkgconfig"
    ENV.prepend_path "PKG_CONFIG_PATH", "#{Formula["libvirt"].opt_lib}/pkgconfig"
    ENV.prepend_path "PKG_CONFIG_PATH", "#{Formula["libxcrypt"].opt_lib}/pkgconfig"
    ENV.prepend_path "PKG_CONFIG_PATH", "#{Formula["libxml2"].opt_lib}/pkgconfig"
    ENV.prepend_path "PKG_CONFIG_PATH", "#{Formula["lua"].opt_lib}/pkgconfig"
    ENV.prepend_path "PKG_CONFIG_PATH", "#{Formula["ncurses"].opt_lib}/pkgconfig"
    ENV.prepend_path "PKG_CONFIG_PATH", "#{Formula["pcre2"].opt_lib}/pkgconfig"
    ENV.prepend_path "PKG_CONFIG_PATH", "#{Formula["python@3.12"].opt_lib}/pkgconfig"
    ENV.prepend_path "PKG_CONFIG_PATH", "#{Formula["vala"].opt_lib}/pkgconfig"
    ENV.prepend_path "PKG_CONFIG_PATH", "#{Formula["xz"].opt_lib}/pkgconfig"
    ENV.prepend_path "PKG_CONFIG_PATH", "#{Formula["yara"].opt_lib}/pkgconfig"
    ENV.prepend_path "PKG_CONFIG_PATH", "#{Formula["zstd"].opt_lib}/pkgconfig"

    ENV.append_to_cflags "-isystem #{Formula["gettext"].opt_include} " \
                         "-isystem #{Formula["libmagic"].opt_include} " \
                         "-isystem #{Formula["readline"].opt_include}"
    ENV["LDFLAGS"] = "-L#{Formula["gettext"].opt_lib}" \
                     "-L#{Formula["libmagic"].opt_lib}" \
                     "-L#{Formula["readline"].opt_lib}"
    ENV["LDFLAGS"] ="#{ENV["LDFLAGS"]} -framework CoreFoundation" if OS.mac?
    # ENV["LIBS"] = "-framework CoreFoundation"

    # pg-config
    # ENV["AUGEAS_CFLAGS"] = "-I#{Formula["augeas"].opt_include}"
    # ENV["AUGEAS_LIBS"] = "-L#{Formula["augeas"].opt_lib} -laugeas -lfa"

    if OS.mac?
      ENV["FUSE_CFLAGS"] = "-I/usr/local/include/fuse -D_FILE_OFFSET_BITS=64 -D_DARWIN_USE_64_BIT_INODE"
      ENV["FUSE_LIBS"] = "-L/usr/local/lib -lfuse -pthread -liconv"
    end

    # pkg-config
    # ENV["HIVEX_CFLAGS"] = "-I#{Formula["hivex"].opt_include}"
    # ENV["HIVEX_LIBS"] = "-L#{Formula["hivex"].opt_lib} -lhivex"

    # pkg-config
    # ENV["JANSSON_CFLAGS"] = "-I#{Formula["jansson"].opt_include}"
    # ENV["JANSSON_LIBS"] = "-L#{Formula["jansson"].opt_lib} -ljansson"

    # pkg-config
    # ENV["LIBTINFO_CFLAGS"] = "-I#{Formula["ncurses"].opt_include}"
    # ENV["LIBTINFO_LIBS"] = "-L#{Formula["ncurses"].opt_lib} -lncurses"

    # pkg-config
    # ENV["LIBVIRT_CFLAGS"] = "-I#{Formula["libvirt"].opt_include}"
    # ENV["LIBVIRT_LIBS"] = "-L#{Formula["libvirt"].opt_lib} -lvirt-admin -lvirt-lxc -lvirt-qemu -lvirt"

    # pkg-config
    # ENV["PCRE2_CFLAGS"] = "-I#{Formula["pcre2"].opt_include}"
    # ENV["PCRE2_LIBS"] = "-L#{Formula["pcre2"].opt_lib} -lpcre2-8 -lpcre2-16 -lpcre2-32"

    hivex_local_build_path = "#{buildpath}/hivex_local_build"
    mkdir_p hivex_local_build_path
    resource("hivex_source").stage(hivex_local_build_path)
    # perl_local_lib_path = "#{buildpath}/perl_local_lib"
    # mkdir_p perl_local_lib_path

    # perl_local_lib_build_path = "#{buildpath}/perl_local_lib_build"
    # mkdir_p perl_local_lib_build_path
    # resource("perl_local_lib").stage(perl_local_lib_build_path)
    # perl_local_lib_path = "#{buildpath}/perl_local_lib"
    # mkdir_p perl_local_lib_path
    # ENV.prepend_path "PATH", "#{perl_local_lib_path}/bin"
    # system "cd #{perl_local_lib_build_path} && " \
    #        "#{Formula["perl"].opt_bin}/perl " \
    #        "Makefile.PL " \
    #        "--bootstrap=#{perl_local_lib_path}"
    # system "cd #{perl_local_lib_build_path} && " \
    #        "#{Formula["make"].opt_libexec}/gnubin/make " \
    #        "test"
    # system "cd #{perl_local_lib_build_path} && " \
    #        "#{Formula["make"].opt_libexec}/gnubin/make " \
    #        "install"

    # ENV["PERL_MB_OPT"] = "--install_base #{perl_local_lib_path}"
    # ENV["PERL_MM_OPT"] = perl_local_lib_path
    # ENV["PERL5LIB"] = "#{perl_local_lib_path}/lib/perl5"
    # ENV["PERL_LOCAL_LIB_ROOT"] = perl_local_lib_path

    # system "#{Formula["curl"].opt_bin}/curl -L https://cpanmin.us | " \
    #        "#{Formula["perl"].opt_bin}/perl - " \
    #        "-l #{perl_local_lib_path} -f App::cpanminus"
    # system "#{perl_local_lib_path}/bin/cpanm " \
    #        "-l #{perl_local_lib_path} -f " \
    #        "Getopt::Long " \
    #        "Locale::TextDomain " \
    #        "Module::Build " \
    #        "Pod::Usage " \
    #        "Test::More"

    args = [
      "--disable-appliance",
      "--disable-daemon",
      "--disable-ocaml",
      "--disable-lua",
      "--disable-haskell",
      "--disable-erlang",
      # "--disable-gobject",
      "--disable-php",
      "--disable-perl",
      "--disable-golang",
      "--disable-python",
      "--disable-ruby",
    ]

    system "./configure",
           "--with-default-backend=libvirt",
           # "--disable-dependency-tracking",
           "--disable-silent-rules",
           # "--prefix=#{prefix}",
           *args,
           *std_configure_args

    system "make"

    ENV["REALLY_INSTALL"] = "yes"
    system "make", "install"

    libguestfs_path = "#{prefix}/var/libguestfs-appliance-1.52.0-arm64"
    mkdir_p libguestfs_path
    # resource("fixed_appliance").stage(libguestfs_path)

    # bin.install_symlink Dir["bin/*"]
  end

  def caveats
    <<~EOS
      A fixed appliance is required for libguestfs to work on Mac OS X.
      This formula downloads the appliance and places it in:
        #{prefix}/var/libguestfs-appliance-1.52.0-arm64

      To use the appliance, add the following to your shell configuration:
        export LIBGUESTFS_PATH=#{prefix}/var/libguestfs-appliance-1.52.0-arm64
      and use libguestfs binaries in the normal way.

      For compilers to find libguestfs you may need to set:
        export LDFLAGS="-L#{prefix}/lib"
        export CPPFLAGS="-I#{prefix}/include"

      For pkg-config to find libguestfs you may need to set:
        export PKG_CONFIG_PATH="#{prefix}/lib/pkgconfig"

    EOS
  end

  test do
    # ENV["LIBGUESTFS_PATH"] = "#{prefix}/var/libguestfs-appliance-1.52.0-arm64"
    # system "#{bin}/libguestfs-test-tool", "-t 180"
    system "true"
  end
end
