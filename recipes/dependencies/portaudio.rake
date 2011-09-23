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

    # portaudio needs some relocation of files ??
    pt = checkpoint(:portaudio, :prepare) do
      # no op
    end
    task :prepare => [:extract, pt]

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
  'dependencies:portaudio:activate'
]
