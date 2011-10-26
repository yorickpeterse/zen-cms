if ENV.key?('COVERAGE') and ENV['COVERAGE'] == 'true'
  require File.expand_path('../../lib/zen/spec/simplecov', __FILE__)
end

require File.expand_path('../../lib/zen', __FILE__)

Ramaze.setup(:verbose => false) do
  gem 'sqlite3'  , ['>= 1.3.4']
  gem 'rdiscount', ['>= 1.6.8']
  gem 'defensio' , ['>= 0.9.1']
end

Ramaze::Log.level   = Logger::ERROR
Ramaze.options.mode = :dev

Zen::Fixtures = __DIR__('fixtures/zen')
Zen.root      = __DIR__
Zen.database  = Sequel.connect(
  :adapter   => 'sqlite',
  :database  => __DIR__('database.db'),
  :test      => true,
  :encoding  => 'utf8'
)

Zen::Language.options.paths.push(__DIR__('fixtures/zen'))

Zen.start

# Load Capybara?
require __DIR__('../lib/zen/spec/helper') if !Zen.const_defined?(:RakeTask)
