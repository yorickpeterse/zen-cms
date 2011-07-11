require File.expand_path('../lib/zen/version', __FILE__)

# Get all the files from the manifest
path = File.expand_path('../', __FILE__)

Gem::Specification.new do |s|
  s.name        = 'zen'
  s.version     = Zen::Version
  s.date        = '01-06-2011'
  s.authors     = ['Yorick Peterse']
  s.email       = 'info@yorickpeterse.com'
  s.summary     = 'Zen is a modular CMS written using Ramaze.'
  s.homepage    = 'http://zen-cms.com/'
  s.description = 'Zen is a modular CMS written using Ramaze. Unlike traditional 
CMS\' you are completely free to build whatever you want.'

  s.files       = `cd #{path}; git ls-files`.split("\n").sort
  s.has_rdoc    = 'yard'
  s.executables = ['zen']
  
  # The following gems are *always* required 
  s.add_dependency('sequel'          , ['~> 3.25'])
  s.add_dependency('ramaze'          , ['~> 2011.01.30'])
  s.add_dependency('bcrypt-ruby'     , ['~> 2.1.4'])
  s.add_dependency('sequel_sluggable', ['~> 0.0.6'])
  s.add_dependency('rake'            , ['~> 0.9.2'])
  s.add_dependency('loofah'          , ['~> 1.0.0'])

  # These gems are only required when hacking the Zen core or when running tests.
  s.add_development_dependency('rdiscount', ['~> 1.6.8'])
  s.add_development_dependency('RedCloth' , ['~> 4.2.7'])
  s.add_development_dependency('bacon'    , ['~> 1.1.0'])
  s.add_development_dependency('yard'     , ['~> 0.7.2'])
  s.add_development_dependency('capybara' , ['~> 1.0.0'])
  s.add_development_dependency('sqlite3'  , ['~> 1.3.3'])
  s.add_development_dependency('defensio' , ['~> 0.9.1'])
end
