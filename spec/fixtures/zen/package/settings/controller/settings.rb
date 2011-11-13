Settings::Setting.add do |setting|
  setting.name   = :checkbox
  setting.title  = 'Checkbox setting'
  setting.group  = :general
  setting.type   = 'checkbox'
  setting.values = ['value', 'value1']
end

Settings::Setting.add do |setting|
  setting.name   = :select_multiple
  setting.title  = 'Select multiple setting'
  setting.group  = :general
  setting.type   = 'select_multiple'
  setting.values = {'value' => 'Label', 'value1' => 'Label 1'}
end

Settings::Setting.migrate
