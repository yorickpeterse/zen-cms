require File.expand_path('../../../spec', __FILE__)

describe "Zen::Liquid::Strip" do

  it "Strip trailing characters from a string" do
    template = File.read(__DIR__('../../resources/liquid/strip.html'))
    template = Liquid::Template.parse(template).render.strip

    template.should === '<p>hello world</p>'
  end

end
