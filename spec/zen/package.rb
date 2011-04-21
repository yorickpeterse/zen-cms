require File.expand_path('../../helper', __FILE__)

describe "Zen::Package" do

  it "Add a new package" do
    Zen::Package.add do |p|
      p.name       = 'spec'
      p.author     = 'Yorick Peterse'
      p.about      = 'A spec extension'
      p.url        = 'http://zen-cms.com/'
      p.directory  = __DIR__

      p.menu = [
        {:title => 'Spec', :url => 'admin/spec'} 
      ]
    end
  end

  it "Select a specific package by it's identifier" do
    package = Zen::Package[:spec]

    package.should_not  === nil
    package.name.should === :spec
    package.url.should  === 'http://zen-cms.com/'
  end

  it "Create a navigation menu of all packages" do
    menu = Zen::Package.build_menu('', {}, true)

    menu.include?('admin/spec').should == true
    menu.include?('Spec').should == true
  end
  
end
