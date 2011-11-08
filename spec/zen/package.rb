require File.expand_path('../../helper', __FILE__)
require File.join(Zen::FIXTURES, 'package')

describe('Zen::Package') do
  behaves_like :capybara

  it('Add a new package') do
    Zen::Package.add do |p|
      p.name       = :spec
      p.title      = 'Spec'
      p.author     = 'Yorick Peterse'
      p.about      = 'A spec extension'
      p.url        = 'http://zen-cms.com/'
      p.root       = __DIR__
      p.migrations = __DIR__

      p.menu('Spec', '/admin/spec', :permission => :show_menu) do |sub|
        sub.menu('Sub spec', '/admin/spec/sub')
      end

      p.permission :foobar, 'Foobar'
    end

    pkg = Zen::Package[:spec]

    pkg.name.should       == :spec
    pkg.title.should      == 'Spec'
    pkg.author.should     == 'Yorick Peterse'
    pkg.root.should       == __DIR__
    pkg.migrations.should == pkg.root

    pkg.menu.title.should == 'Spec'
    pkg.menu.url.should   == '/admin/spec'

    pkg.menu.children[0].title.should == 'Sub spec'
    pkg.menu.children[0].url.should   == '/admin/spec/sub'

    pkg.permissions[:foobar].should   == 'Foobar'
  end

  it('Build a package\'s navigation items') do
    pkg  = Zen::Package[:spec]
    menu = pkg.menu.html
    html = '<li><a href="/admin/spec" title="Spec">Spec</a>' \
      '<ul><li><a href="/admin/spec/sub" title="Sub spec">Sub spec</a></li>' \
      '</ul></li>'

    menu.should == html
  end

  it('Build the navigation menu for all packages') do
    menu = Zen::Package.build_menu
    html = '<li><a href="/admin/spec" title="Spec">Spec</a>' \
      '<ul><li><a href="/admin/spec/sub" title="Sub spec">Sub spec</a></li>' \
      '</ul></li>'

    menu.include?('<ul class="navigation">').should == true
    menu.include?(html).should                      == true
  end
end
