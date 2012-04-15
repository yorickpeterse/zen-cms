require File.expand_path('../../../../../helper', __FILE__)

describe 'Menus::Plugin::Menus' do
  extend Ramaze::Helper::MenuFrontend

  nav_menu = Menus::Model::Menu.create(
    :name       => 'Spec',
    :html_class => 'spec_menu_class',
    :html_id    => 'spec_menu_id'
  )

  item_1 = Menus::Model::MenuItem.create(
    :name       => 'Spec',
    :url        => '/',
    :menu_id    => nav_menu.id,
    :sort_order => 1
  )

  item_2 = Menus::Model::MenuItem.create(
    :name       => 'Spec 2',
    :url        => '/2',
    :menu_id    => nav_menu.id,
    :sort_order => 2,
    :html_id    => '',
    :html_class => 'html class'
  )

  item_3 = Menus::Model::MenuItem.create(
    :name       => 'Spec 3',
    :url        => '/3',
    :menu_id    => nav_menu.id,
    :parent_id  => item_2.id,
    :sort_order => 3
  )

  it "Retrieve a menu with all items" do
    menu = render_menu(nav_menu.slug).strip

    menu.include?('Spec').should                  == true
    menu.include?('Spec 2').should                == true
    menu.include?('Spec 3').should                == true
    menu.include?('<ul class="children">').should == true
  end

  it 'Retrieve a menu with all items by the menu id' do
    menu = render_menu(nav_menu.id).strip

    menu.include?('Spec').should                  == true
    menu.include?('Spec 2').should                == true
    menu.include?('Spec 3').should                == true
    menu.include?('<ul class="children">').should == true
  end

  it "Retrieve a menu with only 1 item" do
    menu = render_menu(nav_menu.slug, :limit => 1, :order => :asc).strip

    # TODO: remove this once I've figured out why Travis is being a little cunt.
    puts '---- TRAVIS DEBUGGING, LIKE A BOSS ----'
    puts menu
    puts '----'
    nav_menu.menu_items.each do |item|
      puts item.name
    end
    puts '----'

    menu.include?('Spec').should                  == true
    menu.include?('Spec 2').should                == false
    menu.include?('Spec 3').should                == false
    menu.include?('<ul class="children">').should == false
  end

  it "Retrieve a menu with only the root elemements" do
    menu = render_menu(nav_menu.slug, :sub => false).strip

    menu.include?('Spec').should                  == true
    menu.include?('Spec 2').should                == true
    menu.include?('Spec 3').should                == false
    menu.include?('<ul class="children">').should == false
  end

  it 'Retrieve a set of items and sort them' do
    menu     = render_menu(nav_menu.slug, :order => :desc, :sub => false)
    menu_asc = render_menu(nav_menu.slug, :order => :asc, :sub => false)
    menu     = Nokogiri::HTML.fragment(menu)
    menu_asc = Nokogiri::HTML.fragment(menu_asc)

    menu.css('ul')[0].attr('id').should    == nav_menu.html_id
    menu.css('ul')[0].attr('class').should == nav_menu.html_class

    menu.css('ul li').size.should                          == 2
    menu.css('ul li:first-child a')[0].attr('href').should == '/2'
    menu.css('ul li:last-child a')[0].attr('href').should  == '/'
    menu.css('ul li:first-child')[0].attr('class') \
      .should  == item_2.html_class

    menu_asc.css('ul li').size.should                          == 2
    menu_asc.css('ul li:first-child a')[0].attr('href').should == '/'
    menu_asc.css('ul li:last-child a')[0].attr('href').should  == '/2'

    menu_asc.css('ul li:last-child')[0].attr('class') \
      .should == item_2.html_class
  end

  it 'Do not set empty attributes' do
    menu = render_menu(nav_menu.slug)

    menu.include?('id=""').should == false
  end

  [item_3, item_2, item_1, nav_menu].each do |k|
    k.destroy
  end
end
