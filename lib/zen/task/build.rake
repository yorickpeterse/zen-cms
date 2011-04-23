##
# Task group used for building various elements such as the Gem and the documentation.
#
# @author Yorick Peterse
# @since  0.2.5
#
namespace :build do

  desc 'Builds the documentation using YARD'
  task :doc do
    zen_path = File.expand_path('../../../../', __FILE__)
    command  = "yard doc #{zen_path}/lib -m markdown -M rdiscount -o #{zen_path}/doc "
    command += "-r #{zen_path}/README.md --private --protected "
    command += "--files #{zen_path}/license.txt,#{zen_path}/CHANGELOG.md,"
    command += "#{zen_path}/ROADMAP.md"

    sh(command)
  end

  desc 'Builds a new Gem'
  task :gem do
    zen_path = File.expand_path('../../../../', __FILE__)

    # Build and install the gem
    sh("gem build #{zen_path}/zen.gemspec")
    sh("mv #{zen_path}/zen-#{Zen::Version}.gem #{zen_path}/pkg")
    sh("gem install #{zen_path}/pkg/zen-#{Zen::Version}.gem")
  end

  desc 'Builds the MANIFEST file'
  task :manifest do
    zen_path     = File.expand_path('../../../../', __FILE__)
    ignore_exts  = ['.gem', '.gemspec']
    ignore_files = ['.DS_Store', '.gitignore']
    ignore_dirs  = ['.git', '.yardoc', 'spec', 'pkg', 'doc']
    files        = ''
    
    Find.find(zen_path) do |f|
      f[zen_path] = ''
      f.gsub!(/^\//, '')

      # Ignore directories
      if !File.directory?(f) and !ignore_exts.include?(File.extname(f)) and !ignore_files.include?(File.basename(f))
        files += "#{f}\n"
      else
        Find.prune if ignore_dirs.include?(f)
      end
    end
    
    # Time to write the MANIFEST file
    begin
      handle = File.open 'MANIFEST', 'w'
      handle.write files.strip
      puts "The MANIFEST file has been updated."
    rescue
      abort "The MANIFEST file could not be written."
    end
  end

end
