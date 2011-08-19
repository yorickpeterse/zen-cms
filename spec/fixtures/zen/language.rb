class SpecLanguage < Zen::Controller::FrontendController
  map '/spec-language'

  def index
    Zen::Language.current
  end
end

class SpecLanguageBackend < Zen::Controller::AdminController
  map '/admin/spec-language'

  def index
    Zen::Language.current
  end
end
