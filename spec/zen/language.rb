require File.expand_path('../../helper', __FILE__)
require File.expand_path('../../fixtures/zen/language', __FILE__)

describe('Zen::Language') do
  behaves_like :capybara

  it('Change the current language') do
    plugin(:settings, :get, :frontend_language).value = 'nl'

    # Check if the frontend language is set properly.
    visit('/spec-language')

    page.body.include?('nl').should === true
    page.body.include?('en').should === false

    plugin(:settings, :get, :frontend_language).value = 'en'

    visit('/spec-language')

    page.body.include?('nl').should === false
    page.body.include?('en').should === true

    # Check if the backend language is set properly
    visit('/admin/spec-language')

    page.body.include?('nl').should === false
    page.body.include?('en').should === true

    plugin(:settings, :get, :language).value = 'nl'

    visit('/admin/spec-language')

    page.body.include?('nl').should === true
    page.body.include?('en').should === false

    plugin(:settings, :get, :language).value = 'en'
  end

  it('Test an English language pack') do
    Zen::Language.load('spec')

    lang('spec.name').should === 'Name'
    lang('spec.age').should  === 'Age'

    lang('spec.parent.sub').should === 'Sub item'
  end

  it('Load an already loaded language file') do
    Zen::Language.load('spec')

    lang('spec.name').should === 'Name'
  end

  it('Load a non existing language file') do
    should.raise?(Zen::LanguageError) do
      Zen::Language.load('does-not-exist')
    end
  end

  it('Access a non existing language string') do
    should.raise?(Zen::LanguageError) do
      lang('spec.does-not-exist')
    end
  end

  it('Access a non existing language string for an empty language file') do
    should.raise?(Zen::LanguageError) do
      lang('foo.does-not-exist', 'foo')
    end
  end

  it('Access an array using a language string') do
    lang('spec.array.0').should === 'first'
    lang('spec.array.1').should === 'second'
  end

  it('Test a Dutch language pack') do
    plugin(:settings, :get, :language).value = 'nl'

    lang('spec.name').should       === 'Naam'
    lang('spec.age').should        === 'Leeftijd'
    lang('spec.parent.sub').should === 'Sub element'

    plugin(:settings, :get, :language).value = 'en'
  end

end
