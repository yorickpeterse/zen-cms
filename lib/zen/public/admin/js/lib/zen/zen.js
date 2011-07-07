/**
 * The namespace used by all Javascript classes that come with Zen.
 *
 * @author Yorick Peterse
 * @since  0.2.6
 */
Zen = {};

/**
 * Object containing all the assets that were loaded from a class using the 
 * Depends mutator.
 *
 * @author Yorick Peterse
 * @since  0.2.6
 */
Zen.assets = {
    javascript: [],
    stylesheet: []
}

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
 * @param  {object} deps Object containing the stylesheets and Javascript files 
 * required by a class.
 */
Class.Mutators.Depends = function(deps)
{
    // Load all Javascript files
    if ( deps.javascript )
    {
        deps.javascript.each(function(file)
        {
            file = '/admin/js/' + file + '.js';

            if ( !Zen.assets.javascript.contains(file) )
            {
                Asset.javascript(file);
                Zen.assets.javascript.push(file);
            }
        });
    }

    // Load all stylesheets
    if ( deps.stylesheet )
    {
        deps.stylesheet.each(function(file)
        {
            file = '/admin/css/' + file + '.css';

            if ( !Zen.assets.stylesheet.contains(file) )
            {
                Asset.css(file);
                Zen.assets.stylesheet.push(file);
            }
        }); 
    }
}
