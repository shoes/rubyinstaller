require 'rake'
require 'rake/clean'

namespace(:dependencies) do
  namespace(:winhttp) do
    # winhttp needs mingw and downloads
    package = Shoes::Winhttp
    directory package.target
    CLEAN.include(package.target)

    # Put files for the :download task
    dt = checkpoint(:winhttp, :download)
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
    et = checkpoint(:winhttp, :extract) do
      dt.prerequisites.each { |f|
        extract(File.join(RubyInstaller::ROOT, f), package.target)
      }
    end
    task :extract => [:extract_utils, :download, package.target, et]

    # winhttp needs some relocation of files ??
    pt = checkpoint(:winhttp, :prepare) do
      # no op
    end
    task :prepare => [:extract, pt]

    task :activate => [:prepare] do
      puts "Activating winhttp version #{package.version}"
      activate(package.target)
    end
  end
end

task :winhttp => [
  'dependencies:winhttp:download',
  'dependencies:winhttp:extract',
  'dependencies:winhttp:prepare',
  'dependencies:winhttp:activate'
]
