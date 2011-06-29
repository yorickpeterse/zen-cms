require File.expand_path('../../helper', __FILE__)

Zen::Language::Languages['nl'] = 'Nederlands'

describe 'Zen::Language' do

  it 'Test an English language pack' do
    Zen::Language.load('spec')

    lang('spec.name').should === 'Name'
    lang('spec.age').should  === 'Age'

    lang('spec.parent.sub').should === 'Sub item'
  end

  it 'Test a Dutch language pack' do
    Zen::Language.options.language = 'nl'

    lang('spec.name').should       === 'Naam'
    lang('spec.age').should        === 'Leeftijd'
    lang('spec.parent.sub').should === 'Sub element'

    Zen::Language.options.language = 'en'
  end

end
