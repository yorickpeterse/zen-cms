require File.expand_path('../../../../../helper', __FILE__)

describe("Categories::Controller::Categories") do
  behaves_like :capybara

  after do
    Zen::Event.delete(
      :before_new_category,
      :after_new_category,
      :before_edit_category,
      :after_edit_category,
      :before_delete_category,
      :after_delete_category
    )
  end

  group         = Categories::Model::CategoryGroup.create(:name => 'Spec group')
  index_url     = Categories::Controller::Categories.r(:index, group.id).to_s
  edit_url      = Categories::Controller::Categories.r(:edit , group.id).to_s
  save_button   = lang('categories.buttons.save')
  delete_button = lang('categories.buttons.delete')

  it('Submit a form without a CSRF token') do
    response = page.driver.post(
      Categories::Controller::Categories.r(:save).to_s
    )

    response.body.include?(lang('zen_general.errors.csrf')).should == true
    response.status.should                                         == 403
  end

  it('No categories should exist') do
    message = lang('categories.messages.no_categories')

    visit(index_url)

    page.has_content?(message).should           == true
    page.has_selector?('table tbody tr').should == false
    current_path.should                         == index_url
  end

  it("Create a new category") do
    new_button  = lang('categories.buttons.new')
    event_name  = nil
    event_name2 = nil

    Zen::Event.listen(:before_new_category) do |category|
      event_name = category.name
    end

    Zen::Event.listen(:after_new_category) do |category|
      event_name2 = category.name
    end

    visit(index_url)
    click_link(new_button)

    within('#category_form') do
      fill_in('name', :with => 'Spec category')
      click_on(save_button)
    end

    current_path.should =~ /#{edit_url}\/[0-9]+/
    event_name.should   == 'Spec category'
    event_name2.should  == event_name
  end

  it("Edit an existing category") do
    event_name  = nil
    event_name2 = nil
    name        = 'Spec category modified 123'

    Zen::Event.listen(:before_edit_category) do |category|
      event_name = category.name
    end

    Zen::Event.listen(:after_edit_category) do |category|
      event_name2 = category.name
    end

    visit(index_url)
    click_link('Spec category')

    current_path.should =~ /#{edit_url}\/[0-9]+/

    within('#category_form') do
      fill_in('name', :with => name)
      click_on(save_button)
    end

    page.find('input[name="name"]').value.should == name

    event_name.should  == name
    event_name2.should == event_name

    # Modify the name using an event
    Zen::Event.listen(:before_edit_category) do |category|
      category.name = 'Spec category modified'
    end

    within('#category_form') do
      click_on(save_button)
    end

    page.find('input[name="name"]').value.should == 'Spec category modified'
  end

  it("Edit an existing category with invalid data") do
    visit(index_url)
    click_link('Spec category')

    current_path.should =~ /#{edit_url}\/[0-9]+/

    within('#category_form') do
      fill_in('name', :with => '')
      click_on(save_button)
    end

    page.has_selector?('span.error').should == true
  end

  it('Try to delete a category without specifying an ID') do
    visit(index_url)
    click_on(delete_button)

    page.has_selector?('input[name="category_ids[]"]').should == true
  end

  it("Delete an existing category") do
    message     = lang('categories.messages.no_categories')
    event_name  = nil
    event_name2 = nil

    Zen::Event.listen(:before_delete_category) do |category|
      event_name = category.name
    end

    Zen::Event.listen(:after_delete_category) do |category|
      event_name2 = category.name
    end

    visit(index_url)
    check('category_ids[]')
    click_on(delete_button)

    page.has_content?(message).should           == true
    page.has_selector?('table tbody tr').should == false

    event_name.should  == 'Spec category modified'
    event_name2.should == event_name
  end

  group.destroy
end
