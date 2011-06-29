require File.expand_path('../../helper', __FILE__)

Dir.glob(__DIR__ + '/**/*.rb').each do |t|
  require(t) if File.basename(t) != 'all.rb'
end
