require File.expand_path('../../helper', __FILE__)

Zen::Language::Languages['nl'] = 'Nederlands'

describe('Zen::Language') do

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
    Zen::Language.options.language = 'nl'

    lang('spec.name').should       === 'Naam'
    lang('spec.age').should        === 'Leeftijd'
    lang('spec.parent.sub').should === 'Sub element'

    Zen::Language.options.language = 'en'
  end

end
