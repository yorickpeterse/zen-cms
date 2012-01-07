require File.expand_path('../../../../../helper', __FILE__)

describe 'Ramaze::Helper::Menu' do
  behaves_like :capybara
  extend       Ramaze::Helper::Menu

  # Create all the required data
  menu = Menus::Model::Menu.create(:name => 'Spec menu')
  item = Menus::Model::MenuItem.create(
    :name    => 'Spec item',
    :menu_id => menu.id,
    :url     => '/'
  )

  child = Menus::Model::MenuItem.create(
    :name      => 'Spec item child',
    :menu_id   => menu.id,
    :url       => '/child',
    :parent_id => item.id
  )

  sub_child = Menus::Model::MenuItem.create(
    :name      => 'Spec item sub child',
    :menu_id   => menu.id,
    :url       => '/sub-child',
    :parent_id => child.id
  )

  it 'Validate a valid menu' do
    url = Menus::Controller::Menus.r(:edit, menu.id).to_s

    visit(url)

    current_path.should == url
  end

  it 'Validate an invalid menu' do
    url   = Menus::Controller::Menus.r(:edit, menu.id + 100).to_s
    index = Menus::Controller::Menus.r(:index).to_s

    visit(url)

    current_path.should == index
  end

  it 'Validate a valid menu item' do
    url = Menus::Controller::MenuItems.r(:edit, menu.id, item.id).to_s

    visit(url)

    current_path.should == url
  end

  it 'Validate an invalid menu item' do
    url   = Menus::Controller::MenuItems.r(:edit, menu.id, item.id + 100).to_s
    index = Menus::Controller::MenuItems.r(:index, menu.id).to_s

    visit(url)

    current_path.should == index
  end

  it 'Generate a navigation tree' do
    tree = menu_item_tree(menu.id, sub_child.id)

    tree[nil].should      == '--'
    tree[child.id].should == "&nbsp;&nbsp;#{child.name}"
  end

  sub_child.destroy
  child.destroy
  item.destroy
  menu.destroy
end
