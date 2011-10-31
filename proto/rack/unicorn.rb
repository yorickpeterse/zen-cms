# Configuration file for Unicorn. Unicorn can be installed by running the
# following shell command:
#
#     $ gem install unicorn
#
# After it's installed you can use it by invoking the unicorn shell command.
#
# For more information on all the available options see the following page:
# http://unicorn.bogomips.org/Unicorn/Configurator.html

# The working_directory option contains the path to the directory of your
# application.
working_directory File.expand_path('../../', __FILE__)

# The amount of worker processes to start. It's very important to remember that
# setting this option above 1 requires you to use a Ramaze cache that stores
# it's data outside of each process' memory. An example of such a cache is
# Ramaze::Cache::MemCache. When doing so you should set the following caches:
#
# * Ramaze::Cache.options.session
# * Ramaze::Cache.options.settings
#
# Without this data will not be synced between Unicorn workers causing all kind
# of weird things to happen.
worker_processes 1

# Listen to localhost:7000 by default. You can specify either a port or a path
# to a Unix socket.
listen 7000

# The user and user group to use for the application. It is recommended that you
# run the application using a dedicated user.
# user 'USER', 'GROUP'

# Path to the file that will contain the PID of each unicorn worker. If you're
# running multiple workers Unicorn will create multiple PIDs using the specified
# name and suffix them with a number.
pid File.expand_path('../../tmp/unicorn.pid', __FILE__)
