require File.expand_path('../../helper', __FILE__)
require File.join(Zen::FIXTURES, 'package')

describe 'Zen::Package' do
  behaves_like :capybara

  after do
    admins = Users::Model::UserGroup[:slug => 'administrators']

    admins.update(:super_group => true) unless admins.super_group
  end

  it 'Add a new package' do
    Zen::Package.add do |p|
      p.name       = :spec
      p.title      = 'Spec'
      p.author     = 'Yorick Peterse'
      p.about      = 'A spec extension'
      p.url        = 'http://zen-cms.com/'
      p.root       = __DIR__
      p.migrations = __DIR__
      p.env.foo    = 'bar'

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
    pkg.env.foo.should    == 'bar'

    pkg.menu[0].title.should == 'Spec'
    pkg.menu[0].url.should   == '/admin/spec'

    pkg.menu[0].children[0].title.should == 'Sub spec'
    pkg.menu[0].children[0].url.should   == '/admin/spec/sub'

    pkg.permissions[:foobar].should   == 'Foobar'
  end

  it 'Build a package\'s navigation items' do
    pkg  = Zen::Package[:spec]
    menu = pkg.menu[0].html
    html = '<li><a href="/admin/spec" title="Spec">Spec</a>' \
      '<ul><li><a href="/admin/spec/sub" title="Sub spec">Sub spec</a></li>' \
      '</ul></li>'

    menu.should == html
  end

  it 'Build the navigation menu for all packages' do
    menu = Zen::Package.build_menu
    html = '<li><a href="/admin/spec" title="Spec">Spec</a>' \
      '<ul><li><a href="/admin/spec/sub" title="Sub spec">Sub spec</a></li>' \
      '</ul></li>'

    menu.include?('<ul class="navigation">').should == true
    menu.include?(html).should                      == true
  end

  # https://github.com/zen-cms/Zen-Core/issues/65
  it 'Menu items that do not need permissions should be displayed' do
    permission = Zen::Package[:spec].menu[0].options[:permission]
    admins     = Users::Model::UserGroup[:slug => 'administrators']
    logout     = Users::Controller::Users.r(:logout).to_s

    Zen::Package[:spec].menu[0].options[:permission] = nil

    # Change the user to a regular user for this test.
    visit(logout)

    admins.update(:super_group => false)

    capybara_login

    visit(Dashboard::Controller::Dashboard.r(:index).to_s)

    within '#admin_navigation' do
      page.has_content?('Spec').should == true
    end

    visit(logout)

    Zen::Package[:spec].menu[0].options[:permission] = permission
  end
end
