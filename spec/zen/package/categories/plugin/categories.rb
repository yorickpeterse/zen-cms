require File.expand_path('../../../../../helper', __FILE__)

CategoryTest = {}

describe("Categories::Plugin::Categories") do
  include Categories::Model
  
  it("Create the test data") do
    CategoryTest[:group]      = CategoryGroup.new(:name => 'Spec').save
    CategoryTest[:category_1] = Category.new(
      :category_group_id => CategoryTest[:group].id, :name => 'Spec'
    ).save
    CategoryTest[:category_2] = Category.new(
      :category_group_id => CategoryTest[:group].id, :name => 'Spec 1'
    ).save
  end

  it("Retrieve all categories") do
    categories = Zen::Plugin.call('com.zen.plugin.categories', :group => 'Spec')

    categories.count.should   === 2
    categories[0].name.should === 'Spec'
    categories[1].name.should === 'Spec 1'
  end

  it("Limit the amount of categories") do
    categories = Zen::Plugin.call('com.zen.plugin.categories', :limit => 1, :group => 'Spec')

    categories.count.should   === 1
    categories[0].name.should === 'Spec'
  end

  it("Specify a limit and an offset") do
    categories = Zen::Plugin.call(
      'com.zen.plugin.categories', :limit => 1, :offset => 1, :group => 'Spec'
    )

    categories.count.should   === 1
    categories[0].name.should === 'Spec 1'
  end

  it("Retrieve a specific category") do
    category = Zen::Plugin.call("com.zen.plugin.categories", :category => 'spec')

    category.name.should === 'Spec'
  end

  it("Specify an invalid type") do
    lambda do
      Zen::Plugin.call('com.zen.plugin.categories', :category => false)
    end.should raise_error(TypeError)
  end

  it("Delete the test data") do
    CategoryTest[:category_1].delete
    CategoryTest[:category_2].delete
    CategoryTest[:group].delete
  end

end
