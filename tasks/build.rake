require 'fileutils'
require 'find'

namespace :build do
  
  desc 'Build and install a new version of the Gem.'
  task :gem do
    # Get the root directory
    zen_path = File.expand_path('../../', __FILE__)
    
    # Build and install the gem
    sh "gem build #{zen_path}/zen.gemspec"
    sh "mv #{zen_path}/zen-#{Zen::Version}.gem #{zen_path}/pkg"
    sh "gem install #{zen_path}/pkg/zen-#{Zen::Version}.gem"
  end
  
  desc 'Remove all non-required files and install a new version of the gem.'
  task :gem_clean do
    begin
      sh 'gem uninstall zen'
    rescue
      puts "Failed to uninstall the gem, most likely it wasn't installed in the first place."
    end
    
    # Remove all logs files
    log_dirs = Dir.glob(File.expand_path('../../spec/zen/logs/', __FILE__) + '*/*')
    
    if !log_dirs.empty?
      log_dirs.each do |dir|
        # Ignore non-directory files
        if File.directory?(dir)
          FileUtils.rm_rf(dir)
        end
      end
    end
    
    Rake::Task["build:normal"].invoke
  end

  desc 'Build the MANIFEST file.'
  task :manifest do
  
    ignore_exts  = ['.gem', '.gemspec']
    ignore_files = ['.DS_Store', '.gitignore']
    ignore_dirs  = ['.git', '.yardoc', 'spec/zen/logs/common', 'spec/zen/logs/server',
                    'spec/zen/logs/database', 'spec/zen/logs/spec']
    files        = String.new
    
    Find.find './' do |f|
      # Ignore directories
      if !File.directory?(f) and !ignore_exts.include?(File.extname(f)) and !ignore_files.include?(File.basename(f))
        # Remove the ./ at the front of each filepath
        f['./'] = ''
        files  += "#{f}\n"
      else
        # Get rid of the ./ prefix and prune the current directory tree if it's excluded.
        f['./'] = ''
        Find.prune if ignore_dirs.include?(f)
      end
    end
    
    # Time to write the MANIFEST file
    begin
      handle = File.open 'MANIFEST', 'w'
      handle.write files.strip
      abort "The MANIFEST file has been updated."
    rescue
      abort "The MANIFEST file could not be written."
    end
  
  end
end
