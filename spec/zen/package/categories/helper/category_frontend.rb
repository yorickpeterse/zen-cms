require File.expand_path('../../../../../helper', __FILE__)
require File.join(Zen::FIXTURES, 'package/categories/helper/category_frontend')

describe('Ramaze::Helper::CategoryFrontend') do
  behaves_like :capybara

  extend Ramaze::Helper::CategoryFrontend

  category_group = ::Categories::Model::CategoryGroup.create(
    :name => 'Spec group'
  )

  category1 = ::Categories::Model::Category.create(
    :name              => 'Spec category',
    :category_group_id => category_group.id
  )

  category2 = ::Categories::Model::Category.create(
    :name              => 'Spec category 2',
    :category_group_id => category_group.id
  )

  should('retrieve categories for a group ID') do
    categories = get_categories(category_group.id).all

    categories.length.should   == 2
    categories[0].name.should  == category1.name
  end

  should('retrieve categories for a group slug') do
    categories = get_categories(category_group.name).all

    categories.length.should   == 2
    categories[0].name.should  == category1.name
  end

  should('limit the amount of results') do
    categories = get_categories(category_group.id, :limit => 1).all

    categories.length.should  == 1
    categories[0].name.should == category1.name
  end

  should('retrieve and paginate two categories') do
    visit('/spec-category-frontend')

    page.has_selector?('p').should          == true
    page.find('p:first-child').text.should  == category1.name
    page.has_selector?('.pager').should     == true

    visit('/spec-category-frontend?page=2')

    page.has_selector?('p').should          == true
    page.find('p:first-child').text.should  == category2.name
    page.has_selector?('.pager').should     == true
  end

  category1.destroy
  category2.destroy
  category_group.destroy
end
