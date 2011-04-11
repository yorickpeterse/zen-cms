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

    end
  end
end
