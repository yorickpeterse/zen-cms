class SpecStackedAspectHelper < Zen::Controller::FrontendController
  map    '/spec-stacked-aspect-helper'
  helper :stacked_aspect

  NUMBERS = {
    :before_all => nil,
    :before_a   => nil
  }

  stacked_before_all do
    NUMBERS[:before_all] = 1
  end

  stacked_before_all do
    NUMBERS[:before_all] += 1
  end

  stacked_before(:a) do
    NUMBERS[:before_a] = 1
  end

  stacked_before(:a) do
    NUMBERS[:before_a] += 1
  end

  def index
    return NUMBERS[:before_all]
  end

  def a
    return NUMBERS[:before_all] + NUMBERS[:before_a]
  end
end
