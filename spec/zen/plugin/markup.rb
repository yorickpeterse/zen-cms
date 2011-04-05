require File.expand_path('../../../helper', __FILE__)
require 'rdiscount'
require 'redcloth'

describe("Zen::Plugin::Markup") do

  it("Convert Markdown to HTML") do
    html = Zen::Plugin.call('com.zen.plugin.markup', :markdown, 'hello **world**').strip

    html.should === '<p>hello <strong>world</strong></p>'
  end

  it("Convert Textile to HTML") do
    html = Zen::Plugin.call('com.zen.plugin.markup', :textile, 'hello *world*').strip

    html.should === '<p>hello <strong>world</strong></p>'
  end

  it("Convert HTML to plain text") do
    text = Zen::Plugin.call('com.zen.plugin.markup', :plain, '<p>hello world</p>').strip

    text.should === '&lt;p&gt;hello world&lt;/p&gt;'
  end

  it("Convert to HTML to HTML") do
    html = Zen::Plugin.call('com.zen.plugin.markup', :html, '<p>hello world</p>')

    html.should === '<p>hello world</p>'
  end

end
