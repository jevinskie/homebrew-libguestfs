# ByteCellar Libguestfs

https://libguestfs.org/

## How do I install these formulae?

`brew install ByteCellar/libguestfs/libguestfs`

Or `brew tap ByteCellar/libguestfs` and then `brew install libguestfs`.

### Versions

#### `Manual install (only tested on apple m2)`

```bash
# install pre-requisit
brew install jansson ncurses yajl augeas macfuse hivex pcre2 ocaml ocaml-findlib

# prepare env
export CFLAGS='-I/opt/homebrew/opt/gettext/include -I/opt/homebrew/opt/readline/include -I/opt/homebrew/opt/libmagic/include -I/opt/homebrew/Cellar/pcre2/10.42/include'
export LDFLAGS='-L/opt/homebrew/opt/gettext/lib -L/opt/homebrew/opt/readline/lib -L/opt/homebrew/opt/libmagic/lib -L/opt/homebrew/Cellar/pcre2/10.42/lib'
export LIBS='-framework CoreFoundation'

export AUGEAS_CFLAGS='-I/opt/homebrew/opt/augeas/include'
export AUGEAS_LIBS='-L/opt/homebrew/opt/augeas/lib -laugeas -lfa'

export FUSE_CFLAGS='-D_FILE_OFFSET_BITS=64 -D_DARWIN_USE_64_BIT_INODE -I/usr/local/include/fuse'
export FUSE_LIBS='-L/usr/local/lib -lfuse -pthread -liconv'

export HIVEX_CFLAGS='-I/opt/homebrew/Cellar/hivex/1.3.23/include'
export HIVEX_LIBS='-L/opt/homebrew/Cellar/hivex/1.3.23/lib -lhivex'

export JANSSON_CFLAGS='-I/opt/homebrew/Cellar/jansson/2.14/include'
export JANSSON_LIBS='-L/opt/homebrew/Cellar/jansson/2.14/lib -ljansson'

export LIBTINFO_CFLAGS='-I/opt/homebrew/opt/ncurses/include'
export LIBTINFO_LIBS='-L/opt/homebrew/opt/ncurses/lib -lncurses'

export LIBVIRT_CFLAGS='-I/opt/homebrew/Cellar/libvirt/9.5.0/include'
export LIBVIRT_LIBS='-L/opt/homebrew/Cellar/libvirt/9.5.0/lib -lvirt-admin -lvirt-lxc -lvirt-qemu -lvirt'

export PCRE2_CFLAGS='-I/opt/homebrew/Cellar/pcre2/10.42/include'
export PCRE2_LIBS='-L/opt/homebrew/Cellar/pcre2/10.42/lib -lpcre2-8 -lpcre2-16 -lpcre2-32'

export YAJL_CFLAGS='-I/opt/homebrew/opt/yajl/include'
export YAJL_LIBS='-L/opt/homebrew/opt/yajl/lib -lyajl'

# configure
./configure --with-default-backend=libvirt --disable-appliance --disable-daemon --disable-ocaml --disable-lua --disable-haskell --disable-erlang --disable-gobject --disable-php --disable-perl --disable-golang --disable-python --disable-ruby --disable-dependency-tracking --disable-silent-rules --prefix=$PWD/output

# make && install
make 
REALLY_INSTALL=yes make install
```

## Documentation

`brew help`, `man brew` or check [Homebrew's documentation](https://docs.brew.sh).

## History

Originally based off of work done [amar1729's homebrew tap](https://github.com/amar1729/homebrew-libguestfs).
That tap has been updated to support `libguestfs 1.50.0` (current version as of summer 2023 is 1.51).

Building libguestfs inside Homebrew is a bit of a pain, due to differences in the macOS build as well as certain homebrew restrictions over time (e.g. removing the `osxfuse` formula in early 2021) so this tap will try to include previous versions of libguestfs as well as the current version (as `libguestfs.rb`).

other work:
https://listman.redhat.com/archives/libguestfs/2015-February/msg00040.html
