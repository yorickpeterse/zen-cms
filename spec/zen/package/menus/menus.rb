require File.expand_path('../../../../helper', __FILE__)

Zen::Language.load('menus')

describe("Menus::Controllers::Menus", :type => :acceptance, :auto_login => true) do
  include Menus::Controllers
  include Menus::Models

  it("No menus should exist") do
    index_url = Menus.r(:index).to_s
    message   = lang('menus.messages.no_menus')

    visit(index_url)

    page.has_content?(message).should           === true
    page.has_selector?('table tbody tr').should === false
  end

  it("Create a new menu") do
    index_url   = Menus.r(:index).to_s
    new_url     = Menus.r(:new).to_s
    new_button  = lang('menus.buttons.new')
    save_button = lang('menus.buttons.save')

    visit(index_url)
    click_link(new_button)

    current_path.should === new_url

    within('#menu_form') do
      fill_in('name'     , :with => 'Spec menu')
      fill_in('css_class', :with => 'spec_class')
      fill_in('css_id'   , :with => 'spec_id')

      click_on(save_button)
    end

    page.find('input[name="name"]').value.should      === 'Spec menu'
    page.find('input[name="css_class"]').value.should === 'spec_class'
    page.find('input[name="css_id"]').value.should    === 'spec_id'
  end

  it("Edit an existing menu") do
    index_url   = Menus.r(:index).to_s
    save_button = lang('menus.buttons.save')
    edit_url    = Menus.r(:edit).to_s

    visit(index_url)
    click_link('Spec menu')

    current_path.should =~ /#{edit_url}\/[0-9]+/

    within('#menu_form') do
      fill_in('name', :with => 'Spec menu modified')
      click_on(save_button)
    end

    page.find('input[name="name"]').value.should === 'Spec menu modified'
  end

  it("Delete an existing menu") do
    index_url     = Menus.r(:index).to_s
    delete_button = lang('menus.buttons.delete')
    message       = lang('menus.messages.no_menus')

    visit(index_url)
    check('menu_ids[]')
    click_on(delete_button)

    page.has_content?(message).should           === true
    page.has_selector?('table tbody tr').should === false
  end

end

