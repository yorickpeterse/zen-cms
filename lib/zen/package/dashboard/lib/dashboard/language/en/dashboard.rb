Zen::Language::Translation.add do |trans|
  trans.language = 'en'
  trans.name     = 'dashboard'

  trans.translate do |t|
    t['titles.index']           = 'Dashboard'
    t['buttons.options']        = 'Options'
    t['labels.columns']         = 'Columns'
    t['labels.active_widgets']  = 'Active Widgets'
    t['labels.documentation']   = 'Documentation'
    t['labels.github']          = 'Github Project'
    t['labels.mailing_list']    = 'Mailing List'
    t['widgets.titles.welcome'] = 'Welcome'

    t['widgets.welcome.content.paragraph_1'] = <<TXT.strip
Welcome to Zen %s. What you are seeing here is the dashboard of your website.
This little box here is called a "widget". Widgets are displayed on the
dashboard and contain small amounts of data such as this help message or a list
of recent entries. Don't like a widget? You can customize the active widgets by
clicking the "Options" button at the top right.
TXT

    t['widgets.welcome.content.paragraph_2'] = <<TXT.strip
To the left is the name of your website, a few user specific actions and the
main navigation menu. You can use this menu to navigate through the
administration panel of your website. Clicking on the name of your website (or
on the "Dashboard" link) will bring you back to this page.
TXT

    t['widgets.welcome.content.paragraph_3'] = 'For more information see the ' \
      'following links:'

    t['description'] = 'Dashboard with custom widgets for each user.'
  end
end
