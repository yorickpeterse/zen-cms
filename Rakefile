require 'rubygems/package_task'

task_path = File.expand_path('../lib/zen/task', __FILE__)
tasks     = ['build', 'clean', 'proto', 'test', 'spelling']

tasks.each do |task|
  import File.join(task_path, "#{task}.rake")
end

Gem::PackageTask.new(Gem::Specification.load('zen.gemspec')) do |pkg|
  pkg.need_tar = false
  pkg.need_zip = false
end
