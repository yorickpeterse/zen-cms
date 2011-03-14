require_relative('../../helper')

describe "Zen::Package" do

  it "Add a new package" do
    Zen::Package.add do |p|
      p.type       = 'extension'
      p.name       = 'spec'
      p.author     = 'Yorick Peterse'
      p.version    = 1.0
      p.about      = 'A spec extension'
      p.url        = 'http://zen-cms.com/'
      p.identifier = 'com.zen.spec'
      p.directory  = __DIR__

      p.menu = [
        {:title => 'Spec', :url => 'admin/spec'} 
      ]
    end
  end

  it "Select a specific package by it's identifier" do
    package = Zen::Package['com.zen.spec']

    package.should_not === nil
    package.type.should === 'extension'
    package.name.should === 'spec'
    package.url.should === 'http://zen-cms.com/'
  end

  it "Create a navigation menu of all packages" do
    menu = Zen::Package.build_menu

    menu.include?('admin/spec').should == true
    menu.include?('Spec').should == true
  end
  
end
