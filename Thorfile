require File.expand_path('../lib/zen', __FILE__)
require 'thor'

task_dir = File.expand_path('../lib/zen/task', __FILE__)

Dir.glob("#{task_dir}/*.rb").each do |f|
  require(f)
end
