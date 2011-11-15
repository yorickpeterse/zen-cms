class SpecLanguage < Zen::Controller::FrontendController
  map '/spec-language'

  def frontend_dutch
    user.update(:frontend_language => 'nl')

    respond(Zen::Language.current.name, 200)
  end

  def frontend_english
    user.update(:frontend_language => 'en')

    respond(Zen::Language.current.name, 200)
  end
end

class SpecLanguageBackend < Zen::Controller::AdminController
  map '/admin/spec-language'

  def backend_dutch
    user.update(:language => 'nl')

    respond(Zen::Language.current.name, 200)
  end

  def backend_english
    user.update(:language => 'en')

    respond(Zen::Language.current.name, 200)
  end
end
