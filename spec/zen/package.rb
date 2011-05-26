require File.expand_path('../../helper', __FILE__)

class SpecPackage < Zen::Controller::AdminController
  map '/admin/spec'

  def index
    Zen::Package.build_menu('spec_menu', extension_permissions)
  end
end

Zen::Package.add do |p|
  p.name       = 'spec'
  p.author     = 'Yorick Peterse'
  p.about      = 'A spec extension'
  p.url        = 'http://zen-cms.com/'
  p.directory  = __DIR__

  p.menu = [
    {:title => 'Spec', :url => '/admin/spec'} 
  ]

  p.controllers = {
    'Spec' => SpecPackage
  }
end

describe('Zen::Package', :type => :acceptance, :auto_login => true) do

  it('Select a specific package by it\'s name') do
    package = Zen::Package[:spec]

    package.should_not                 === nil
    package.name.should                === :spec
    package.url.should                 === 'http://zen-cms.com/'
    package.controllers['Spec'].should == SpecPackage
  end

  it ('Create a navigation menu of all packages') do
    visit('/admin/spec')

    page.has_selector?('a[href="/admin/spec"]').should === true
    page.has_selector?('ul.spec_menu')
  end
  
end
