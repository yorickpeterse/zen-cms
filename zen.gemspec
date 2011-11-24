require File.expand_path('../lib/zen/version', __FILE__)

path = File.expand_path('../', __FILE__)

Gem::Specification.new do |s|
  s.name        = 'zen'
  s.version     = Zen::VERSION
  s.date        = '2011-11-24'
  s.authors     = ['Yorick Peterse']
  s.email       = 'info@yorickpeterse.com'
  s.summary     = 'Zen is a modular CMS written using Ramaze.'
  s.homepage    = 'http://zen-cms.com/'
  s.description = 'Zen is a modular CMS written using Ramaze. ' \
    'Zen gives you complete freedom to build whatever you want in whatever ' \
    'way you might want to build it.'

  s.files                 = `cd #{path}; git ls-files`.split("\n").sort
  s.has_rdoc              = 'yard'
  s.executables           = ['zen']
  s.required_ruby_version = '>= 1.9.2'

  s.add_dependency('sequel'      , ['~> 3.28.0'])
  s.add_dependency('ramaze'      , ['~> 2011.10.23'])
  s.add_dependency('bcrypt-ruby' , ['~> 3.0.1'])
  s.add_dependency('rake'        , ['~> 0.9.2'])
  s.add_dependency('loofah'      , ['~> 1.2.0'])
  s.add_dependency('ramaze-asset', ['~> 0.2.3'])
  s.add_dependency('shebang'     , ['~> 0.1'])

  s.add_development_dependency('rdiscount', ['>= 1.6.8'])
  s.add_development_dependency('RedCloth' , ['>= 4.2.8'])
  s.add_development_dependency('bacon'    , ['>= 1.1.0'])
  s.add_development_dependency('yard'     , ['>= 0.7.2'])
  s.add_development_dependency('capybara' , ['>= 1.1.1'])
  s.add_development_dependency('sqlite3'  , ['>= 1.3.4'])
  s.add_development_dependency('defensio' , ['>= 0.9.1'])
  s.add_development_dependency('simplecov', ['>= 0.4.2'])
  s.add_development_dependency('webmock'  , ['>= 1.6.4'])
end
