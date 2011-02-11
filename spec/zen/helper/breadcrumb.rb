require File.expand_path '../../spec', __FILE__
require File.expand_path '../../../../lib/zen/helper/breadcrumb', __FILE__

include Ramaze::Helper::Breadcrumb

describe Ramaze::Helper::Breadcrumb do
  it 'Generate a single segment' do
    set_breadcrumbs "hello"
    
    get_breadcrumbs.should.equal "hello"
  end
  
  it 'Generate multiple segments' do
    set_breadcrumbs "hello", "world"
    
    get_breadcrumbs.should.equal "hello &raquo; world"
  end
  
  it 'Generate multiple segments using a custom separator' do
    set_breadcrumbs "hello", "world"
    
    get_breadcrumbs("=>").should.equal "hello => world"
  end
end
