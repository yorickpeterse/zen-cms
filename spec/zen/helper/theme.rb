require File.expand_path('../../../helper', __FILE__)
require __DIR__('../../fixtures/zen/theme/theme')

describe('Ramaze::Helper::Theme') do
  behaves_like :capybara

  # Set the theme
  before do
    plugin(:settings, :get, :theme).value = 'spec_theme'
  end

  # Reset
  after do
    plugin(:settings, :get, :theme).value = nil
  end

  it('Render a partial template') do
    visit('/helper/partial')

    page.body.include?('This is a partial.').should === true
  end

  it('Show a 404 page') do
    visit('/helper/404')

    page.body.include?('The requested page could not be found!') \
      .should === true

    page.status_code.should === 404
  end

  it('Show an error when no partial directory exists') do
    dir = Zen::Theme['spec_theme'].partial_dir
    Zen::Theme['spec_theme'].partial_dir = nil

    begin
      visit('/helper/partial')
    rescue => e
      e.message.should === 'The theme spec_theme has no partial directory set.'
    end

    Zen::Theme['spec_theme'].partial_dir = dir
  end

  it('Request a non existing partial') do
    theme = File.join(
      Zen::Theme['spec_theme'].partial_dir,
      'wrong_partial.xhtml'
    )

    begin
      visit('/helper/wrong_partial')
    rescue => e
      e.message.should === "The template #{theme} doesn't exist."
    end
  end

end