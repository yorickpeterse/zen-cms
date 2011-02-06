require File.expand_path '../../spec', __FILE__

Zen::Package.add do |ext|
  ext.name       = "Spec"
  ext.author     = "Yorick Peterse"
  ext.version    = 1.0
  ext.about      = "Description..."
  ext.url        = "http://yorickpeterse.com/"
  ext.identifier = "com.zen.spec"
  ext.directory  = __DIR__
  
  ext.menu = [
    {
      :title => "Spec",
      :url   => "admin/spec",
      :children => [
        {:title => "Child", :url => "admin/child"}
      ]
    }
  ]
end

describe Zen::Package do
  
  it "Retrieve basic details about the extension" do
    ext = Zen::Package['com.zen.spec']
    
    ext.name.should.equal "Spec"
    ext.author.should.equal "Yorick Peterse"
    ext.version.should.equal 1.0
  end

  it "Check if the extension directory is added to Ramaze.options.roots" do
    ext = Zen::Package['com.zen.spec']
    
    Ramaze.options.roots.should.include?(__DIR__)
  end
  
  it "Build a navigation menu" do
    ext  = Zen::Package['com.zen.spec']
    menu = Zen::Package.build_menu
    
    menu.should.equal '<ul class=""><li><a href="/admin/spec" title="Spec">Spec</a><ul><li><a href="/admin/child" title="Child">Child</a></li></ul></li></ul>'
  end

end