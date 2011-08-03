class AssetController < Zen::Controller::AdminController
  map '/spec/asset'

  javascript ['spec']
  stylesheet ['reset']

  javascript ['specific'], :method => :specific
  javascript ['array']   , :method => [:array, :array_1]

  def index; end

  def javascripts; Zen::Asset.build(:javascript); end
  def stylesheets; Zen::Asset.build(:stylesheet); end

  def specific ; Zen::Asset.build(:javascript); end
  def array    ; Zen::Asset.build(:javascript); end
  def array_1  ; Zen::Asset.build(:javascript); end
end
