require File.expand_path('../../../../../helper', __FILE__)

describe("Menus::Plugin::Menus") do
  include Menus::Model

  it("Create the test data") do
    Testdata[:menu]   = Menu.new(:name => 'Spec').save
    Testdata[:item_1] = MenuItem.new(
      :name => 'Spec', :url => '/', :menu_id => Testdata[:menu].id,
      :order => 1
    ).save
    Testdata[:item_2] = MenuItem.new(
      :name => 'Spec 2', :url => '/2', :menu_id => Testdata[:menu].id, 
      :order => 2, :css_id => ''
    ).save
    Testdata[:item_3] = MenuItem.new(
      :name => 'Spec 3', :url => '/3', :menu_id => Testdata[:menu].id, 
      :parent_id => Testdata[:item_2].id, :order => 3
    ).save
  end

  it("Retrieve a menu with all items") do
    menu = plugin(:menus, :menu => 'spec').strip

    menu.include?('Spec').should                  === true
    menu.include?('Spec 2').should                === true
    menu.include?('Spec 3').should                === true
    menu.include?('<ul class="children">').should === true
  end

  it("Retrieve a menu with only 1 item") do
    menu = plugin(:menus, :menu => 'spec', :limit => 1).strip

    menu.include?('Spec').should                  === true
    menu.include?('Spec 2').should                === false
    menu.include?('Spec 3').should                === false
    menu.include?('<ul class="children">').should === false
  end

  it("Retrieve a menu with only 1 item and an offset") do
    menu = plugin(
      :menus, :menu => 'spec', :limit => 1, :offset => 1
    ).strip

    menu.include?('Spec 2').should                === true
    menu.include?('Spec 3').should                === true
    menu.include?('<ul class="children">').should === true
  end

  it("Retrieve a menu with only the root elemements") do
    menu = plugin(:menus, :menu => 'spec', :sub => false).strip

    menu.include?('Spec').should                  === true
    menu.include?('Spec 2').should                === true
    menu.include?('Spec 3').should                === false
    menu.include?('<ul class="children">').should === false
  end

  it('Retrieve a set of items and sort them') do
    menu     = plugin(:menus, :menu => 'spec', :order => :desc, :sub => false).strip
    menu_asc = plugin(:menus, :menu => 'spec', :order => :asc, :sub => false).strip
    html     = <<-HTML
<ul><li><a href="/2" title="Spec 2">Spec 2</a></li><li><a href="/" title="Spec">Spec</a>
</li></ul>
HTML

    html_asc = <<-HTML
<ul><li><a href="/" title="Spec">Spec</a></li><li><a href="/2" title="Spec 2">Spec 2</a>
</li></ul>
HTML

    menu.should     === html.gsub("\n", '').strip
    menu_asc.should === html_asc.gsub("\n", '').strip
  end

  it('No empty attributes should be set') do
    menu = plugin(:menus, :menu => 'spec')

    menu.include?('id=""').should === false
  end

  it("Delete the test data") do
    [:item_3, :item_2, :item_1, :menu].each do |k|
      Testdata[k].destroy
    end
  end

end
