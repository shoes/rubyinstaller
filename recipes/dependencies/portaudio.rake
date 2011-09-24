require 'rake'
require 'rake/clean'

namespace(:dependencies) do
  namespace(:portaudio) do
    # portaudio needs mingw and downloads
    package = Shoes::PortAudio
    directory package.target
    CLEAN.include(package.target)

    # Put files for the :download task
    dt = checkpoint(:portaudio, :download)
    package.files.each do |f|
      file_source = "#{package.url}/#{f}"
      file_target = "downloads/#{f}"
      download file_target => file_source

      # depend on downloads directory
      file file_target => "downloads"

      # download task need these files as pre-requisites
      dt.enhance [file_target]
    end
    task :download => dt

    # Prepare the :sandbox, it requires the :download task
    et = checkpoint(:portaudio, :extract) do
      dt.prerequisites.each { |f|
        extract(File.join(RubyInstaller::ROOT, f), package.target)
      }
    end
    task :extract => [:extract_utils, :download, package.target, et]

    # portaudio needs some relocation of files... unlike every other
    # dependency, this one puts its files into
    # package.target/portaudio instead of plain 'ol package.target;
    # to make it more like everyone else, the prepare step should
    # move those files up one directory level and delete the
    # portaudio subdir
    pt = checkpoint(:portaudio, :prepare) do
      cd File.join(RubyInstaller::ROOT, package.target) do
        subdir_files = File.join('portaudio', '*')

        # can't get these two lines to work
        # to test configure & compile too, make sure to uncomment
        # the lines at the very bottom of this file
        #mv subdir_files, '.'
        #rm_rf "portaudio"
      end
    end
    task :prepare => [:extract, pt]

    # Prepare sources for compilation
    ct = checkpoint(:portaudio, :configure) do
      install_target = File.join(RubyInstaller::ROOT, package.install_target)
      cd package.target do
        sh "sh -c \"./configure --prefix=#{install_target}\""
      end
    end
    task :configure => [:prepare, :compiler, ct]

    mt = checkpoint(:portaudio, :make) do
      cd package.target do
        sh "make"
      end
    end
    task :compile => [:configure, mt]

    it = checkpoint(:portaudio, :install) do
      cd package.target do
        sh "make install"
      end
    end
    task :install => [:compile, it]

    task :activate => [:prepare] do
      puts "Activating portaudio version #{package.version}"
      activate(package.target)
    end
  end
end

task :portaudio => [
  'dependencies:portaudio:download',
  'dependencies:portaudio:extract',
  'dependencies:portaudio:prepare',
#  'dependencies:portaudio:configure',
#  'dependencies:portaudio:compile',
#  'dependencies:portaudio:install',
  'dependencies:portaudio:activate'
]
