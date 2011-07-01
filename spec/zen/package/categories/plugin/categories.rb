require File.expand_path('../../../../../helper', __FILE__)

describe("Categories::Plugin::Categories") do
  extend Categories::Model
  
  it("Create the test data") do
    @group      = CategoryGroup.create(:name => 'Spec')

    @category_1 = Category.create(
      :category_group_id => @group.id, :name => 'Spec'
    )

    @category_2 = Category.create(
      :category_group_id => @group.id, :name => 'Spec 1'
    )

    @group.name.should      === 'Spec'
    @category_1.name.should === 'Spec'
    @category_2.name.should === 'Spec 1'
  end

  it("Retrieve all categories") do
    categories = plugin(:categories, :group => 'Spec')

    categories.count.should     === 2
    categories.class.should     ==  Array
    categories[0][:name].should === 'Spec'
    categories[1][:name].should === 'Spec 1'
  end

  it("Limit the amount of categories") do
    categories = plugin(:categories, :limit => 1, :group => 'Spec')

    categories.count.should     === 1
    categories[0][:name].should === 'Spec'
  end

  it("Specify a limit and an offset") do
    categories = plugin(
      :categories, :limit => 1, :offset => 1, :group => 'Spec'
    )

    categories.count.should     === 1
    categories[0][:name].should === 'Spec 1'
  end

  it("Retrieve a specific category") do
    category = plugin(:categories, :category => 'spec')

    category[:name].should === 'Spec'
    category.class.should  == Hash
  end

  it("Specify an invalid type") do
    should.raise?(TypeError) do
      plugin(:categories, :category => false)
    end
  end

  it("Delete the test data") do
    @category_1.destroy
    @category_2.destroy
    @group.destroy

    CategoryGroup[:name => 'Spec'].should === nil
    Category[:name => 'Spec'].should      === nil
    Category[:name => 'Spec 1'].should    === nil
  end

end
