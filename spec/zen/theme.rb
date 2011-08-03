require File.expand_path('../../helper', __FILE__)

describe("Zen::Theme") do

  it("No themes should exist") do
    should.raise?(Zen::ThemeError) { Zen::Theme[:spec] }
  end

  it("Add a new theme") do
    Zen::Theme.add do |t|
      t.name         = 'spec'
      t.author       = 'Yorick Peterse'
      t.about        = 'An example theme'
      t.template_dir = __DIR__
      t.public_dir   = __DIR__
    end

    should.not.raise?(Zen::ThemeError) { Zen::Theme[:spec] }
  end

  it('Add an existing theme') do
    should.raise?(Zen::ValidationError) do
      Zen::Theme.add do |t|
        t.name         = 'spec'
        t.author       = 'Yorick Peterse'
        t.about        = 'An example theme'
        t.template_dir = __DIR__
      end
    end
  end

  it("Retrieve our theme") do
    theme = Zen::Theme[:spec]

    theme.name.should         === :spec
    theme.author.should       === 'Yorick Peterse'
    theme.template_dir.should === __DIR__
  end

end

