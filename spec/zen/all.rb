require File.expand_path('../../helper', __FILE__)

tests = Dir.glob(__DIR__ + '/**/*.rb')

# Load and run all tests
tests.each do |t|
  if File.basename(t) != 'all.rb'
    require t
  end
end
