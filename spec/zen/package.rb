require File.expand_path('../../helper', __FILE__)

fixtures ['package']

describe('Zen::Package') do
  behaves_like :capybara

  it('Select a specific package by it\'s name') do
    package = Zen::Package[:spec]

    package.should.not                 === nil
    package.name.should                === :spec
    package.url.should                 === 'http://zen-cms.com/'
    package.controllers['Spec'].should == SpecPackage
  end

  it ('Create a navigation menu of all packages') do
    visit('/admin/spec')

    page.has_selector?('a[href="/admin/spec"]').should === true
    page.has_selector?('ul.spec_menu').should          === true
  end

end
