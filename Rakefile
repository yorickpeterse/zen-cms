require 'rubygems'
require File.expand_path('../lib/zen', __FILE__)

Zen::Gemspec = Gem::Specification::load(__DIR__('zen.gemspec'))

Dir.glob(__DIR__('lib/zen/task/*.rake')).each do |task|
  import task
end
