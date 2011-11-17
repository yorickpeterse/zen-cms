Zen::Language::Translation.add do |trans|
  trans.language = 'en'
  trans.name     = 'zen_models'

  trans.translate do |t|
    t['exact_length'] = 'This field is not exactly %s characters long.'
    t['format']       = "This field's format is invalid."
    t['includes']     = "This field's value is not in the range or set of %s."
    t['integer']      = "This field's value is not an integer."
    t['length_range'] = "This field's value is either too long or too short."
    t['max_length']   = "This field's value may not be longer than %s characters."
    t['min_length']   = "This field's value may not be shorter than %s characters."
    t['not_string']   = "This field's value is not a string."
    t['numeric']      = "This field's value is not numeric."
    t['type']         = "This field's value is not a %s."
    t['presence']     = "This field's value is required."
    t['unique']       = "This field's value is already taken."
  end
end
