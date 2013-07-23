require 'formula'

class NanoRC < Formula
  homepage 'https://github.com/scopatz/nanorc'
  head 'https://github.com/scopatz/nanorc.git'
end

class Nano < Formula
  homepage 'http://www.nano-editor.org/'
  url 'http://www.nano-editor.org/dist/v2.2/nano-2.2.6.tar.gz'
  sha1 'f2a628394f8dda1b9f28c7e7b89ccb9a6dbd302a'

  depends_on "homebrew/dupes/ncurses"

  option 'color', 'Download and install nano syntax highlighting definition files'

  def install
    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--sysconfdir=#{etc}",
                          "--enable-color",
                          "--enable-extra",
                          "--enable-multibuffer",
                          "--enable-nanorc",
                          "--disable-nls",
                          "--enable-utf8"
    system "make install"

    # Install syntax highlighting files if the user wanted them
    NanoRC.new('nanorc').brew do
      # We don't want this one, we'll build our own in ${etc}/nanorc
      rm "import.nanorc"

      # list of default syntaxes to load
      defaults = ['c', 'cmake', 'conf', 'css', 'fortran', 'git', 'gitcommit', 'html', 'ini', 'java', 'javascript', 'lua', 'markdown', 'nanorc', 'objc', 'patch', 'perl', 'php', 'python', 'ruby', 'sh', 'tex', 'xml', 'yaml']

      open("#{etc}/nanorc", "w") do |rc|
        Dir['*.nanorc'].each do |file|
          cp file, "#{share}/nano/"
          hash = (defaults.include? File.basename(file, '.*')) ? "" : "#"
          rc << "#{hash}include \"#{share}/nano/#{file}\"\n"
        end
      end
    end if build.include? 'color'
  end

  def caveats
    output = ''
    if build.include? 'color'
      output << "A selection of syntax highlighting rules have been enabled by default.\n"
      output << "To customize them, edit the system-wide nanorc: #{etc}/nanorc"
    end
    return output
  end
end
