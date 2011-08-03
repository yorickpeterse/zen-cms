require File.expand_path('../../helper', __FILE__)
require File.join(Zen::Fixtures, 'asset')

describe('Zen::Asset') do
  behaves_like :capybara

  it('Load a single stylesheet') do
    Zen::Asset.stylesheet(['reset'], :global => true)

    path = File.join(
      '/', Zen::Asset.options.prefix, Zen::Asset.options.stylesheet_prefix
    ) + '/reset.css'

    Zen::Asset::Stylesheets[:global].length.should         > 1
    Zen::Asset::Stylesheets[:global].include?(path).should === true
  end

  it('Load two stylesheets') do
    Zen::Asset.stylesheet(['reset', 'text'], :global => true)

    Zen::Asset::Stylesheets[:global].length.should                 > 2
    Zen::Asset::Stylesheets[:global].last.include?('text').should  === true
  end

  it('Load a set of action specific files') do
    visit('/spec/asset/index')

    Zen::Asset::Javascripts[:'AssetController'][:__all] \
      .length.should === 1

    Zen::Asset::Javascripts[:'AssetController'][:specific] \
      .length.should === 1

    Zen::Asset::Javascripts[:'AssetController'][:__all][0] \
      .include?('spec').should  === true

    Zen::Asset::Stylesheets[:'AssetController'] \
      .length.should            === 1

    Zen::Asset::Stylesheets[:'AssetController'][:__all][0] \
      .include?('reset').should === true
  end

  it('Build all Javascript files') do
    visit('/spec/asset/javascripts')

    path = File.join(
      '/',
      Zen::Asset.options.prefix,
      Zen::Asset.options.javascript_prefix
    ) + '/spec.js'

    page.body.strip.include?(path).should          === true
    page.body.strip.include?('specific.js').should === false
  end

  it('Build all Stylesheets') do
    visit('/spec/asset/stylesheets')

    path = File.join(
      '/',
      Zen::Asset.options.prefix,
      Zen::Asset.options.stylesheet_prefix
    ) + '/reset.css'

    page.body.strip.include?(path).should === true
  end

  it('Build a set of method specific Javascript files') do
    visit('/spec/asset/specific')

    path = File.join(
      '/',
      Zen::Asset.options.prefix,
      Zen::Asset.options.javascript_prefix
    ) + '/specific.js'

    page.body.strip.include?(path).should      === true
    page.body.strip.include?('spec.js').should === false
  end

  it('Build a set of Javascript files using an array of methods') do
    path = File.join(
      '/',
      Zen::Asset.options.prefix,
      Zen::Asset.options.javascript_prefix
    ) + '/array.js'

    [:array, :array_1].each do |method|
      visit("/spec/asset/#{method}")

      page.body.strip.include?(path).should      === true
      page.body.strip.include?('spec.js').should === false
    end
  end

end
