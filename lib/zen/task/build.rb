require 'fileutils'
require 'find'

module Zen
  module Task
    ##
    # The Build class/task can be used to create the documentation, manifest, etc.
    #
    # @author Yorick Peterse
    # @since  0.2
    #
    class Build < Thor
      include Thor::Actions

      namespace :build

      desc 'gem', 'Builds a new RubyGem'

      ##
      # Builds a new version of the RubyGem and places it in ./pkg
      #
      # @author Yorick Peterse
      # @since  0.2
      #
      def gem
        zen_path = File.expand_path('../../../../', __FILE__)

        # Build and install the gem
        run("gem build #{zen_path}/zen.gemspec")
        run("mv #{zen_path}/zen-#{Zen::Version}.gem #{zen_path}/pkg")
        run("gem install #{zen_path}/pkg/zen-#{Zen::Version}.gem")
      end

      desc 'gem_clean', 'Builds a new RubyGem and uninstalls any current versions of Zen'

      ##
      # Builds a new version of the RubyGem and uninstalls any current versions of Zen.
      #
      # @author Yorick Peterse
      # @since  0.2
      # 
      def gem_clean
        zen_path = File.expand_path('../../../../', __FILE__)

        begin
          run('gem uninstall zen')
        rescue
          puts "Failed to uninstall the gem, most likely it wasn't installed in the first place."
        end
        
        # Remove all logs files
        log_dirs = Dir.glob(zen_path + '/spec/zen/log/**/*')
        
        if !log_dirs.empty?
          log_dirs.each do |dir|
            # Ignore non-directory files
            if File.directory?(dir)
              FileUtils.rm_rf(dir)
            end
          end
        end
        
        self.gem
      end

      desc 'manifest', 'Builds the MANIFEST file'

      ##
      # Builds the MANIFEST file and places it in ./
      #
      # @author Yorick Peterse
      # @since  0.2
      # 
      def manifest
        zen_path = File.expand_path('../../../../', __FILE__)

        ignore_exts  = ['.gem', '.gemspec']
        ignore_files = ['.DS_Store', '.gitignore']
        ignore_dirs  = ['.git', '.yardoc', 'spec', 'pkg', 'doc']
        files        = ''
        
        Find.find(zen_path) do |f|
          f[zen_path] = ''
          f.gsub!(/^\//, '')

          # Ignore directories
          if !File.directory?(f) and !ignore_exts.include?(File.extname(f)) and !ignore_files.include?(File.basename(f))
            files  += "#{f}\n"
          else
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

      desc 'doc', 'Builds the documentation using YARD'

      ##
      # Builds the documentation using YARD.
      #
      # @author Yorick Peterse
      # @since  0.2
      #
      def doc
        zen_path = File.expand_path('../../../../', __FILE__)

        run("yard doc #{zen_path}/lib -m markdown -M rdiscount -o #{zen_path}/doc -r #{zen_path}/README.md")
      end 
    end
  end
end
