require File.expand_path '../../spec', __FILE__
require File.expand_path '../../../../lib/zen/helper/asset', __FILE__

include Ramaze::Helper::Asset

describe Ramaze::Helper::Asset do
  
  it 'Require and load a single CSS file' do
    require_css :reset
    
    build_css.should.equal '<link rel="stylesheet" href="/admin/css/reset.css" media="all" type="text/css" />'
  end
  
  it 'Require and load two CSS files' do
    require_css :reset, :base
    
    build_css.should.equal '<link rel="stylesheet" href="/admin/css/reset.css" media="all" type="text/css" /><link rel="stylesheet" href="/admin/css/base.css" media="all" type="text/css" />'
  end

  it 'Require and load two Javascript files' do
    require_js :mootools, :application
    
    build_js.should.equal '<script src="/admin/js/mootools.js"></script><script src="/admin/js/application.js"></script>'
  end

end