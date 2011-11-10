require File.expand_path('../../../helper', __FILE__)
require File.join(Zen::FIXTURES, 'theme', 'theme')

describe('Ramaze::Helper::Theme') do
  behaves_like :capybara

  before do
    get_setting(:theme).value = 'spec_theme'
  end

  after do
    get_setting(:theme).value = nil
  end

  should('render a partial template') do
    visit('/helper/partial')

    page.body.include?('This is a partial.').should == true
  end

  should('show a 404 page') do
    visit('/helper/404')

    page.body.include?('The requested page could not be found!') \
      .should == true

    page.status_code.should == 404
  end

  should('error when no partial directory exists') do
    dir = Zen::Theme['spec_theme'].partial_dir
    Zen::Theme['spec_theme'].partial_dir = nil

    begin
      visit('/helper/partial')
    rescue => e
      e.message.should == 'The theme spec_theme has no partial directory set.'
    end

    Zen::Theme['spec_theme'].partial_dir = dir
  end

  should('request a non existing partial') do
    theme = File.join(
      Zen::Theme['spec_theme'].partial_dir,
      'wrong_partial.xhtml'
    )

    begin
      visit('/helper/wrong_partial')
    rescue => e
      e.message.should == "The template #{theme} doesn't exist."
    end
  end
end
