require File.expand_path('../lib/zen', __FILE__)

task_dir = File.expand_path('../lib/zen/task', __FILE__)

Dir.glob("#{task_dir}/*.rake").each do |f|
  import(f)
end
