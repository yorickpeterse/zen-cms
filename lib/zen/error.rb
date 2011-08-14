#:nodoc:
module Zen
  # Error class used by Zen::Language.
  class LanguageError < StandardError; end

  # Error class used by Zen::Package.
  class PackageError < StandardError; end

  # Error class used by Zen::Plugin.
  class PluginError < StandardError; end

  # Error class used by Zen::Theme.
  class ThemeError < StandardError; end

  # Error class used by Zen::Validation.
  class ValidationError < StandardError; end
end # Zen
