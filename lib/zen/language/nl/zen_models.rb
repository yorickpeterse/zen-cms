Zen::Language::Translation.add do |t|
  t.language = 'nl'
  t.name     = 'zen_models'

  t['exact_length'] = 'Dit veld bevat niet exact %s karakters.'
  t['format']       = 'Het formaat van de waarde van dit veld is onjuist.'
  t['includes']     = 'De waarde van dit veld is niet binnen het bereik van %s.'
  t['integer']      = 'De waarde van dit veld is niet numeriek.'
  t['length_range'] = 'De waarde van dit veld is te lang of te kort.'
  t['max_length']   = 'De waarde van dit veld mag niet langer zijn dan %s karakters.'
  t['min_length']   = 'De waarde van dit veld mag niet korter zijn dan %s karakters.'
  t['not_string']   = 'De waarde van dit veld is geen tekst.'
  t['numeric']      = 'De waarde van dit veld is niet numeriek.'
  t['type']         = 'De waarde van dit veld is niet het type %s.'
  t['presence']     = 'Dit veld is vereist.'
  t['unique']       = 'De waarde van dit veld is al in gebruik.'
end
