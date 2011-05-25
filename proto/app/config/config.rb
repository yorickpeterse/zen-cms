# Specify the root directory. This is required since there are multiple directories
# to load resources from. This directory will be used for the database logger, modes, etc.
Zen.root = __DIR__('../')

# Set the application's mode. Available modes are "dev" and "live"
Ramaze.options.mode  = :dev

# The session identifier to use for cookies.
Ramaze.options.session.key = 'zen.sid'

# Cache settings. These are turned off for the development server to make it easier
# to debug potential errors.
Ramaze::View.options.cache      = false
Ramaze::View.options.read_cache = false

# Use LRU instead of the memory cache as the latter leaks memory over time
Ramaze::Cache.options.session = Ramaze::Cache::LRU
