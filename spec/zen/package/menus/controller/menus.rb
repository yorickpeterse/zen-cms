require File.expand_path('../../../../../helper', __FILE__)

Zen::Language.load('menus')

describe("Menus::Controller::Menus") do
  behaves_like :capybara

  index_url     = Menus::Controller::Menus.r(:index).to_s
  edit_url      = Menus::Controller::Menus.r(:edit).to_s
  new_url       = Menus::Controller::Menus.r(:new).to_s
  new_button    = lang('menus.buttons.new')
  save_button   = lang('menus.buttons.save')
  delete_button = lang('menus.buttons.delete')

  should('find no existing menus') do
    message = lang('menus.messages.no_menus')

    visit(index_url)

    page.has_content?(message).should           == true
    page.has_selector?('table tbody tr').should == false
  end

  should('submit a form without a CSRF token') do
    response = page.driver.post(
      Menus::Controller::Menus.r(:save).to_s
    )

    response.body.include?(lang('zen_general.errors.csrf')).should == true
    response.status.should                                         == 403
  end

  should("create a new menu") do
    visit(index_url)
    click_link(new_button)

    current_path.should == new_url

    within('#menu_form') do
      fill_in('name'     , :with => 'Spec menu')
      fill_in('html_class', :with => 'spec_class')
      fill_in('html_id'   , :with => 'spec_id')

      click_on(save_button)
    end

    page.find('input[name="name"]').value.should      == 'Spec menu'
    page.find('input[name="html_class"]').value.should == 'spec_class'
    page.find('input[name="html_id"]').value.should    == 'spec_id'
  end

  should('search for a menu') do
    search_button = lang('zen_general.buttons.search')
    error         = lang('zen_general.errors.invalid_search')

    visit(index_url)

    within('#search_form') do
      fill_in('query', :with => 'Spec menu')
      click_on(search_button)
    end

    page.has_content?(error).should       == false
    page.has_content?('Spec menu').should == true

    within('#search_form') do
      fill_in('query', :with => 'does not exist')
      click_on(search_button)
    end

    page.has_content?(error).should       == false
    page.has_content?('Spec menu').should == false
  end

  should("edit an existing menu") do
    visit(index_url)
    click_link('Spec menu')

    current_path.should =~ /#{edit_url}\/[0-9]+/

    within('#menu_form') do
      fill_in('name', :with => 'Spec menu modified')
      click_on(save_button)
    end

    page.find('input[name="name"]').value.should == 'Spec menu modified'
  end

  should("edit an existing menu with invalid data") do
    visit(index_url)
    click_link('Spec menu')

    current_path.should =~ /#{edit_url}\/[0-9]+/

    within('#menu_form') do
      fill_in('name', :with => '')
      click_on(save_button)
    end

    page.find('input[name="name"]').value.should == ''
    page.has_selector?('span.error').should      == true
  end

  should('fail to delete a set of menus without IDs') do
    visit(index_url)
    click_on(delete_button)

    page.has_selector?('input[name="menu_ids[]"]').should == true
  end

  should("delete an existing menu") do
    message = lang('menus.messages.no_menus')

    visit(index_url)
    check('menu_ids[]')
    click_on(delete_button)

    page.has_content?(message).should           == true
    page.has_selector?('table tbody tr').should == false
  end

  should('call the event new_menu (before and after)') do
    event_name = nil

    Zen::Event.listen(:before_new_menu) do |menu|
      menu.name += ' with event'
    end

    Zen::Event.listen(:after_new_menu) do |menu|
      event_name = menu.name
    end

    visit(index_url)
    click_on(new_button)

    within('#menu_form') do
      fill_in('name', :with => 'Menu')
      click_on(save_button)
    end

    page.has_selector?('span.error').should      == false
    page.find('input[name="name"]').value.should == 'Menu with event'
    event_name.should                            == 'Menu with event'

    Zen::Event.delete(:before_new_menu, :after_new_menu)
  end

  should('call the event edit_menu (before and after)') do
    event_name = nil

    Zen::Event.listen(:before_edit_menu) do |menu|
      menu.name = 'Menu modified'
    end

    Zen::Event.listen(:after_edit_menu) do |menu|
      event_name = menu.name
    end

    visit(index_url)
    click_on('Menu with event')

    within('#menu_form') do
      click_on(save_button)
    end

    page.has_selector?('span.error').should      == false
    page.find('input[name="name"]').value.should == 'Menu modified'
    event_name.should                            == 'Menu modified'

    Zen::Event.delete(:before_edit_menu, :after_edit_menu)
  end

  should('call the event delete_menu (before and after)') do
    event_name  = nil
    event_name2 = nil
    message     = lang('menus.messages.no_menus')

    Zen::Event.listen(:before_delete_menu) do |menu|
      event_name = menu.name
    end

    Zen::Event.listen(:after_delete_menu) do |menu|
      event_name2 = menu.name
    end

    visit(index_url)
    check('menu_ids[]')
    click_on(delete_button)

    page.has_selector?('table tbody tr').should == false
    page.has_content?(message).should           == true
    event_name.should                           == 'Menu modified'
    event_name2.should                          == event_name

    Zen::Event.delete(:before_delete_menu, :after_delete_menu)
  end
end
