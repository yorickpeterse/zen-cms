require File.expand_path('../../helper', __FILE__)

describe("Zen::Theme") do
  
  it("No themes should exist") do
    lambda { Zen::Theme[:foobar] }.should raise_error(Zen::ThemeError)
  end

  it("Add a new theme") do
    Zen::Theme.add do |t|
      t.name         = 'spec'
      t.author       = 'Yorick Peterse'
      t.about        = 'An example theme'
      t.template_dir = __DIR__
    end
  end

  it("Retrieve our theme") do
    theme = Zen::Theme[:spec]

    theme.name.should         === :spec
    theme.author.should       === 'Yorick Peterse'
    theme.template_dir.should === __DIR__
  end

end

