require_relative('../helper')

tests = Dir.glob(__DIR__ + '/**/*.rb')

# Load and run all tests
tests.each do |t|
  if File.basename(t) != 'all.rb'
    require t
  end
end
