require 'formula'

class Clang < Formula
  homepage  'http://llvm.org/'
  url       'http://llvm.org/releases/3.2/clang-3.2.src.tar.gz'
  sha1      'b0515298c4088aa294edc08806bd671f8819f870'

  head      'http://llvm.org/git/clang.git'
end

class CompilerRt < Formula
  homepage  'http://llvm.org/'
  url       'http://llvm.org/releases/3.2/compiler-rt-3.2.src.tar.gz'
  sha1      '718c0249a00e928f8bba32c84771da998ea4d42f'

  head      'http://llvm.org/git/compiler-rt.git'
end

class Llvm32 < Formula
  homepage  'http://llvm.org/'
  url       'http://llvm.org/releases/3.2/llvm-3.2.src.tar.gz'
  sha1      '42d139ab4c9f0c539c60f5ac07486e9d30fc1280'

  head      'http://llvm.org/git/llvm.git'

  keg_only "Conflicts with llvm in mainline homebrew"

  bottle do
    revision 2
    sha1 'beec50e270e10df5a8286919d1a7a18e7e21146b' => :lion
    sha1 'e1570f49b4c31efbc8dbaac0134a84677ee47a1c' => :snow_leopard
    sha1 '5f61eb469603f59d354d0eb1a95990fb44f12f56' => :mountain_lion
  end

  option :universal
  option 'with-clang', 'Build Clang C/ObjC/C++ frontend'
  option 'with-asan', 'Include support for -faddress-sanitizer (from compiler-rt)'
  option 'disable-shared', "Don't build LLVM as a shared library"
  option 'all-targets', 'Build all target backends'
  option 'rtti', 'Build with C++ RTTI'
  option 'disable-assertions', 'Speeds up LLVM, but provides less debug information'

  depends_on :python => :recommended

  env :std if build.universal?

  def install
    if build.with? 'python' and build.include? 'disable-shared'
      raise 'The Python bindings need the shared library.'
    end

    Clang.new("clang").brew do
      clang_dir.install Dir['*']
    end if build.include? 'with-clang'

    CompilerRt.new("compiler-rt").brew do
      (buildpath/'projects/compiler-rt').install Dir['*']
    end if build.include? 'with-asan'

    if build.universal?
      ENV['UNIVERSAL'] = '1'
      ENV['UNIVERSAL_ARCH'] = 'i386 x86_64'
    end

    ENV['REQUIRES_RTTI'] = '1' if build.include? 'rtti'

    args = [
      "--prefix=#{prefix}",
      "--enable-optimized",
      # As of LLVM 3.1, attempting to build ocaml bindings with Homebrew's
      # OCaml 3.12.1 results in errors.
      "--disable-bindings",
    ]

    if build.include? 'all-targets'
      args << "--enable-targets=all"
    else
      args << "--enable-targets=host"
    end
    args << "--enable-shared" unless build.include? 'disable-shared'

    args << "--disable-assertions" if build.include? 'disable-assertions'

    system "./configure", *args
    system "make install"

    # install llvm python bindings
    if python
      unless build.head?
        inreplace buildpath/'bindings/python/llvm/common.py', 'LLVM-3.1svn', "libLLVM-#{version}svn"
      end
      python.site_packages.install buildpath/'bindings/python/llvm'
    end

    # install clang tools and bindings
    cd clang_dir do
      system 'make install'
      (share/'clang/tools').install 'tools/scan-build', 'tools/scan-view'
      python.site_packages.install 'bindings/python/clang' if python
    end if build.include? 'with-clang'
  end

  def test
    system "#{bin}/llvm-config", "--version"
  end

  def caveats
    s = ''
    s += python.standard_caveats if python
    s += <<-EOS.undent
      Extra tools are installed in #{share}/llvm and #{share}/clang.
    EOS
  end

  def clang_dir
    buildpath/'tools/clang'
  end
end
