# Load the language pack and configure Sequel to use that pack
lang = Zen::Language.load 'zen_models'

# When passing a hash to update() or create() we'll ignore any keys that don't belong in the table.
# This allows you to directly pass request.params to these methods without having to filter the hash
# yourself.
Sequel::Model.strict_param_setting = false

# Load all the required plugins
Sequel::Model.plugin :validation_helpers
Sequel::Model.plugin :association_pks
Sequel::Model.plugin :schema

Sequel::Plugins::ValidationHelpers::DEFAULT_OPTIONS.merge!(
  :exact_length => {:message => lang.exact_length},
  :format       => {:message => lang.format},
  :includes     => {:message => lang.includes, :allow_nil => false},
  :integer      => {:message => lang.integer,  :allow_nil => true},
  :length_range => {:message => lang.length_range},
  :max_length   => {:message => lang.max_length, :allow_nil => true},
  :min_length   => {:message => lang.min_length, :allow_nil => true},
  :not_string   => {:message => lang.not_string},
  :numeric      => {:message => lang.numeric},
  :type         => {:message => lang.type},
  :presence     => {:message => lang.presence},
  :unique       => {:message => lang.unique}
)