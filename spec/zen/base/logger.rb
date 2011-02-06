require File.expand_path '../../spec', __FILE__
require File.expand_path('../../../../lib/zen/base/logger', __FILE__)

log_dir = "#{Zen.options.root}/logs/spec"

describe Zen::Logger do

  it 'Initialize the Logger class' do
    logger = Zen::Logger.new log_dir
    
    # Validate the instance of the logger
    logger.should.respond_to? 'write'
    logger.should.respond_to? 'log'
  end
  
  it 'Create a basic log file' do
    logger = Zen::Logger.new log_dir
    
    # Validate the instance of the logger
    logger.should.respond_to? 'write'
    logger.should.respond_to? 'log'
    
    # Create the log file and check if it exists
    date = Time.new.strftime Zen.options.date_format
    logger.write 'Hello spec!'
    
    File.should.exist?(File.expand_path("#{log_dir}/spec/#{date}.log"))
    
    # Let's see if the log file actually contains the specified content
    log_file = File.open(File.expand_path("#{log_dir}/spec/#{date}.log"), 'r').read
    log_file.should.include? 'Hello spec!'
  end

end