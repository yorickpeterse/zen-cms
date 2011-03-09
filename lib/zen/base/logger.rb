require 'ramaze/log/rotatinginformer'

module Zen
  ##
  # The Logger class acts as a small wrapper around the RotatingInformer class provided
  # by Ramaze. Before returning a new instance this logger will make sure the specified
  # directory actually exists and create it if this isn't the case.
  #
  # @author Yorick Peterse
  # @since  0.1
  # 
  class Logger < Ramaze::Logger::RotatingInformer

    trait :timestamp => Zen.options.date_format
    trait :format    => "[%time] %prefix  %text"
    
    ##
    # Create a new instance of the logging class. The first parameter is the directory 
    # in which the log files should be stored. Based on this paramater and the current 
    # mode (specified in Ramaze.options.mode) the required directories will be created. 
    # When specifying a directory you should NOT add trailing slash.
    #
    # @example
    #  # When running in :dev mode this will result in the log files being stored in 
    #  # logs/database/dev
    #  Zen::Logger.new 'logs/database'
    # 
    # @author Yorick Peterse
    # @since  0.1
    # @param  [String] log_dir The relative path to the log directory.
    # @return [Object]
    #
    def initialize log_dir
      # Create the log directory if it doesn't exist
      Dir.mkdir log_dir unless Dir.exist? log_dir
      
      log_dir += "/#{Ramaze.options.mode}"
      Dir.mkdir log_dir unless Dir.exist? log_dir
      
      # Initialize the RotatingInformer class
      super(log_dir, "#{Zen.options.date_format}.log")
    end
    
    ##
    # The write method is called whenever a log message has to be written to a file.
    #
    # @author Yorick Peterse
    # @since  0.1
    # @param  [String] message The data that has to be logged.
    #
    def write message
      self.log(:info, message)
    end
  end
end
