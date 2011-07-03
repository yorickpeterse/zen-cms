require File.expand_path('../../../../../helper', __FILE__)

describe('Ramaze::Helper::Menu') do
  behaves_like :capybara

  it('Create the test data') do
    @menu = Menus::Model::Menu.create(:name => 'Spec menu')
    @item = Menus::Model::MenuItem.create(
      :name    => 'Spec item',
      :menu_id => @menu.id,
      :url     => '/'
    )

    @menu.name.should === 'Spec menu'
    @item.name.should === 'Spec item'
  end

  it('Validate a valid menu') do
    url = Menus::Controller::Menus.r(:edit, @menu.id).to_s

    visit(url)

    current_path.should === url
  end

  it('Validate an invalid menu') do
    url   = Menus::Controller::Menus.r(:edit, @menu.id + 1).to_s
    index = Menus::Controller::Menus.r(:index).to_s

    visit(url)

    current_path.should === index
  end

  it('Validate a valid menu item') do
    url = Menus::Controller::MenuItems.r(:edit, @menu.id, @item.id).to_s

    visit(url)

    current_path.should === url
  end

  it('Validate an invalid menu item') do
    url   = Menus::Controller::MenuItems.r(:edit, @menu.id, @item.id + 1).to_s
    index = Menus::Controller::MenuItems.r(:index, @menu.id).to_s

    visit(url)

    current_path.should === index
  end

  it('Delete the test data') do
    @item.destroy
    @menu.destroy

    Menus::Model::Menu[:name => 'Spec menu'].should     === nil
    Menus::Model::MenuItem[:name => 'Spec item'].should === nil
  end

end
