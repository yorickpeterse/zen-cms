require 'fileutils'

desc "Removes non-required files such as log files."
task :clean do
  
  # Remove all log files
  puts "Cleaning log files..."
  log_files = Dir.glob(__DIR__('../spec/zen/logs/**/**/*.log'))
  log_files.each { |file| File.unlink(file) }
  
  # Remove the documentation files. They're not required
  # for developing/hacking with Zen and can be generated manually
  puts "Cleaning YARD files..."
  FileUtils.rm_rf(__DIR__('../doc'))
  FileUtils.rm_rf(__DIR__('../.yardoc'))
  
  puts "And done!"
end
