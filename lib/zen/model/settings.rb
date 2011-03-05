include Zen::Language

Zen::Language.load('zen_models')

# When passing a hash to update() or create() we'll ignore any keys that don't belong in the table.
# This allows you to directly pass request.params to these methods without having to filter the hash
# yourself.
Sequel::Model.strict_param_setting = false

# Load all the required plugins
Sequel::Model.plugin :validation_helpers
Sequel::Model.plugin :association_pks
Sequel::Model.plugin :schema

Sequel::Plugins::ValidationHelpers::DEFAULT_OPTIONS.merge!(
{
  :exact_length => {
    :message => lambda do |length|
      lang('zen_models.exact_length') & length
    end
  },

  :format => {
    :message => lang('zen_models.format')
  },

  :includes => {
    :message   => lambda do |arg|
      lang('zen_models.includes') % arg.inspect
    end,
    :allow_nil => false
  },

  :integer => {
    :message   => lang('zen_models.integer'),
    :allow_nil => true
  },

  :length_range =>
  {
    :message => lang('zen_models.length_range')
  },

  :max_length => {
    :message   => lambda do |length|
      lang('zen_models.max_length') % length
    end,
    :allow_nil => true
  },

  :min_length => {
    :message => lambda do |length|
      lang('zen_models.min_length') % length
    end
  },

  :not_string => {
    :message => lang('zen_models.not_string')
  },

  :numeric => {
    :message => lang('zen_models.numeric')
  },

  :type => {
    :message => lambda do |type|
      lang('zen_models.type') % type
    end
  },

  :presence => {
    :message => lang('zen_models.presence')
  },

  :unique => {
    :message => lang('zen_models.unique')
  }
})
