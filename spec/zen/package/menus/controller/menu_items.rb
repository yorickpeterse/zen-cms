require File.expand_path('../../../../../helper', __FILE__)

Zen::Language.load('menu_items')

describe("Menus::Controller::MenuItems") do
  behaves_like :capybara

  it("Create the required test data") do
    @menu = Menus::Model::Menu.create(:name => 'Spec menu')

    @menu.name.should === 'Spec menu'
  end

  it("No menu items should exist") do
    menu_id   = @menu.id
    index_url = Menus::Controller::MenuItems.r(:index, menu_id).to_s
    message   = lang('menu_items.messages.no_items')
    
    visit(index_url)

    page.has_content?(message).should           === true
    page.has_selector?('table tbody tr').should === false
  end

  it("Create a new menu item") do
    menu_id     = @menu.id
    index_url   = Menus::Controller::MenuItems.r(:index, menu_id).to_s
    edit_url    = Menus::Controller::MenuItems.r(:edit, menu_id).to_s
    new_button  = lang('menu_items.buttons.new')
    save_button = lang('menu_items.buttons.save')

    visit(index_url)
    click_link(new_button)

    within('#menu_item_form') do
      fill_in('name'     , :with => 'Spec menu item')
      fill_in('url'      , :with => '/spec')
      fill_in('css_class', :with => 'spec_class')
      click_on(save_button)
    end

    current_path.should =~ /#{edit_url}\/[0-9]+/
  end

  it("Edit an existing menu item") do
    menu_id     = @menu.id
    index_url   = Menus::Controller::MenuItems.r(:index, menu_id).to_s
    save_button = lang('menu_items.buttons.save')

    visit(index_url)
    click_link('Spec menu item')

    within('#menu_item_form') do
      fill_in('name', :with => 'Spec menu item modified')
      click_on(save_button)
    end

    page.find('input[name="name"]').value.should === 'Spec menu item modified'
  end

  it("Delete an existing menu item") do
    menu_id       = @menu.id
    index_url     = Menus::Controller::MenuItems.r(:index, menu_id).to_s
    message       = lang('menu_items.messages.no_items')
    delete_button = lang('menu_items.buttons.delete')

    visit(index_url)
    check('menu_item_ids[]')
    click_on(delete_button)

    page.has_selector?('table tbody tr').should === false
    page.has_content?(message).should           === true
  end

  it("Remove all test data") do
    @menu.destroy

    Menus::Model::Menu[:name => 'Spec menu'].should === nil
  end

end
