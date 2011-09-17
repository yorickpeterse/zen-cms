class SpecLanguage < Zen::Controller::FrontendController
  map '/spec-language'

  def index
    respond(Zen::Language.current, 200)
  end
end

class SpecLanguageBackend < Zen::Controller::AdminController
  map '/admin/spec-language'

  def index
    respond(Zen::Language.current, 200)
  end
end
