require File.expand_path('../../../../../helper', __FILE__)

Zen::Language.load('category_groups')

describe(
  "Categories::Controller::CategoryGroups", :type => :acceptance, :auto_login => true
) do
  include Categories::Controller
  include Categories::Model

  it("No category groups should exist") do
    index_url  = CategoryGroups.r(:index).to_s
    message    = lang('category_groups.messages.no_groups')

    visit(index_url)

    page.has_content?(message).should           === true
    page.has_selector?('table tbody tr').should === false
  end

  it("Create a new category group") do
    index_url   = CategoryGroups.r(:index).to_s
    new_url     = CategoryGroups.r(:new).to_s
    edit_url    = CategoryGroups.r(:edit).to_s
    new_button  = lang('category_groups.buttons.new')
    save_button = lang('category_groups.buttons.save')

    visit(index_url)
    click_link(new_button)

    current_path.should == new_url

    within('#category_group_form') do
      fill_in('name', :with => 'Spec category group')
      click_on(save_button)
    end

    current_path.should                          =~ /#{edit_url}\/[0-9]+/
    page.find('input[name="name"]').value.should === 'Spec category group'
  end

  it("Edit an existing category group") do
    index_url   = CategoryGroups.r(:index).to_s
    edit_url    = CategoryGroups.r(:edit).to_s
    save_button = lang('category_groups.buttons.save')

    visit(index_url)
    click_link('Spec category group')

    current_path.should =~ /#{edit_url}\/[0-9]+/

    within('#category_group_form') do
      fill_in('name', :with => 'Spec category group modified')
      click_on(save_button)
    end

    page.find('input[name="name"]').value.should === 'Spec category group modified'
  end

  it("Delete an existing category group") do
    index_url     = CategoryGroups.r(:index).to_s
    delete_button = lang('category_groups.buttons.delete')
    message       = lang('category_groups.messages.no_groups')

    visit(index_url)
    check('category_group_ids[]')

    click_on(delete_button)

    page.has_content?(message).should           === true
    page.has_selector?('table tbody tr').should === false
  end

end
