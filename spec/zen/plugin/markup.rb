require File.expand_path('../../../helper', __FILE__)
require 'rdiscount'

describe("Zen::Plugin::Markup") do

  it("Convert Markdown to HTML") do
    html = plugin(:markup, :markdown, 'hello **world**').strip

    html.should === '<p>hello <strong>world</strong></p>'
  end

  it("Convert HTML to plain text") do
    text = plugin(:markup, :plain, '<p>hello world</p>').strip

    text.should === '&lt;p&gt;hello world&lt;&#x2F;p&gt;'
  end

  it("Convert to HTML to HTML") do
    html = plugin(:markup, :html, '<p>hello world</p>')

    html.should === '<p>hello world</p>'
  end

  it('Specify a non existing engine') do
    begin
      plugin(:markup, :foobar, 'hello')
    rescue => e
      e.message.should === 'The markup engine "foobar" is invalid.'
    end
  end

  it('Specify an engine without a message') do
    Zen::Plugin::Markup::Engines['foobar'] = 'foobar'

    begin
      plugin(:markup, :foobar, 'hello')
    rescue => e
      e.message.should === 'The engine "foobar" has no matching method.'
    end

    Zen::Plugin::Markup::Engines.delete('foobar')
  end

end
