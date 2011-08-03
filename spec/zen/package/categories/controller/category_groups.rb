require File.expand_path('../../../../../helper', __FILE__)

Zen::Language.load('category_groups')

describe("Categories::Controller::CategoryGroups") do
  behaves_like :capybara

  it('Submit a form without a CSRF token') do
    response = page.driver.post(
      Categories::Controller::CategoryGroups.r(:save).to_s
    )

    response.body.include?(lang('zen_general.errors.csrf')).should === true
    response.status.should                                         === 403
  end

  it("No category groups should exist") do
    index_url  = Categories::Controller::CategoryGroups.r(:index).to_s
    message    = lang('category_groups.messages.no_groups')

    visit(index_url)

    page.has_content?(message).should           === true
    page.has_selector?('table tbody tr').should === false
  end

  it("Create a new category group") do
    index_url   = Categories::Controller::CategoryGroups.r(:index).to_s
    new_url     = Categories::Controller::CategoryGroups.r(:new).to_s
    edit_url    = Categories::Controller::CategoryGroups.r(:edit).to_s
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
    index_url   = Categories::Controller::CategoryGroups.r(:index).to_s
    edit_url    = Categories::Controller::CategoryGroups.r(:edit).to_s
    save_button = lang('category_groups.buttons.save')

    visit(index_url)
    click_link('Spec category group')

    current_path.should =~ /#{edit_url}\/[0-9]+/

    within('#category_group_form') do
      fill_in('name', :with => 'Spec category group modified')
      click_on(save_button)
    end

    page.find('input[name="name"]') \
      .value.should === 'Spec category group modified'
  end

  it("Edit an existing category group with invalid data") do
    index_url   = Categories::Controller::CategoryGroups.r(:index).to_s
    edit_url    = Categories::Controller::CategoryGroups.r(:edit).to_s
    save_button = lang('category_groups.buttons.save')

    visit(index_url)
    click_link('Spec category group')

    current_path.should =~ /#{edit_url}\/[0-9]+/

    within('#category_group_form') do
      fill_in('name', :with => '')
      click_on(save_button)
    end

    page.has_selector?('span.error').should === true
  end

  it('Try to delete a category group without specifying an ID') do
    index_url     = Categories::Controller::CategoryGroups.r(:index).to_s
    delete_button = lang('category_groups.buttons.delete')

    visit(index_url)
    click_on(delete_button)

    page.has_selector?('input[name="category_group_ids[]"]').should === true
  end

  it("Delete an existing category group") do
    index_url     = Categories::Controller::CategoryGroups.r(:index).to_s
    delete_button = lang('category_groups.buttons.delete')
    message       = lang('category_groups.messages.no_groups')

    visit(index_url)
    check('category_group_ids[]')

    click_on(delete_button)

    page.has_content?(message).should           === true
    page.has_selector?('table tbody tr').should === false
  end
end
