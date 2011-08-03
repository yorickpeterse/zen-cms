require File.expand_path('../../../../../helper', __FILE__)

Zen::Language.load('menu_items')

describe("Menus::Controller::MenuItems") do
  behaves_like :capybara

  @menu = Menus::Model::Menu.create(:name => 'Spec menu')

  it("No menu items should exist") do
    menu_id   = @menu.id
    index_url = Menus::Controller::MenuItems.r(:index, menu_id).to_s
    message   = lang('menu_items.messages.no_items')

    visit(index_url)

    page.has_content?(message).should           === true
    page.has_selector?('table tbody tr').should === false
  end

  it('Submit a form without a CSRF token') do
    response = page.driver.post(
      Menus::Controller::MenuItems.r(:save).to_s
    )

    response.body.include?(lang('zen_general.errors.csrf')).should === true
    response.status.should                                         === 403
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
      fill_in('html_class', :with => 'spec_class')
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

  it('Edit an existing menu item with invalid data') do
    menu_id     = @menu.id
    index_url   = Menus::Controller::MenuItems.r(:index, menu_id).to_s
    save_button = lang('menu_items.buttons.save')

    visit(index_url)
    click_link('Spec menu item')

    within('#menu_item_form') do
      fill_in('name', :with => 'xxx')
      fill_in('url' , :with => '')
      click_on(save_button)
    end

    page.find('input[name="name"]').value.should === 'xxx'
    page.has_selector?('span.error').should      === true
  end

  it('Try to delete a set of items without IDs') do
    menu_id       = @menu.id
    index_url     = Menus::Controller::MenuItems.r(:index, menu_id).to_s
    delete_button = lang('menu_items.buttons.delete')

    visit(index_url)
    click_on(delete_button)

    page.has_selector?('input[name="menu_item_ids[]"]').should === true
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

  @menu.destroy
end # describe
