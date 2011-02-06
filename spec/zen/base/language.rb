require File.expand_path('../../spec', __FILE__)
require File.expand_path('../../../../lib/zen/base/language', __FILE__)

describe Zen::Language do
  
  it 'Show a localized username and password.' do
    general = Zen::Language.load 'general'

    # Check if all the items exist
    general.should.respond_to?(:username)
    general.should.respond_to?(:password)
    
    # Check if the items have the proper values
    general.username.should.equal 'Username'
    general.password.should.equal 'Password'
  end
  
  it 'Show a localized username and password using a Dutch langauge pack' do
    Zen.options.language = 'nl'
    general              = Zen::Language.load 'general'

    # Check if all the items exist
    general.should.respond_to?(:username)
    general.should.respond_to?(:password)
    
    # Check if the items have the proper values
    general.username.should.equal 'Gebruikersnaam'
    general.password.should.equal 'Wachtwoord'
  end

end