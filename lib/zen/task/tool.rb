#:nodoc
module Zen
  #:nodoc:
  module Task
    ##
    # Thor task that contains a few useful commands that can be used when hacking with
    # Zen.
    #
    # @author Yorick Peterse
    # @since  0.2.5
    #
    class Tool < Thor
      include ::Thor::Actions

      namespace :tool

      desc 'syntax', 'Checks the syntax of all Ruby files'

      ##
      # Checks the syntax of all Ruby files.
      #
      # @author Yorick Peterse
      # @since  0.2.5
      #
      def syntax
        files   = Dir.glob("#{Dir.pwd}/**/*.rb")
        invalid = 0

        files.each do |file|
          output = run("ruby -c #{file}", :capture => true, :verbose => false).strip

          # Display the status
          if output != 'Syntax OK'
            invalid += 1
          end
        end

        say("\nFiles: #{files.count} | ")
        say("Invalid files: #{invalid.to_s}", :red)
      end

      desc 'env', 'Displays data about the current environment, platform, etc'

      ##
      # Task that when executed will display data about the current environment, Ruby
      # version and various other things.
      #
      # @author Yorick Peterse
      # @since  0.2.5
      #
      def env
        # Collect all basic data
        table_start = [['Name', 'Identifier'], ['-------', '-------']]
        vars        = {
          'Ruby version'  => "#{RUBY_VERSION}p#{RUBY_PATCHLEVEL}",
          'Ruby platform' => RUBY_PLATFORM.to_s,
          'Ruby engine'   => RUBY_ENGINE.to_s,
          'Zen version'   => Zen::Version.to_s,
          'Zen packages'  => table_start.dup,
          'Zen themes'    => table_start.dup,
          'Zen plugins'   => table_start.dup
        }

        # Create a list of all loaded packages
        if !Zen::Package.packages.nil?
          Zen::Package.packages.each do |ident, p|
            vars['Zen packages'].push([p.name, p.identifier])
          end
        end

        # Get a list of all loaded themes
        if !Zen::Theme.themes.nil?
          Zen::Theme.themes.each do |ident, p|
            vars['Zen themes'].push([p.name, p.identifier])
          end
        end

        # And get a list of all plugins while we're at it anyway
        if !Zen::Plugin.plugins.nil?
          Zen::Plugin.plugins.each do |ident, p|
            vars['Zen plugins'].push([p.name, p.identifier])
          end
        end

        # Display the results
        vars.each do |label, value|
          if value.class == String
            puts "#{label}: #{value}"
          else
            if value.count > 2
              puts "#{label}:"
              print_table(value)

              puts
            end
          end
        end
      end

    end
  end
end
