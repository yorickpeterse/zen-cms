require File.expand_path('../../../../../helper', __FILE__)

describe 'Menus::Model::MenuItem' do
  menu = Menus::Model::Menu.create(:name => 'Spec')

  after do
    Menus::Model::MenuItem.destroy
  end

  it 'Sort orders of menu items should auto increment by default' do
    item  = menu.add_menu_item(:name => 'Menu item', :url => '/')
    item1 = menu.add_menu_item(:name => 'Menu item 1', :url => '/1')
    item2 = menu.add_menu_item(
      :name       => 'Menu item 2',
      :url        => '/2',
      :sort_order => 5
    )

    item3 = menu.add_menu_item(:name => 'Menu item 3', :url => '/3')
    item4 = menu.add_menu_item(
      :name       => 'Menu item 4',
      :url        => '/4',
      :sort_order => 10
    )

    item.sort_order.should  == 0
    item1.sort_order.should == 1
    item2.sort_order.should == 5
    item3.sort_order.should == 6
    item4.sort_order.should == 10
  end

  menu.destroy
end
