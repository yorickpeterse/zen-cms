Zen::Language::Translation.add do |t|
  t.language = 'en'
  t.name     = 'zen_general'

  t['labels.powered_by']   = 'Powered by'
  t['labels.view_website'] = 'View website'
  t['labels.logout']       = 'Logout'
  t['labels.profile']      = 'Profile'

  t['errors.csrf'] = 'The specified request can not be executed without a ' \
    'valid CSRF token.'

  t['errors.not_authorized']  = 'You are not authorized to access that page.'
  t['errors.no_templates']    = 'No templates were found for the given action.'
  t['errors.no_theme']        = 'No theme has been specified.'
  t['errors.invalid_request'] = 'The request could not be executed as the ' \
    'specified data is incorrect.'

  t['errors.require_login'] = 'You need to be logged in in order to view ' \
    'that page.'

  t['errors.invalid_search'] = 'The specified search query is invalid.'

  t['descriptions.search'] = 'Search keywords'

  t['buttons.bold']    = 'Bold'
  t['buttons.italic']  = 'Italic'
  t['buttons.link']    = 'Link'
  t['buttons.ul']      = 'Unordered list'
  t['buttons.ol']      = 'Ordered list'
  t['buttons.preview'] = 'Preview'
  t['buttons.close']   = 'Close'
  t['buttons.search']  = 'Search'

  t['datepicker.select_a_time']   = 'Select a time'
  t['datepicker.use_mouse_wheel'] = 'Use the mouse wheel to quickly change ' \
    'the value'
  t['datepicker.time_confirm_button'] = 'Ok'
  t['datepicker.apply_range']         = 'Ok'
  t['datepicker.cancel']              = 'Cancel'
  t['datepicker.week']                = 'W'

  t['special.boolean_hash.true']    = 'Yes'
  t['special.boolean_hash.false']   = 'No'

  t['markup.html']     = 'HTML'
  t['markup.textile']  = 'Textile'
  t['markup.markdown'] = 'Markdown'
  t['markup.plain']    = 'Plain'
end
