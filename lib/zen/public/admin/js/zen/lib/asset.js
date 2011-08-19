/**
 * Zen.Asset is a small "class" that can be used to load Javascript or CSS
 * files. This class keeps track of all the files it has loaded and thus
 * prevents a certain file from being loaded multiple times.
 *
 * @author Yorick Peterse
 * @since  0.2.8
 */
Zen.Asset =
{
    /**
     * Object containing the Javascript and CSS files that have been loaded.
     *
     * @author Yorick Peterse
     * @since  0.2.8
     */
    assets:
    {
        javascripts: [],
        stylesheets: []
    },

    /**
     * Allows you to load a number of Javascript files. These files should be
     * specified relative to /admin/js/ and should not start with a slash.
     *
     * @author Yorick Peterse
     * @since  0.2.8
     * @param  {array} files An array of Javascript files to load.
     */
    javascript: function(files)
    {
        files.each(function(file)
        {
            file = '/admin/js/' + files + '.js';

            if ( !Zen.Asset.assets.javascripts.contains(file) )
            {
                Asset.javascript(file);
                Zen.Asset.assets.javascripts.push(file);
            }
        });
    },

    /**
     * Allows you to load a number of CSS files. These files should be specified
     * relative to /admin/css/ and just like Zen.Asset.javascript these should
     * not start with a slash.
     *
     * @author Yorick Peterse
     * @since  0.2.8
     * @param  {array} files An array of stylesheets to load.
     */

    stylesheet: function(files)
    {
        files.each(function(file)
        {
            file = '/admin/css/' + files + '.css';

            if ( !Zen.Asset.assets.stylesheets.contains(file) )
            {
                Asset.css(file);
                Zen.Asset.assets.stylesheets.push(file);
            }
        });
    }
};

/**
 * Extends the Class class so that dependencies on Javascript and CSS files can
 * be inserted into a class using the assets system that comes with Mootools.
 *
 * Note that you shouldn't specify the file extension, this will be added
 * automatically.
 *
 * @example
 *  var my_class = new Class(
 *  {
 *      Depends:
 *      {
 *          stylesheet: ['zen/editor']
 *      }
 *  });
 *
 * @author Yorick Peterse
 * @since  0.2.6
 * @see    Zen.Asset
 * @param  {object} deps Object containing the stylesheets and Javascript files
 * required by a class.
 */
Class.Mutators.Depends = function(deps)
{
    if ( deps.javascript )
    {
        Zen.Asset.javascript(deps.javascript);
    }

    if ( deps.stylesheet )
    {
        Zen.Asset.stylesheet(deps.stylesheet);
    }
}
