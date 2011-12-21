Zen.asset.register_asset_group(:tabs) do |asset, controller, methods|
  asset.serve(
    :javascript,
    ['admin/js/zen/lib/tabs', 'admin/js/zen/lib/hash'],
    :name       => 'zen_tabs',
    :controller => controller,
    :minify     => true,
    :methods    => methods
  )

  asset.serve(
    :css,
    ['admin/css/zen/tabs'],
    :name       => 'zen_tabs',
    :controller => controller,
    :minify     => true,
    :methods    => methods
  )
end

Zen.asset.register_asset_group(:datepicker) do |asset, controller, methods|
  asset.serve(
    :javascript,
    ['admin/js/vendor/datepicker'],
    :name       => 'vendor_datepicker',
    :controller => controller,
    :minify     => true,
    :methods    => methods
  )

  asset.serve(
    :css,
    ['admin/css/zen/datepicker'],
    :name       => 'vendor_datepicker',
    :controller => controller,
    :minify     => true,
    :methods    => methods
  )
end

Zen.asset.register_asset_group(:window) do |asset, controller, methods|
  asset.serve(
    :javascript,
    ['admin/js/zen/lib/window'],
    :name       => 'zen_window',
    :controller => controller,
    :minify     => true,
    :methods    => methods
  )

  asset.serve(
    :css,
    ['admin/css/zen/window'],
    :name       => 'zen_window',
    :controller => controller,
    :minify     => true,
    :methods    => methods
  )
end

Zen.asset.register_asset_group(:editor) do |asset, controller, methods|
  asset.load_asset_group(:window, controller, methods)

  asset.serve(
    :javascript,
    [
      'admin/js/zen/lib/editor',
      'admin/js/zen/lib/editor/markdown',
      'admin/js/zen/lib/editor/textile'
    ],
    :name       => 'zen_editor',
    :controller => controller,
    :minify     => true,
    :methods    => methods
  )

  asset.serve(
    :css,
    ['admin/css/zen/editor'],
    :name       => 'zen_editor',
    :controller => controller,
    :minify     => true,
    :methods    => methods
  )
end
