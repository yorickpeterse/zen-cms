if ENV.key?('COVERAGE') and ENV['COVERAGE'] == 'true'
  require File.expand_path('../../lib/zen/spec/simplecov', __FILE__)
end

require File.expand_path('../../lib/zen', __FILE__)

Ramaze::Log.level   = Logger::ERROR
Ramaze.options.mode = :dev

Zen::Fixtures = __DIR__('fixtures/zen')
Zen.root      = __DIR__
Zen.database  = Sequel.connect(
  :adapter   => ENV['ADAPTER']  || 'sqlite',
  :database  => ENV['DATABASE'] || __DIR__('database.db'),
  :username  => ENV['USERNAME'],
  :password  => ENV['PASSWORD'],
  :test      => true,
  :encoding  => 'utf8'
)

Zen::Language.options.paths.push(__DIR__('fixtures/zen'))

Zen.start

# Load Capybara?
require __DIR__('../lib/zen/spec/helper') if !Zen.const_defined?(:RakeTask)
