require File.expand_path('../../../../../helper', __FILE__)

Zen::Language.load('menus')

describe("Menus::Controller::Menus") do
  behaves_like :capybara

  it("No menus should exist") do
    index_url = Menus::Controller::Menus.r(:index).to_s
    message   = lang('menus.messages.no_menus')

    visit(index_url)

    page.has_content?(message).should           === true
    page.has_selector?('table tbody tr').should === false
  end

  it('Submit a form without a CSRF token') do
    response = page.driver.post(
      Menus::Controller::Menus.r(:save).to_s
    )

    response.body.include?(lang('zen_general.errors.csrf')).should === true
    response.status.should                                         === 403
  end

  it("Create a new menu") do
    index_url   = Menus::Controller::Menus.r(:index).to_s
    new_url     = Menus::Controller::Menus.r(:new).to_s
    new_button  = lang('menus.buttons.new')
    save_button = lang('menus.buttons.save')

    visit(index_url)
    click_link(new_button)

    current_path.should === new_url

    within('#menu_form') do
      fill_in('name'     , :with => 'Spec menu')
      fill_in('html_class', :with => 'spec_class')
      fill_in('html_id'   , :with => 'spec_id')

      click_on(save_button)
    end

    page.find('input[name="name"]').value.should      === 'Spec menu'
    page.find('input[name="html_class"]').value.should === 'spec_class'
    page.find('input[name="html_id"]').value.should    === 'spec_id'
  end

  it("Edit an existing menu") do
    index_url   = Menus::Controller::Menus.r(:index).to_s
    save_button = lang('menus.buttons.save')
    edit_url    = Menus::Controller::Menus.r(:edit).to_s

    visit(index_url)
    click_link('Spec menu')

    current_path.should =~ /#{edit_url}\/[0-9]+/

    within('#menu_form') do
      fill_in('name', :with => 'Spec menu modified')
      click_on(save_button)
    end

    page.find('input[name="name"]').value.should === 'Spec menu modified'
  end

  it("Edit an existing menu with invalid data") do
    index_url   = Menus::Controller::Menus.r(:index).to_s
    save_button = lang('menus.buttons.save')
    edit_url    = Menus::Controller::Menus.r(:edit).to_s

    visit(index_url)
    click_link('Spec menu')

    current_path.should =~ /#{edit_url}\/[0-9]+/

    within('#menu_form') do
      fill_in('name', :with => '')
      click_on(save_button)
    end

    page.find('input[name="name"]').value.should === ''
    page.has_selector?('span.error').should      === true
  end

  it('Try to delete a set of menus without IDs') do
    index_url     = Menus::Controller::Menus.r(:index).to_s
    delete_button = lang('menus.buttons.delete')

    visit(index_url)
    click_on(delete_button)

    page.has_selector?('input[name="menu_ids[]"]').should === true
  end

  it("Delete an existing menu") do
    index_url     = Menus::Controller::Menus.r(:index).to_s
    delete_button = lang('menus.buttons.delete')
    message       = lang('menus.messages.no_menus')

    visit(index_url)
    check('menu_ids[]')
    click_on(delete_button)

    page.has_content?(message).should           === true
    page.has_selector?('table tbody tr').should === false
  end
end # describe
