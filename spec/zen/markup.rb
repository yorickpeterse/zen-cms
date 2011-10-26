require File.expand_path('../../helper', __FILE__)

describe('Zen::Markup') do
  it('Convert Markdown to HTML') do
    html = Zen::Markup.convert(:markdown, 'hello **world**').strip

    html.should == '<p>hello <strong>world</strong></p>'
  end

  it('Convert Textile to HTML') do
    html = Zen::Markup.convert(:textile, 'hello *world*').strip

    html.should == '<p>hello <strong>world</strong></p>'
  end

  it('Convert HTML to plain text') do
    text = Zen::Markup.convert(:plain, '<p>hello world</p>').strip

    text.should == '&lt;p&gt;hello world&lt;&#x2F;p&gt;'
  end

  it('Convert to HTML to HTML') do
    html = Zen::Markup.convert(:html, '<p>hello world</p>')

    html.should == '<p>hello world</p>'
  end

  it('Specify a non existing engine') do
    begin
      Zen::Markup.convert(:foobar, 'hello')
    rescue ArgumentError => e
      e.message.should == 'The specified engine "foobar" is invalid'
    end
  end
end
