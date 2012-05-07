require File.expand_path('../../helper', __FILE__)

puts "# Ruby version: #{RUBY_VERSION}p#{RUBY_PATCHLEVEL}"
puts "# Database adapter: #{Zen.database.adapter_scheme}"
puts "# Database: #{ENV['DATABASE'] || 'SQLite3'}"

Dir.glob(__DIR__ + '/**/*.rb').each do |t|
  require(t) if File.basename(t) != 'all.rb'
end
