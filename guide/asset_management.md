# Asset Management

Zen comes with an asset manager powered by [Ramaze::Asset][ramaze-asset]. Before
v0.3 Zen used to come with it's own asset manager (``Zen::Asset``) but this
module is no longer available as of v0.3.

Assets can be loaded using the attribute ``Zen.asset``. This attribute contains
an instance of ``Ramaze::Asset::Environment`` and will automatically minify
files based on ``Ramaze.options.mode``. If the mode is ``:live`` all the files
will be minified. Once minified these files will be stored in
``public/minified`` in the directory stored in ``Zen.root``. If the
``minified/`` directory doesn't exist it will be automatically created.

Assets can be loaded in two different ways, either by calling
``Zen.asset.serve()`` directly or by using the helper ``Ramaze::Helper::Asset``.
The asset helper is loaded in the admin controller and therefor available to all
controllers that extend it. Loading assets using the first method works as
following:

    Zen.asset.serve(:javascript, ['admin/mootools/js/core'])

The first parameter is the type of files to load. Out of the box you can use
``:javascript`` and ``:css``. The second parameter is an array of paths relative
to ``/`` (with or without file extensions). The third parameter can be used to
specify extra options. See [Ramaze::Asset::Environment][ramaze-env] URL for more
information.

The second way of loading assets is by using the Asset helper. This helper has a
shorter syntax and loads the assets *only* for the calling controller. Generally
it's better to load assets for a specific controller rather than globally
loading them. Using this helper you can load assets in your class declaration as
following:

    class Posts < Zen::Controller::AdminController
      map '/admin/posts'

      serve(:javascript, ['admin/mootools/js/core'])
    end

The ``serve()`` method has the same syntax as ``Zen.asset.serve()``, it just
automatically fills the ``:controller`` option.

An example of loading a set of files with various options (taken from the Users
package):

    serve(
      :javascript,
      ['admin/users/js/lib/access_rules', 'admin/users/js/access_rules'],
      :methods => [:edit, :new],
      :name    => 'users'
    )

## Asset Groups

Loading multiple assets, especially ones that ship with Zen, can be a bit
annoying. Luckily ``Ramaze::Asset`` provides a nice way of dealing with groups
of assets: asset groups. Asset groups are simple blocks that are invoked on the
an instance of ``Ramaze::Asset::Environment`` (the one they're added to). Adding
an asset group can be done as following:

    Zen.asset.register_asset_group(:my_asset_group) do |asset|
      asset.serve(...)
    end

Loading that particular asset group would be done as following:

    Zen.asset.load_asset_group(:my_asset_group)

All additional parameters passed to ``Zen.asset.load_asset_group()`` will be
passed to the block that defines the asset group. This makes it possible for
asset groups to know for what controller they should be loaded:

    Zen.asset.register_asset_group(:my_asset_group) do |asset, controller|
      asset.serve(
        :javascript,
        ['admin/mootools/js/core'],
        :controller => controller
      )
    end

    Zen.asset.load_asset_group(:my_asset_group, Sections::Controller::Sections)

The Asset helper also contains a method that makes it a bit easier to load
asset groups in your controllers. This method is called ``load_asset_group()``.
The first parameter is an array of groups to load and the second parameter an
array of methods for which to load those groups:

    class Posts < Zen::Controller::AdminController
      map '/'

      # Loads the :tabs group for the index() method
      load_asset_group([:tabs], [:index])
    end

### Available Groups

Zen comes with the following asset groups that you can use:

* tabs
* datepicker
* window
* editor

## Global Assets

When starting up Zen will check if it can find a global stylesheet and
Javascript file. These files can be used to make changes to the admin panel
without having to go through the process of creating packages or re-defining the
entire layout. These files are called "global.css" and "global.js" and (in order
to use them) should be placed in the following directories (where ROOT is the
root directory of the application):

* ROOT/admin/zen/css/global.css
* ROOT/admin/zen/js/global.js

[ramaze-asset]: https://github.com/yorickpeterse/ramaze-asset
[ramaze-env]: https://github.com/YorickPeterse/ramaze-asset/blob/master/lib/ramaze/asset/environment.rb
