require File.expand_path('../../../spec', __FILE__)

describe "Ramaze::Helper::Asset" do
  include Ramaze::Helper::Asset

  it "Add a new CSS file" do
    respond_to?('require_css').should == true
    require_css('foobar')
  end

  it "Add a new Javascript file" do
    respond_to?('require_js').should == true
    require_js('baz')
  end

  it "Build all CSS files" do
    respond_to?('build_css').should == true
    require_css('foobar')

    css = build_css
    css.include?('foobar.css').should == true
    css.include?('stylesheet').should == true
  end

  it "Build all Javascript files" do
    respond_to?('build_js').should == true
    require_js('baz')

    js = build_js
    js.include?('baz.js').should == true
    js.include?('script').should == true
  end

end
