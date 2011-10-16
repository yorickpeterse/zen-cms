Zen::Language.load('zen_models')

Sequel::Model.plugin(:validation_helpers)
Sequel::Model.plugin(:association_pks)

Sequel.extension(:migration)
Sequel.extension(:pagination)
Sequel.extension(:inflector)

Sequel::Plugins::ValidationHelpers::DEFAULT_OPTIONS.merge!(
{
  :exact_length => {
    :message    => lambda { |length| lang('zen_models.exact_length') & length }
  },

  :format => {
    :message => lang('zen_models.format')
  },

  :includes  => {
    :message   => lambda { |arg| lang('zen_models.includes') % arg.inspect },
    :allow_nil => false
  },

  :integer => {
    :message   => lang('zen_models.integer'),
    :allow_nil => true
  },

  :length_range => {
    :message => lang('zen_models.length_range')
  },

  :max_length => {
    :message   => lambda { |length| lang('zen_models.max_length') % length },
    :allow_nil => true
  },

  :min_length => {
    :message  => lambda { |length| lang('zen_models.min_length') % length }
  },

  :not_string => {
    :message  => lang('zen_models.not_string')
  },

  :numeric   => {
    :message => lang('zen_models.numeric')
  },

  :type      => {
    :message => lambda { |type| lang('zen_models.type') % type }
  },

  :presence  => {
    :message => lang('zen_models.presence')
  },

  :unique    => {
    :message => lang('zen_models.unique')
  }
})
