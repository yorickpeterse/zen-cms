require File.expand_path('../../../../../helper', __FILE__)

describe('Ramaze::Helper::Category') do
  behaves_like :capybara

  it('Create the test data') do
    Testdata[:category_group] = ::Categories::Model::CategoryGroup.create(
      :name => 'Spec group'
    )

    Testdata[:category] = ::Categories::Model::Category.create(
      :name              => 'Spec category',
      :category_group_id => Testdata[:category_group].id
    )

    Testdata[:category_group].name.should === 'Spec group'
    Testdata[:category].name.should       === 'Spec category'
  end

  it('Validate a valid category group') do
    url = ::Categories::Controller::Categories.r(
      :index, Testdata[:category_group].id
    ).to_s

    visit(url)

    current_path.should \
      === "/admin/categories/index/#{Testdata[:category_group].id}"
  end

  it('Validate an invalid category group') do
    msg = lang('category_groups.errors.invalid_group')

    visit(url)

    current_path.should === '/admin/category-groups/index'
  end

  it('Validate a valid category') do
    group_id = Testdata[:category_group].id
    cat_id   = Testdata[:category].id

    url = ::Categories::Controller::Categories.r(
      :edit, group_id, cat_id
    ).to_s

    visit(url)

    current_path.should \
      === "/admin/categories/edit/#{group_id}/#{cat_id}"
  end

  it('Validate an invalid category') do
    group_id = Testdata[:category_group].id
    cat_id   = 10000000

    url = ::Categories::Controller::Categories.r(
      :edit, group_id, cat_id
    ).to_s

    visit(url)

    current_path.should \
      === "/admin/categories/index/#{group_id}"
  end

  it('Delete the test data') do
    Testdata[:category].destroy
    Testdata[:category_group].destroy

    ::Categories::Model::CategoryGroup[:name => 'Spec group'].should === nil
    ::Categories::Model::Category[:name => 'Spec category'].should   === nil
  end
end
