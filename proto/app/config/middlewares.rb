##
# All Rack middlewares should go in a block like the one below. Different combinations
# can be used for different versions by setting the first argument of the middleware!
# method to a symbol containing the name of the environment (e.g. :live).
#
# For development purposes we'll be loading various middlewares to make it easier to
# detect errors, reloading the code and so on.
#
Ramaze.middleware! :dev do |m|
  ##
  # Rack::Lint is used to validate all code according to the Rack specification.
  # It's not recommended to use this middleware in a production environment as it will
  # slow your application down a bit.
  #
  m.use Rack::Lint

  ##
  # Rack::CommonLogger is used to log requests in an Apache like format. Zen ships with
  # a small extension of Ramaze::Log::RotatingInformer that automatically creates the
  # required directories for each mode and group (database, server, etc) but any Rack
  # compatible logger will do.
  #
  m.use Rack::CommonLogger, Zen::Logger.new("#{Zen.options.root}/log/server")

  ##
  # Shows an error page whenever an exception was raised. It's not recommended to use
  # this middleware on a production server as it may reveal sensitive details to the
  # visitor.
  #
  m.use Rack::ShowExceptions

  ##
  # Pretty much the same as Rack::ShowExceptions.
  #
  m.use Rack::ShowStatus
  
  ##
  # Routes exceptions to different actions, can be useful for catching 404's and such.
  #
  # m.use Rack::RouteExceptions
  
  ##
  # Middleware that enables conditional GET using If-None-Match and If-Modified-Since.
  # Currently Zen doesn't respond to conditional GET requests so it's fairly useless
  # out of the box, it can be useful for custom extensions and such.
  #
  # m.use Rack::ConditionalGet
  
  ##
  # Automatically sets the ETag header on all string bodies. Etags can be useful for
  # checking if a certain page has been modified or not.
  #
  # IMPORTANT: Prior to Rack 1.2.2 Rack::ETag required the second argument of use() to
  # be set to 'public'. Newer versions no longer require this.
  #
  m.use Rack::ETag
  
  ##
  # Allows HEAD requests. HEAD requests are identical to GET requests but shouldn't
  # return the body.
  #
  m.use Rack::Head
  
  ##
  # Automatically reloads your application whenever it detects changes. Note that this
  # middleware isn't always as accurate so there may be times when you have to manually
  # restart your server.
  #
  m.use Ramaze::Reloader
  
  ##
  # Runs Ramaze based on all mappings and such.
  #
  m.run Ramaze::AppMap
end

##
# Middlewares to use for a production environment.
#
Ramaze.middleware! :live do |m|
  m.use Rack::CommonLogger, Zen::Logger.new("#{Zen.options.root}/log/server")
  m.use Rack::RouteExceptions
  m.use Rack::ShowStatus
  m.use Rack::ConditionalGet
  m.use Rack::ETag
  m.use Rack::Head
  m.run Ramaze::AppMap
end
