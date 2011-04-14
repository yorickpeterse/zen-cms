require File.expand_path('../../../helper', __FILE__)
require 'rdiscount'

describe "Ramaze::Helper::Plugin" do
  include Ramaze::Helper::Plugin

  it("Convert Markdown to HTML") do
    output = plugin(:markup, :markdown, 'hello world').strip

    output.should === '<p>hello world</p>'
  end

  it("Use a custom vendor/plugin combination") do
    output = plugin([:zen, :markup], :markdown, 'hello world').strip

    output.should === '<p>hello world</p>'
  end

end
