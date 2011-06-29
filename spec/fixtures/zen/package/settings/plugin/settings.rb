plugin(:settings, :register_group) do |group|
  group.name  = 'general_spec'
  group.title = 'General Spec'
end

plugin(:settings, :register) do |setting|
  setting.name        = 'spec'
  setting.title       = 'Spec'
  setting.group       = 'general_spec'
  setting.type        = 'select'
  setting.values      = [1,2,3]
  setting.description = 'An example of a setting with a select box.'
end

plugin(:settings, :register) do |setting|
  setting.name  = 'spec_textbox'
  setting.title = 'Spec Textbox'
  setting.group = 'general_spec'
  setting.type  = 'textbox'
end
