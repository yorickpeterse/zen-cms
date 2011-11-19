require File.expand_path('../../../../../helper', __FILE__)
require File.join(Zen::FIXTURES, 'theme', 'theme')

describe('Extensions::Controller::Extensions') do
  behaves_like :capybara

  index_url = Extensions::Controller::Extensions.r(:index).to_s

  it('Show a list of all the installed packages') do
    visit(index_url)

    Zen::Package::REGISTERED.each do |name, package|
      page.has_content?(package.title).should == true
      page.has_content?(package.about).should == true
    end
  end

  it('Show a list of all the installed themes') do
    visit(index_url)

    get_setting(:theme).value = 'spec_theme'

    Zen::Theme::REGISTERED.each do |name, theme|
      page.has_content?(theme.name).should  == true
      page.has_content?(theme.about).should == true
    end

    get_setting(:theme).value = ''
  end

  it('Show a list of all the installed languages') do
    visit(index_url)

    Zen::Language::REGISTERED.each do |name, lang|
      page.has_content?(lang.title).should == true
    end
  end
end
