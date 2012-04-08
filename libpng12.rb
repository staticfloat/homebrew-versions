require 'formula'

class Libpng12 < Formula
  homepage 'http://www.libpng.org/pub/png/libpng.html'
  url 'http://sourceforge.net/projects/libpng/files/libpng12/1.2.49/libpng-1.2.49.tar.gz/download'
  md5 '39a35257cd888d29f1d000c2ffcc79eb'

  keg_only "keg_only so that we don't conflict with OSX-installed libpng"

  def install
    system "./configure", "--disable-debug", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make install"
    system "make test"

    # Move included test programs into prefix/etc, for later running
    mkdir "#{prefix}/etc"
    mv "pngtest.png", "#{prefix}/etc"
    mv ".libs/pngtest", "#{prefix}/etc"
  end

  def test
    # run the included test
    system "#{prefix}/etc/pngtest", "#{prefix}/etc/pngtest.png"
  end
end
