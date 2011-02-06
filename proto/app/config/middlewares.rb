# Put your custom development modes in here
Ramaze.middleware! :dev do |m|
  m.use Rack::Lint
  m.use Rack::CommonLogger, Zen::Logger.new("#{Zen.options.root}/logs/server")
  m.use Rack::ShowExceptions
  m.use Rack::ShowStatus
  m.use Rack::RouteExceptions
  m.use Rack::ConditionalGet
  m.use Rack::ETag, 'public'
  m.use Rack::Head
  m.use Ramaze::Reloader
  m.run Ramaze::AppMap
end

Ramaze.middleware! :live do |m|
  m.use Rack::CommonLogger, Zen::Logger.new("#{Zen.options.root}/logs/server")
  m.use Rack::RouteExceptions
  m.use Rack::ShowStatus
  m.use Rack::ConditionalGet
  m.use Rack::ETag
  m.use Rack::Head
  m.run Ramaze::AppMap
end