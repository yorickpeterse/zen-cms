require File.expand_path('../../helper', __FILE__)

describe "Zen::Language" do
  include Zen::Language

  it "Test an English language pack" do
    Zen::Language.options.language = 'en'
    Zen::Language.load('spec')

    lang('spec.name').should === 'Name'
    lang('spec.age').should === 'Age'

    lang('spec.parent.sub').should === 'Sub item'
  end

  it "Test a Dutch language pack" do
    Zen::Language.options.language = 'nl'
    Zen::Language.load('spec')

    lang('spec.name').should === 'Naam'
    lang('spec.age').should === 'Leeftijd'

    lang('spec.parent.sub').should === 'Sub element'
  end
end
