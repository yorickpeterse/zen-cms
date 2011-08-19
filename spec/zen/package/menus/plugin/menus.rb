require File.expand_path('../../../../../helper', __FILE__)

describe("Menus::Plugin::Menus") do
  @menu = Menus::Model::Menu.create(
    :name       => 'Spec',
    :html_class => 'spec_menu_class',
    :html_id    => 'spec_menu_id'
  )

  @item_1 = Menus::Model::MenuItem.create(
    :name       => 'Spec',
    :url        => '/',
    :menu_id    => @menu.id,
    :sort_order => 1
  )

  @item_2 = Menus::Model::MenuItem.create(
    :name       => 'Spec 2',
    :url        => '/2',
    :menu_id    => @menu.id,
    :sort_order => 2,
    :html_id    => '',
    :html_class => 'html class'
  )

  @item_3 = Menus::Model::MenuItem.create(
    :name       => 'Spec 3',
    :url        => '/3',
    :menu_id    => @menu.id,
    :parent_id  => @item_2.id,
    :sort_order => 3
  )

  it("Retrieve a menu with all items") do
    menu = plugin(:menus, :menu => 'spec', :sub => true).strip

    menu.include?('Spec').should                  === true
    menu.include?('Spec 2').should                === true
    menu.include?('Spec 3').should                === true
    menu.include?('<ul class="children">').should === true
  end

  it('Retrieve a menu with all items by the menu id') do
    menu = plugin(:menus, :menu => @menu.id, :sub => true).strip

    menu.include?('Spec').should                  === true
    menu.include?('Spec 2').should                === true
    menu.include?('Spec 3').should                === true
    menu.include?('<ul class="children">').should === true
  end

  it("Retrieve a menu with only 1 item") do
    menu = plugin(:menus, :menu => 'spec', :limit => 1, :sub => true).strip

    menu.include?('Spec').should                  === true
    menu.include?('Spec 2').should                === false
    menu.include?('Spec 3').should                === false
    menu.include?('<ul class="children">').should === false
  end

  it("Retrieve a menu with only 1 item and an offset") do
    menu = plugin(
      :menus, :menu => 'spec', :limit => 1, :offset => 1, :sub => true
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
    menu = plugin(
      :menus, :menu => 'spec', :order => :desc, :sub => false
    )

    menu_asc = plugin(
      :menus, :menu => 'spec', :order => :asc , :sub => false
    )

    menu     = Nokogiri::HTML.fragment(menu)
    menu_asc = Nokogiri::HTML.fragment(menu_asc)

    menu.css('ul')[0].attr('id').should    === @menu.html_id
    menu.css('ul')[0].attr('class').should === @menu.html_class

    menu.css('ul li').size.should                          === 2
    menu.css('ul li:first-child a')[0].attr('href').should === '/2'
    menu.css('ul li:last-child a')[0].attr('href').should  === '/'
    menu.css('ul li:first-child')[0].attr('class') \
      .should  === @item_2.html_class

    menu_asc.css('ul li').size.should                          === 2
    menu_asc.css('ul li:first-child a')[0].attr('href').should === '/'
    menu_asc.css('ul li:last-child a')[0].attr('href').should  === '/2'

    menu_asc.css('ul li:last-child')[0].attr('class') \
      .should === @item_2.html_class
  end

  it('No empty attributes should be set') do
    menu = plugin(:menus, :menu => 'spec')

    menu.include?('id=""').should === false
  end

  [@item_3, @item_2, @item_1, @menu].each do |k|
    k.destroy
  end
end
