require File.expand_path('../../helper', __FILE__)
require File.expand_path('../../fixtures/zen/language', __FILE__)

describe('Zen::Language') do
  behaves_like :capybara

  # Ensure the user object is put back in the correct state after each
  # specification.
  after do
    Users::Model::User[:email => 'spec@domain.tld'].update(
      :language          => 'en',
      :frontend_language => 'en'
    )
  end

  should('change the current language') do
    # Check if the frontend language is set properly.
    visit('/spec-language/frontend_dutch')

    page.body.include?('<p>nl</p>').should == true
    page.body.include?('<p>en<p>').should  == false

    visit('/spec-language/frontend_english')

    page.body.include?('<p>nl</p>').should == false
    page.body.include?('<p>en</p>').should == true

    visit('/admin/spec-language/backend_english')

    page.body.include?('<p>nl</p>').should == false
    page.body.include?('<p>en</p>').should == true

    visit('/admin/spec-language/backend_dutch')

    page.body.include?('<p>nl</p>').should == true
    page.body.include?('<p>en</p>').should == false
  end

  should('load an English language pack') do
    Zen::Language.load('spec')

    lang('spec.name').should == 'Name'
    lang('spec.age').should  == 'Age'

    lang('spec.parent.sub').should == 'Sub item'
  end

  should('load an already loaded language file') do
    Zen::Language.load('spec')

    lang('spec.name').should == 'Name'
  end

  should('fail to load a non existing language file') do
    should.raise?(Zen::LanguageError) do
      Zen::Language.load('does-not-exist')
    end
  end

  should('fail to access a non existing language string') do
    should.raise?(Zen::LanguageError) do
      lang('spec.does-not-exist')
    end
  end

  should('fail to access a non existing language file') do
    should.raise?(Zen::LanguageError) do
      lang('foo.does-not-exist', 'foo')
    end
  end

  should('load a Dutch language pack') do
    get_setting(:language).value = 'nl'

    lang('spec.name').should       == 'Naam'
    lang('spec.age').should        == 'Leeftijd'
    lang('spec.parent.sub').should == 'Sub element'

    get_setting(:language).value = 'en'
  end
end
