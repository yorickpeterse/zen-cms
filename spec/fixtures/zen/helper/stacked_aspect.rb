class SpecStackedAspect < Zen::Controller::FrontendController
  map '/spec-stacked-aspect'

  NUMBERS = {
    :before_all => 0,
    :before     => 0,
    :after_all  => 0,
    :after      => 0
  }

  stacked_before_all(:a) do
    NUMBERS[:before_all] += 5
  end

  stacked_before_all(:b) do
    NUMBERS[:before_all] += 10
  end

  stacked_before(:c, [:before]) do
    NUMBERS[:before] += 2
  end

  stacked_before(:d, [:before]) do
    NUMBERS[:before] += 2
  end

  stacked_after_all(:a) do
    NUMBERS[:after_all] += 5
  end

  stacked_after_all(:b) do
    NUMBERS[:after_all] += 10
  end

  stacked_after(:c, [:after]) do
    NUMBERS[:after] += 2
  end

  stacked_after(:d, [:after]) do
    NUMBERS[:after] += 2
  end

  def before_all
    return NUMBERS[:before_all]
  end

  def before
    return NUMBERS[:before]
  end

  def after
    return NUMBERS[:after]
  end
end
