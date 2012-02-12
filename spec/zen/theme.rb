require File.expand_path('../../helper', __FILE__)

describe "Zen::Theme" do

  it 'Error when retrieving a theme when no themes exist' do
    should.raise?(Zen::ThemeError) { Zen::Theme[:spec] }
  end

  it 'Add a new theme' do
    Zen::Theme.add do |t|
      t.name      = 'spec'
      t.author    = 'Yorick Peterse'
      t.about     = 'An example theme'
      t.templates = __DIR__
      t.public    = __DIR__
      t.env.name  = 'Zen'
      t.env.foo   = {:foo => 'bar'}
    end

    should.not.raise?(Zen::ThemeError) { Zen::Theme[:spec] }

    theme = Zen::Theme[:spec]

    theme.name.should      == :spec
    theme.author.should    == 'Yorick Peterse'
    theme.templates.should == __DIR__
    theme.env.name.should  == 'Zen'
    theme.env.foo.should   == {:foo => 'bar'}
  end

  it 'Add an already existing theme' do
    should.raise?(Zen::ValidationError) do
      Zen::Theme.add do |t|
        t.name         = 'spec'
        t.author       = 'Yorick Peterse'
        t.about        = 'An example theme'
        t.templates = __DIR__
      end
    end
  end
end
