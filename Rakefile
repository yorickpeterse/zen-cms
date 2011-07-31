require File.expand_path('../lib/zen', __FILE__)

GEMSPEC = Gem::Specification::load(__DIR__('zen.gemspec'))

# Load all tasks
Dir.glob(File.expand_path('../lib/zen/task/*.rake', __FILE__)).each do |f|
  import(f)
end
