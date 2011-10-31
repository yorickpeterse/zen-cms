# This is the main file of your application. It loads various configuration
# files, your themes and starts your application.
require 'zen'

# Depending on your database adapter you might need to install extra Gems.
# Ramaze makes it easy to automatically install and require these using
# Ramaze.setup(). For example, if you want to automatically load the mysql2 gem
# you'd do this as following:
#
#     Ramaze.setup(:verbose => false) do
#       gem 'mysql2'
#     end
#

# Load all the configuration files.
require __DIR__('config/config')
require __DIR__('config/middlewares')
require __DIR__('config/database')

# Load the default theme. You're free to change this or remove it.
require __DIR__('theme/theme')

# Starts Zen. While you can still load custom files after calling this method it
# is not recommended as it may lead to unexpected behavior. Zen itself tries not
# to cache anything in memory unless required, however it could be that a
# third-party extension does do this. Because of this it is recommended to just
# put your require() calls before calling this method.
Zen.start
