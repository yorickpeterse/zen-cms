require 'rubygems'

Zen::Gemspec = Gem::Specification::load(
  File.expand_path('../zen.gemspec', __FILE__)
)

Dir.glob(File.expand_path('../lib/zen/task/*.rake', __FILE__)).each do |task|
  import(task)
end
