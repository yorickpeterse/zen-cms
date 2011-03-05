require File.expand_path('../../spec', __FILE__)
require File.expand_path('../../../../lib/zen/base/language', __FILE__)

include Zen::Language

describe Zen::Language do
  
  it 'Show a localized username and password.' do
    Zen::Language.load('general')

    lang('general.username').should.equal('Username')
    lang('general.password').should.equal('Password')
  end
  
  it 'Show a localized username and password using a Dutch langauge pack' do
    Zen::Language.options.language = 'nl'
    Zen::Language.load('general')
    
    # Check if the items have the proper values
    lang('general.username').should.equal('Gebruikersnaam')
    lang('general.password').should.equal('Wachtwoord')
  end

  it 'Access a sub item' do
    Zen::Language.options.language = 'en'
    Zen::Language.load('general')

    lang('general.location.street').should.equal('Street')
    lang('general.location.city').should.equal('City')
  end

end
