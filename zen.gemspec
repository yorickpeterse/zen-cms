require File.expand_path('../lib/zen/version', __FILE__)

path = File.expand_path('../', __FILE__)

Gem::Specification.new do |s|
  s.name        = 'zen'
  s.version     = Zen::VERSION
  s.date        = '2012-04-16'
  s.authors     = ['Yorick Peterse']
  s.email       = 'yorickpeterse@gmail.com'
  s.summary     = 'Zen is a modular CMS written using Ramaze.'
  s.homepage    = 'http://zen-cms.com/'
  s.description = 'Zen is a modular CMS written using Ramaze. ' \
    'Zen gives you complete freedom to build whatever you want in whatever ' \
    'way you might want to build it.'

  s.post_install_message = <<-TXT.strip
Thank you for installing Zen. Creating a new project can be done by running
the following command:

    $ zen create

This command will walk you through the steps required to create a new project
using Zen. Once your project has been created you should not forget to migrate
your database, this can be done as following:

    $ rake db:migrate

Keep in mind that depending on your database configuration (this can be found
in config/database.rb) you might have to install separate Rubygems. For example,
for SQLite3 you'll need to install the sqlite3 gem.

After the database has been migrated you can start your application:

    $ ramaze start

For more information see the documentation: http://zen-cms.com/documentation
  TXT

  s.files                 = `cd #{path}; git ls-files`.split("\n").sort
  s.has_rdoc              = 'yard'
  s.executables           = ['zen']
  s.required_ruby_version = '>= 1.9.2'

  s.add_dependency('sequel',       ['~> 3.35.0'])
  s.add_dependency('ramaze',       ['~> 2012.04.14'])
  s.add_dependency('bcrypt-ruby',  ['~> 3.0.1'])
  s.add_dependency('rake',         ['~> 0.9.2.2'])
  s.add_dependency('loofah',       ['~> 1.2.1'])
  s.add_dependency('ramaze-asset', ['~> 0.2.3'])
  s.add_dependency('shebang',      ['~> 0.1'])
  s.add_dependency('diff-lcs',     ['~> 1.1.3'])

  s.add_development_dependency('redcarpet',  ['>= 2.1.1'])
  s.add_development_dependency('RedCloth',   ['>= 4.2.8'])
  s.add_development_dependency('bacon',      ['>= 1.1.0'])
  s.add_development_dependency('yard',       ['>= 0.8.1'])
  s.add_development_dependency('capybara',   ['>= 1.1.1'])
  s.add_development_dependency('defensio',   ['>= 0.9.1'])
  s.add_development_dependency('simplecov',  ['>= 0.6.4'])
  s.add_development_dependency('webmock',    ['>= 1.8.7'])
  s.add_development_dependency('ffi-aspell', ['>= 0.0.2'])
  s.add_development_dependency('sqlite3',    ['>= 1.3.4'])
  s.add_development_dependency('pg',         ['>= 0.13.2'])
  s.add_development_dependency('mysql2',     ['>= 0.3.11'])
end
