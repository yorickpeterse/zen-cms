require File.expand_path('../lib/zen', __FILE__)

module Zen
  Gemspec = Gem::Specification::load(__DIR__('zen.gemspec'))
end

# Load all tasks
Dir.glob(File.expand_path('../lib/zen/task/*.rake', __FILE__)).each do |f|
  import(f)
end
