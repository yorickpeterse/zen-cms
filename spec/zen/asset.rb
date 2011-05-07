require File.expand_path('../../helper', __FILE__)

class AssetController < Zen::Controller::AdminController
  map '/spec/asset'

  javascript(['spec'])
  stylesheet(['reset'])

  def index; end

  def javascripts
    Zen::Asset.build(:javascript)
  end

  def stylesheets
    Zen::Asset.build(:stylesheet)
  end
end

describe('Zen::Asset', :type => :acceptance, :auto_login => true) do

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

    Zen::Asset::Javascripts[:'AssetController'].length.should               === 1
    Zen::Asset::Javascripts[:'AssetController'][0].include?('spec').should  === true
    Zen::Asset::Stylesheets[:'AssetController'].length.should               === 1
    Zen::Asset::Stylesheets[:'AssetController'][0].include?('reset').should === true
  end

  it('Build all Javascript files') do
    visit('/spec/asset/javascripts')

    path = File.join(
      '/', Zen::Asset.options.prefix, Zen::Asset.options.javascript_prefix
    ) + '/spec.js'

    page.body.strip.include?(path).should === true
  end

  it('Build all Stylesheets') do
    visit('/spec/asset/stylesheets')

    path = File.join(
      '/', Zen::Asset.options.prefix, Zen::Asset.options.stylesheet_prefix
    ) + '/reset.css'

    page.body.strip.include?(path).should === true
  end

end
