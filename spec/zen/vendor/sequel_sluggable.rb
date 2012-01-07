require File.expand_path('../../../helper', __FILE__)
require File.expand_path('../../../../lib/vendor/sequel_sluggable', __FILE__)

describe 'Sequel::Plugins::Sluggable' do
  extend Sequel::Plugins::Sluggable::InstanceMethods

  it 'Generate a slug' do
    to_slug('Hello world').should    == 'hello-world'
    to_slug('Hello_world').should    == 'hello_world'
    to_slug('Hello world 10').should == 'hello-world-10'
  end
end
