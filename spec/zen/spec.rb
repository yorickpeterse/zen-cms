require File.expand_path('../../../lib/zen', __FILE__)
require 'ramaze/spec/bacon'
require __DIR__ 'config/database'

Ramaze.options.roots = [__DIR__]
Ramaze.options.mode  = :spec
Zen.options.root     = __DIR__

Zen.init