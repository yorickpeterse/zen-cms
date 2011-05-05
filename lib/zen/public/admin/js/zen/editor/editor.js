/**
 * Base class for all drivers that provides several common methods and allows developers
 * to use the same syntax for all editor drivers.
 *
 * @author     Yorick Peterse
 * @since      0.2.6
 * @implements Options
 * @namespace  Zen
 */
Zen.Editor = new Class(
{
    Implements: Options,

    /**
     * Object containing all the default options merged with the custom ones.
     *
     * @author Yorick Peterse
     * @since  0.2.6
     * @var    [Object]
     */
    options:
    {
        // The default height in pixels
        height: 400,

        // The default width in pixels, set it to null to leave it unchanged (default)
        width: null,
    },

    /**
     * Array containing all the buttons to display in the toolbar and their onClick
     * events. Note that if the onClick values are strings the class assumes they're
     * methods available in the current instance.
     *
     * @author Yorick Peterse
     * @since  0.2.6
     * @var    [Array]
     */
    buttons:
    [
        {name: 'bold'     , label: 'Bold'          , onClick: 'bold'},
        {name: 'italic'   , label: 'Italic'        , onClick: 'italic'},
        {name: 'link'     , label: 'Link'          , onClick: 'link'},
        {name: 'ul'       , label: 'Unordered list', onClick: 'ul'},
        {name: 'ol'       , label: 'Ordered list'  , onClick: 'ol'}
    ],

    /**
     * The DOM element to use for the editor.
     *
     * @author Yorick Peterse
     * @since  0.2.6
     * @var    [Element]
     */
    element: null,

    /**
     * Creates a new instance of the class and saves and validates all the given data.
     *
     * @example
     *  var editor = new Zen.Editor($('editor'), {markup: 'markdown'});
     *
     * @author Yorick Peterse
     * @since  0.2.6
     * @param  [Object|String] element Either a DOM element or a CSS selector. If a
     * selector is specified only the first element will be used.
     * @param  [Object] options Object containing a custom set of options that will be
     * merged with this.options.
     */
    initialize: function(element, options)
    {
        // Merge the options
        this.setOptions(options);

        // The element variable is always required
        if ( typeOf(element) === 'undefined' )
        {
            throw new SyntaxError("You need to specify an element for the editor.");
        }

        this.element = Zen.Editor.getElement(element);

        // Create the HTML for the editor
        var toolbar       = new Element('div', {'class': 'editor_toolbar'});
        var container     = new Element('div', {'class': 'editor_container'});
        var ul            = new Element('ul');
        var current_class = this;

        this.buttons.each(function(button)
        {
            var li = new Element('li', {'class': button.name, html: button.label});

            // Add the onClick event, when clicked the current editor's instance is passed
            // to the event allowing developers to work with it's content.
            li.addEvent('click', function()
            {
                var current_editor = this.getParent('.editor_container')
                    .getElement('textarea');

                if ( typeOf(button.onClick) === 'string' )
                {
                    current_class[button.onClick](current_editor);
                }
                else
                {
                    button.onClick(current_editor);
                }
            });

            li.inject(ul);
        });

        // Inject the HTML into the DOM
        ul.inject(toolbar);
        toolbar.inject(container);
        container.inject(this.element, 'before');

        // Set the options
        ['height', 'width'].each(function(attr)
        {
            if ( current_class.options[attr] !== null )
            {
                element.setStyle(attr, current_class.options[attr]);
            }
        });

        // Inject the textarea back into the container
        element.inject(container);
        element.set('data-state', 'initialized');
    },

    /**
     * Inserts a set of <strong> tags around the cursor.
     *
     * @author Yorick Peterse
     * @since  0.2.6
     * @param  [Element] editor The editor to insert the tags into.
     */
    bold: function(editor)
    {
        editor.insertAroundCursor({before: '<strong>', after: '</strong>'});
    },

    /**
     * Inserts a set of <em> tags around the cursor.
     *
     * @author Yorick Peterse
     * @since  0.2.6
     * @param  [Element] editor The editor to insert the tags into.
     */
    italic: function(editor)
    {
        editor.insertAroundCursor({before: '<em>', after: '</em>'});
    },

    /**
     * Asks for a URL and inserts it into the textarea using an <a> tag.
     *
     * @author Yorick Peterse
     * @since  0.2.6
     * @param  [Element] editor The editor to insert the tags into.
     */
    link: function(editor)
    {
        var link = prompt("URL");

        editor.insertAroundCursor(
        {
            before: '<a href="' + link + '">',
            after: '</a>'
        });
    },

    /**
     * Inserts a set of <ul> and <li> tags around the cursor.
     *
     * @author Yorick Peterse
     * @since  0.2.6
     * @param  [Element] editor The editor to insert the tags into.
     */
    ul: function(editor)
    {
        editor.insertAroundCursor(
        {
            before: "<ul>\n    <li>",
            after:  "</li>\n</ul>"
        });
    },

    /**
     * Inserts a set of <ol> and <li> tags around the cursor.
     *
     * @author Yorick Peterse
     * @since  0.2.6
     * @param  [Element] editor The editor to insert the tags into.
     */
    ol: function(editor)
    {
        editor.insertAroundCursor(
        {
            before: "<ol>\n    <li>",
            after:  "</li>\n</ol>"
        });
    },
});

/**
 * Object containing the names of all available drivers and their classes.
 * Note that these drivers should be declared under the Zen.Editor namespace.
 *
 * @author Yorick Peterse
 * @since  0.2.6
 * @var    [Object]
 */
Zen.Editor.drivers = {
    markdown: 'Markdown',
    textile:  'Textile'
};

/**
 * Class method that can be used to create editor instances using different drivers while
 * still using the same syntax.
 *
 * @example
 *  var editor = Zen.Editor.init('markdown', $('editor'), {height: 200});
 *
 * @author Yorick Peterse
 * @since  0.2.6
 * @param  [String] driver The name of the driver to use.
 * @param  [Object|String] A DOM element or a CSS selector.
 * @param  [Object] options An object containing custom options to use.
 * @see    Zen.Editor.initialize
 * @return [Object] An instance of the correct driver or an error class in case something
 * went wrong.
 */
Zen.Editor.init = function(driver, element, options)
{
    if ( !driver )
    {
        throw new SyntaxError("You need to specify a driver.");
    }

    if ( !element )
    {
        throw new SyntaxError("You need to specify a DOM element or a CSS selector.");
    }

    // Get the element so we can determine if the textarea has already been processed
    element = Zen.Editor.getElement(element);

    if ( element.get('data-state') === 'initialized' )
    {
        return;
    }

    var driver_class = Zen.Editor.drivers[driver];

    // Try to see if a driver exists for the given name. If there isn't we'll use the
    // HTML driver as a fallback.
    if ( typeOf(driver_class) === 'undefined' || !Zen.Editor[driver_class] )
    {
        return new Zen.Editor(element, options);
    }
    else
    {
        return new Zen.Editor[driver_class](element, options);
    }
};

/**
 * Retrieves the correct element for the given CSS selector or element(s). If the
 * parameter is a single DOM element it will be returned immediately, if it's an array of
 * objects only the first one will be returned. If the parameter is a string this method
 * will return the first element for the given selector.
 *
 * @example
 *  Zen.Editor.getElement($$('.some_class')); # => Element
 *
 * @author Yorick Peterse
 * @since  0.2.6
 * @param  [String|Array|Element] The source data from which to extract the (first)
 * element.
 * @return [Element]
 */
Zen.Editor.getElement = function(element)
{
    if ( typeOf(element) === 'element' )
    {
        return element;
    }

    if ( typeOf(element) === 'string' )
    {
        element = $$(element);

        if ( element.length === 0 )
        {
            throw new Error("The CSS selector did not result in any elements.");
        }
    }

    if ( element.length > 0 )
    {
        return element[0];
    }
}
