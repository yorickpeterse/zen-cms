require_relative('../helper')

describe("Zen::Theme") do
  
  it("No themes should exist") do
    lambda { Zen::Theme['foobar'] }.should raise_error(Zen::ThemeError)
  end

  it("Add a new theme") do
    Zen::Theme.add do |t|
      t.name         = 'Spec'
      t.author       = 'Yorick Peterse'
      t.version      = '0.1'
      t.about        = 'An example theme'
      t.identifier   = 'com.zen.theme.spec'
      t.template_dir = __DIR__
    end
  end

  it("Retrieve our theme") do
    theme = Zen::Theme['com.zen.theme.spec']

    theme.name.should         === 'Spec'
    theme.author.should       === 'Yorick Peterse'
    theme.template_dir.should === __DIR__
  end

end

