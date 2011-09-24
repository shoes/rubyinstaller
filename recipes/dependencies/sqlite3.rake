require 'rake'
require 'rake/clean'

namespace(:dependencies) do
  namespace(:sqlite3) do
    # sqlite3 needs mingw and downloads
    package = Shoes::Sqlite3
    directory package.target
    CLEAN.include(package.target)

    # Put files for the :download task
    dt = checkpoint(:sqlite3, :download)
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
    et = checkpoint(:sqlite3, :extract) do
      dt.prerequisites.each { |f|
        extract(File.join(RubyInstaller::ROOT, f), package.target)
      }
    end
    task :extract => [:extract_utils, :download, package.target, et]

    # sqlite3 needs some relocation of files ??
    pt = checkpoint(:sqlite3, :prepare) do
      # no op
    end
    task :prepare => [:extract, pt]
    
    task :link_dll => [:prepare] do
      sh "dlltool --dllname #{package.target}/sqlite3.dll --def #{package.target}/sqlite3.def --output-lib #{package.target}/sqlite3.lib"
    end

    task :activate => [:prepare] do
      puts "Activating sqlite3 version #{package.version}"
      activate(package.target)
    end
  end
end

task :sqlite3 => [
  'dependencies:sqlite3:download',
  'dependencies:sqlite3:extract',
  'dependencies:sqlite3:prepare',
  'dependencies:sqlite3:link_dll',
  'dependencies:sqlite3:activate'
]
