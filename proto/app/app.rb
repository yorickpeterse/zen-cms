# Load the Zen gem
require 'zen'

# Load the configuration files
require __DIR__('config/config')

# Load all our custom Rack middlewares
require __DIR__('config/middlewares')

# Load the database configuration file
require __DIR__('config/database')

# Make sure that Ramaze knows where you are
Ramaze.options.roots.push(Zen.options.root)

# Load the database
Zen.init

# Require all the custom gems/modules we need
require __DIR__('config/requires')

# Almost done!
Zen.post_init
