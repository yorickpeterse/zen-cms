Zen::Language::Translation.add do |trans|
  trans.language = 'nl'
  trans.name     = 'dashboard'

  trans.translate do |t|
    t['titles.index']           = 'Dashboard'
    t['buttons.options']        = 'Opties'
    t['labels.columns']         = 'Kolommen'
    t['labels.active_widgets']  = 'Actieve widgets'
    t['labels.documentation']   = 'Documentatie'
    t['labels.github']          = 'Github project'
    t['labels.mailing_list']    = 'Discussie groep'
    t['widgets.titles.welcome'] = 'Welkom'

    t['widgets.welcome.content.paragraph_1'] = <<TXT.strip
Welkom bij Zen %s. Wat u nu voor u ziet is het dashboard van uw website. Dit
kleine blok heet een "widget". Widgets worden weergegeven op het dashboard en
bevatten kleine hoeveelheden aan data zoals dit help bericht of een lijst met
recente artikelen. Vind u een bepaalde widget maar niks? Geen probleem. Widgets
kunnen aan of uit worden gezet door op de knop "Opties" te klikken, deze knop
vind u in de rechter bovenhoek van deze pagina.
TXT

    t['widgets.welcome.content.paragraph_2'] = <<TXT.strip
Aan de linker kant van deze pagina vind u de naam van uw website, een paar
gebruikers specifieke acties en het hoofd navigatie menu. Met dit menu kunt u
rond navigeren door het beheerders paneel van uw website. Door op de naam te
klikken (of op de "Dashboard" link) komt u weer terug op deze pagina.
TXT

    t['widgets.welcome.content.paragraph_3'] = 'Zie de volgende links voor ' \
      'meer informatie:'

    t['description'] = 'Dashboard met aanpasbare widgets voor elke gebruiker.'
  end
end
