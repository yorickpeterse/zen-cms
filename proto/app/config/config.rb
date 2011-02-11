# Specify the root directory. This is required since there are multiple directories
# to load resources from. This directory will be used for the database logger, modes, etc.
Zen.options.root     = __DIR__('../')

# General configuration options
Zen.options.encoding = 'utf8'

# Localization settings
Zen.options.language = 'en'

# Set the application's mode. Available modes are "dev" and "live"
Ramaze.options.mode = :dev

# Configure sessions
Ramaze.options.session.key   = 'zen.sid'

Ramaze::View.options.cache   = false