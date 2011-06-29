class AssetController < Zen::Controller::AdminController
  map '/spec/asset'

  javascript ['spec']
  stylesheet ['reset']

  def index; end

  def javascripts; Zen::Asset.build(:javascript); end
  def stylesheets; Zen::Asset.build(:stylesheet); end
end
