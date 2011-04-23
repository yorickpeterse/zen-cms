require 'fileutils'

##
# Task group used to remove various files that aren't needed when releasing gems and such.
#
# @author Yorick Peterse
# @since  0.2.5
#
namespace :clean do

  desc 'Removes all log files'
  task :log do
    zen_path = File.expand_path('../../../../', __FILE__)

    log_files = Dir.glob("#{zen_path}/spec/log/**/*.log")
    log_files.each { |file| File.unlink(file) }
  end

  desc 'Removes all YARD files'
  task :yard do
    zen_path = File.expand_path('../../../../', __FILE__)

    FileUtils.rm_rf("#{zen_path}/doc")
    FileUtils.rm_rf("#{zen_path}/.yardoc")
  end

end
