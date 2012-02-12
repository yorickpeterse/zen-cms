require File.expand_path('../../../../../helper', __FILE__)

describe 'Menus::Model::Menu' do
  menu = Menus::Model::Menu.create(:name => 'Spec')

  after do
    Menus::Model::MenuItem.destroy
  end

  # The structure in this specification should look like the following:
  #
  # item 0
  # |_ item 1
  #   |_ item 2
  #     |_ item 3
  #       |_ item 4
  #
  it 'Build the hierarchy for 5 nested menu items' do
    parent_id = nil
    items     = []

    5.times do |i|
      menu_item = Menus::Model::MenuItem.create(
        :name       => "Menu item #{i}",
        :url        => "/#{i}",
        :menu_id    => menu.id,
        :sort_order => i,
        :parent_id  => parent_id
      )

      parent_id = menu_item.id
      items    << menu_item
    end

    tree = menu.menu_items_tree

    tree.length.should == 1

    tree[0][:node].name.should == 'Menu item 0'

    children = tree[0][:children][0]

    children[:node].name.should == 'Menu item 1'

    children = children[:children][0]

    children[:node].name.should == 'Menu item 2'

    children = children[:children][0]

    children[:node].name.should == 'Menu item 3'

    children = children[:children][0]

    children[:node].name.should == 'Menu item 4'
  end

  # The structure in this test should look like the following:
  #
  # item 0
  # |_ item 1
  # | |_ item 3
  # |
  # |_ item 4
  #   |_ item 2
  #
  it 'Build the tree with non sequential parent IDs' do
    item = Menus::Model::MenuItem.create(
      :name       => 'Menu item 0',
      :url        => '/0',
      :sort_order => 0,
      :menu_id    => menu.id
    )

    item1 = Menus::Model::MenuItem.create(
      :name       => 'Menu item 1',
      :url        => '/1',
      :sort_order => 1,
      :parent_id  => item.id,
      :menu_id    => menu.id
    )

    # Parent ID will be set to the last item.
    item2 = Menus::Model::MenuItem.create(
      :name       => 'Menu item 2',
      :url        => '/2',
      :sort_order => 4,
      :menu_id    => menu.id
    )

    item3 = Menus::Model::MenuItem.create(
      :name       => 'Menu item 3',
      :url        => '/3',
      :sort_order => 2,
      :parent_id  => item1.id,
      :menu_id    => menu.id
    )

    item4 = Menus::Model::MenuItem.create(
      :name       => 'Menu item 4',
      :url        => '/4',
      :sort_order => 3,
      :menu_id    => menu.id
    )

    item2.update(:parent_id => item4.id)

    tree = menu.menu_items_tree

    tree.length.should == 2

    tree[0][:node].name.should                             == 'Menu item 0'
    tree[0][:children][0][:node].name.should               == 'Menu item 1'
    tree[0][:children][0][:children][0][:node].name.should == 'Menu item 3'

    tree[1][:node].name.should               == 'Menu item 4'
    tree[1][:children][0][:node].name.should == 'Menu item 2'
  end

  menu.destroy
end
