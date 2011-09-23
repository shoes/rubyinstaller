require 'rake'
require 'rake/clean'
require 'pathname'

namespace(:interpreter) do
  namespace(:shoes) do
    package = Shoes::Shoes
    directory package.build_target
    directory package.install_target
    CLEAN.include(package.target)
    CLEAN.include(package.build_target)
    CLEAN.include(package.install_target)

    # Put files for the :download task
    package.files.each do |f|
      file_source = "#{package.url}/#{f}"
      file_target = "downloads/#{f}"
      download file_target => file_source

      # depend on downloads directory
      file file_target => "downloads"

      # download task need these files as pre-requisites
      task :download => file_target
    end

    task :checkout => "downloads" do
      # If is there already a checkout, update instead of checkout"
      if File.exist?(File.join(RubyInstaller::ROOT, package.checkout_target, '.git'))
        cd File.join(RubyInstaller::ROOT, package.checkout_target) do
          sh "git pull"
        end
      else
        cd RubyInstaller::ROOT do
          sh "git clone #{package.checkout} #{package.checkout_target}"
        end
      end
    end

    task :sources do
        Rake::Task['interpreter:shoes:checkout'].invoke
    end

    task :extract => [:extract_utils] do
      package.target = File.expand_path(package.checkout_target)
    end
    
    task :prepare => [package.build_target] do
      # no op
    end
    
    task :dependencies => package.dependencies
    
    task :configure => [package.build_target, :compiler, :dependencies] do
      # no op?
    end

    task :compile => [:configure, :compiler, :dependencies] do
      cd package.build_target do
        sh "rake"
      end
    end

    task :clean do
      rm_rf package.build_target
      rm_rf package.install_target
    end

  end # shoes namespace
end # interpreter namespace

desc "compile Shoes"
task :shoes => [
  'interpreter:shoes:sources',
  'interpreter:shoes:extract',
  'interpreter:shoes:prepare',
  'interpreter:shoes:configure',
#  'interpreter:shoes:compile',
#  'interpreter:shoes:install'
]

namespace :shoes do
  task :dependencies => ['interpreter:shoes:dependencies']
  task :clean => ['interpreter:shoes:clean']
end
