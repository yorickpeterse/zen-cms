require 'rdiscount'
require File.expand_path('../../../helper', __FILE__)

describe "Zen::Liquid::General" do
  include Zen::Liquid::General

  it "All methods should be present" do
    respond_to?('parse_key_values').should === true
    respond_to?('merge_context').should === true
  end

  it "Parse a key/value string and return it as a Hash" do
    hash = parse_key_values('name="Yorick" age="18"')

    hash['name'].should === 'Yorick'
    hash['age'].should === '18'
  end

  it "Merge two hashes together using merge_context()" do
    context = {'username'      => 'YorickPeterse'}
    hash    = {'selected_user' => 'username'}    
    hash    = merge_context(hash, context)

    hash['selected_user'].should === 'YorickPeterse'
  end

end
