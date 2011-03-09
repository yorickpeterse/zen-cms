require 'rubygems'
require File.expand_path('../lib/zen/base/version', __FILE__)

# Get all the files from the manifest
manifest = File.open './MANIFEST', 'r'
manifest = manifest.read.strip
manifest = manifest.split "\n"

Gem::Specification.new do |s|
  s.name        = 'zen'
  s.version     = Zen::Version
  s.date        = '14-03-2011'
  s.authors     = ['Yorick Peterse']
  s.email       = 'info@yorickpeterse.com'
  s.summary     = 'Zen is a fully modular CMS written using Ramaze.'
  s.homepage    = 'http://zen-cms.com/'
  s.description = 'Zen is a fully modular CMS written using Ramaze. Unlike traditional Content Management Systems you are completely free to build whatever you want.'
  s.files       = manifest
  s.has_rdoc    = 'yard'
  s.executables = ['zen']
  
  # The following gems are always required  
  s.add_dependency 'sequel'
  s.add_dependency 'ramaze'
  s.add_dependency 'bcrypt-ruby'
  s.add_dependency 'liquid'
  s.add_dependency 'json'
  s.add_dependency 'thor'
  s.add_dependency 'rake'
  s.add_dependency 'defensio'
  s.add_dependency 'sequel_sluggable'
  s.add_dependency 'ruby-extensions'
end
