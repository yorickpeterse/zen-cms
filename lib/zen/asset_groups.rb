Zen.asset.register_asset_group(:tabs) do |asset, controller, methods|
  asset.serve(
    :javascript,
    ['admin/zen/js/lib/tabs', 'admin/zen/js/lib/hash'],
    :name       => 'zen_tabs',
    :controller => controller,
    :minify     => true,
    :methods    => methods
  )

  asset.serve(
    :css,
    ['admin/zen/css/tabs'],
    :name       => 'zen_tabs',
    :controller => controller,
    :minify     => true,
    :methods    => methods
  )
end

Zen.asset.register_asset_group(:datepicker) do |asset, controller, methods|
  asset.serve(
    :javascript,
    ['admin/zen/js/lib/datepicker'],
    :name       => 'vendor_datepicker',
    :controller => controller,
    :minify     => true,
    :methods    => methods
  )

  asset.serve(
    :css,
    ['admin/zen/css/datepicker'],
    :name       => 'vendor_datepicker',
    :controller => controller,
    :minify     => true,
    :methods    => methods
  )
end

Zen.asset.register_asset_group(:window) do |asset, controller, methods|
  asset.serve(
    :javascript,
    ['admin/zen/js/lib/window'],
    :name       => 'zen_window',
    :controller => controller,
    :minify     => true,
    :methods    => methods
  )

  asset.serve(
    :css,
    ['admin/zen/css/window'],
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
      'admin/zen/js/lib/editor',
      'admin/zen/js/lib/editor/markdown',
      'admin/zen/js/lib/editor/textile'
    ],
    :name       => 'zen_editor',
    :controller => controller,
    :minify     => true,
    :methods    => methods
  )

  asset.serve(
    :css,
    ['admin/zen/css/editor'],
    :name       => 'zen_editor',
    :controller => controller,
    :minify     => true,
    :methods    => methods
  )
end
