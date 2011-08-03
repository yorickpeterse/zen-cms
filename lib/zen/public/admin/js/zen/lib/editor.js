/**
 * Base class for all drivers that provides several common methods and allows
 * developers to use the same syntax for all editor drivers.
 *
 * ## Usage
 *
 * In order to create a new instance of Zen.Editor your textareas will need an
 * attribute called "data-format". Without this attribute this class will assume
 * you're using HTML as your markup. An example of the most basic textarea looks
 * like the following:
 *
 *     <textarea data-format="markdown"></textarea>
 *
 * To make it easier to retrieve an editor instance once it's created you should
 * add an ID to the element. Instances of a textarea with an ID set can be
 * retrieved from Zen.Editor.instances, this doesn't work for classes or other
 * attributes.
 *
 *     <textarea data-format="markdown" id="markdown_editor"></textarea>
 *
 * Once you have your element in place you can create a new instance by calling
 * Zen.Editor.create. While other classes such as Zen.Window can be initialized
 * the regular way by using the "new" keyword this will not work for Zen.Editor.
 * The reason is that the editor has to initialize a sub class based on the
 * specified driver and return that class, something which isn't possible inside
 * a class' constructor. The syntax of Zen.Editor.create looks like the
 * following:
 *
 *     Zen.Editor.create(driver, element[, options]);
 *
 * A basic example of using this method looks like the following:
 *
 *     var editor = Zen.Editor.create('markdown', $('editor'), {height: 200});
 *
 * Once an editor has been initialized you can access it from a variable (if
 * you've stored the resulting object in a variable) or by using
 * Zen.Editor.instances. This object contains a list of element IDs and the
 * editor instances for those IDs. If we were to use the code above you could
 * access the instance for #editor as following:
 *
 *     Zen.Editor.instances['editor'];
 *
 * For more information see the documentation for the following methods:
 *
 * * Zen.Editor.create()
 * * Zen.Editor.initialize()
 *
 * ## Available Drivers
 *
 * Currently the following drivers are available:
 *
 * * HTML (default)
 * * Markdown
 * * Textile
 *
 * ## Creating Drivers
 *
 * Creating a new driver for your own favorite markup engine (e.g.
 * restructuredText) is pretty simple. Each driver should be declared under the
 * Zen.Editor namespace and should extend the base class, Zen.Editor. The latter
 * makes it possible for the driver to use features of the parent class if it
 * doesn't override or provides them itself.
 *
 * A basic skeleton for a driver looks like the following:
 *
 *     Zen.Editor.RestructuredText = new Class(
 *     {
 *         Extends: Zen.Editor
 *     });
 *
 * Usually you don't want to redeclare the initialize() method as it's used to
 * create most of the required data for an editor. Typically you'll only want to
 * override the methods for the default buttons or add your own ones.
 *
 * Once a driver has been written it's class has to be registered, this can be
 * done as following:
 *
 *     Zen.Editor.drivers.restructured_text = 'RestructuredText';
 *
 * The key of Zen.Editor.drivers should match the value set in the data-format
 * attribute, it's value should be the name of the driver's class.
 *
 * @author Yorick Peterse
 * @since  0.2.6
 */
Zen.Editor = new Class(
{
    Implements: Options,

    Depends:
    {
        stylesheet: ['zen/editor'],
        javascript: ['zen/lib/window']
    },

    /**
     * Object containing all the default options merged with the custom ones.
     *
     * @author Yorick Peterse
     * @since  0.2.6
     * @var    {object}
     */
    options:
    {
        // The default height in pixels
        height: 400,

        // The default width in pixels, set it to null to leave it unchanged
        // (default)
        width: null
    },

    /**
     * Array containing all the buttons to display in the toolbar and their
     * onClick events. Note that if the onClick values are strings the class
     * assumes they're methods available in the current instance.
     *
     * Each callback gets two parameters sent to it: the editor instance and
     * the object of the button that was clicked.
     *
     * @author Yorick Peterse
     * @since  0.2.6
     * @var    {array}
     */
    buttons:
    [
        {name: 'bold'   , label: 'Bold'          , onClick: 'bold'},
        {name: 'italic' , label: 'Italic'        , onClick: 'italic'},
        {name: 'link'   , label: 'Link'          , onClick: 'link'},
        {name: 'ul'     , label: 'Unordered list', onClick: 'ul'},
        {name: 'ol'     , label: 'Ordered list'  , onClick: 'ol'},
        {name: 'preview', label: 'Preview'       , onClick: 'preview'}
    ],

    /**
     * The DOM element to use for the editor.
     *
     * @author Yorick Peterse
     * @since  0.2.6
     * @var    {element}
     */
    element: null,

    /**
     * Creates a new instance of the class and saves and validates all the given
     * data.
     *
     * @example
     *  var editor = new Zen.Editor($('editor'), {markup: 'markdown'});
     *
     * @author Yorick Peterse
     * @since  0.2.6
     * @param  {object|string} element Either a DOM element or a CSS selector.
     * If a selector is specified only the first element will be used.
     * @param  {object} options Object containing a custom set of options that
     * will be merged with this.options.
     * @param  {array} buttons An array with a custom set of buttons to add on
     * top of the default ones.
     */
    initialize: function(element, options, buttons)
    {
        // Merge the options
        this.setOptions(options);

        // The element variable is always required
        if ( typeOf(element) === 'undefined' )
        {
            throw new SyntaxError(
                "You need to specify an element for the editor."
            );
        }

        this.element = Zen.Editor.getElement(element);

        // Create the HTML for the editor
        var toolbar       = new Element('div', {'class': 'editor_toolbar'});
        var container     = new Element('div', {'class': 'editor_container'});
        var ul            = new Element('ul');
        var current_class = this;

        // Push the custom buttons
        if ( typeof buttons !== 'undefined' && buttons.length > 0 )
        {
            this.buttons.combine(buttons);
        }

        // Create the HTML for all the buttons
        this.buttons.each(function(button)
        {
            var li = new Element(
                'li',
                {
                    'class': button.name,
                    html:    button.label,
                    title:   button.label
                }
            );

            // Add the onClick event, when clicked the current editor's instance
            // is passed to the event allowing developers to work with it's
            // content.
            li.addEvent('click', function()
            {
                var current_editor = this.getParent('.editor_container')
                    .getElement('textarea');

                if ( typeOf(button.onClick) === 'string' )
                {
                    current_class[button.onClick](current_editor, this);
                }
                else
                {
                    button.onClick(current_editor, this);
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
                element.setStyle('min-' + attr, current_class.options[attr]);
            }
        });

        // Inject the textarea back into the container
        element.inject(container);
        element.set('data-state', 'initialized');
    },

    /**
     * Destroys the editor instance. This will remove all HTML and removes the
     * textarea from Zen.Editor.instances if it has an ID.
     *
     * @author Yorick Peterse
     * @since  0.2.6
     */
    destroy: function()
    {
        // First we'll have to remove all HTML
        var parent_container = this.element.getParent('.editor_container');
        var id               = this.element.id;

        this.element.inject(parent_container, 'before');
        this.element.removeAttribute('data-state');

        parent_container.destroy();

        if ( typeOf(id) !== 'undefined' )
        {
            Zen.Editor.instances[id] = null;
        }

        // Reset the dimensions
        this.element.setStyle('height', null);
        this.element.setStyle('width' , null);
    },

    /**
     * Inserts a set of <strong> tags around the cursor.
     *
     * @author Yorick Peterse
     * @since  0.2.6
     * @param  {element} editor The editor to insert the tags into.
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
     * @param  {element} editor The editor to insert the tags into.
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
     * @param  {element} editor The editor to insert the tags into.
     */
    link: function(editor)
    {
        var link = prompt('URL', 'http://');

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
     * @param  {element} editor The editor to insert the tags into.
     */
    ul: function(editor)
    {
        editor.insertAroundCursor(
        {
            before: "\n<ul>\n    <li>",
            after:  "</li>\n</ul>\n"
        });
    },

    /**
     * Inserts a set of <ol> and <li> tags around the cursor.
     *
     * @author Yorick Peterse
     * @since  0.2.6
     * @param  {element} editor The editor to insert the tags into.
     */
    ol: function(editor)
    {
        editor.insertAroundCursor(
        {
            before: "\n<ol>\n    <li>",
            after:  "</li>\n</ol>\n"
        });
    },

    /**
     * Shows a preview of the content entered in the text area.
     *
     * @author Yorick Peterse
     * @since  0.2.6
     * @param  {element} editor The editor to render the preview for.
     */
    preview: function(editor)
    {
        var markup   = editor.get('value');
        var engine   = editor.get('data-format');

        new Request(
        {
            method:    'POST',
            url:       '/admin/preview',
            data:      {engine: engine, markup: markup},
            onSuccess: function(response)
            {
                new Zen.Window(
                    response,
                    {
                        title:   'Preview',
                        width:   700,
                        move:    true,
                        buttons:
                        [
                            {
                                name:    'close',
                                label:   'Close',
                                onClick: function(instance)
                                {
                                    instance.destroy();
                                }
                            }
                        ]
                    }
                );
            }
        }).send();
    }
});

/**
 * Object containing the names of all available drivers and their classes.
 * Note that these drivers should be declared under the Zen.Editor namespace.
 *
 * @author Yorick Peterse
 * @since  0.2.6
 * @var    {object}
 */
Zen.Editor.drivers = {
    markdown: 'Markdown',
    textile:  'Textile'
};

/**
 * Object that will contain a list of all instances of the Zen.Editor class.
 * Note that the textareas will need an ID in order for them to be added to this
 * list.
 *
 * @author Yorick Peterse
 * @since  0.2.6
 * @var    {object}
 */
Zen.Editor.instances = {};

/**
 * Class method that can be used to create editor instances using different
 * drivers while still using the same syntax.
 *
 * @example
 *  var editor = Zen.Editor.create('markdown', $('editor'), {height: 200});
 *
 * @author Yorick Peterse
 * @since  0.2.6
 * @see    Zen.Editor.initialize
 * @param  {string} driver The name of the driver to use.
 * @param  {object|string} A DOM element or a CSS selector.
 * @param  {object} options An object containing custom options to use.
 * @param  {object} buttons An array of buttons to add to the editor.
 * @return {object} An instance of the correct driver.
 */
Zen.Editor.create = function(driver, element, options, buttons)
{
    if ( !driver )
    {
        throw new SyntaxError("You need to specify a driver.");
    }

    if ( !element )
    {
        throw new SyntaxError(
            "You need to specify a DOM element or a CSS selector."
        );
    }

    // Get the element so we can determine if the textarea has already been
    // processed
    element = Zen.Editor.getElement(element);

    if ( element.get('data-state') === 'initialized' )
    {
        return;
    }

    var driver_class = Zen.Editor.drivers[driver];
    var instance     = null;

    // Try to see if a driver exists for the given name. If there isn't we'll
    // use the HTML driver as a fallback.
    if ( typeOf(driver_class) === 'undefined' || !Zen.Editor[driver_class] )
    {
        instance = new Zen.Editor(element, options, buttons);
    }
    else
    {
        instance = new Zen.Editor[driver_class](element, options, buttons);
    }

    // Store the instance if it has an ID
    if ( typeOf(instance.element.id) !== 'undefined' )
    {
        Zen.Editor.instances[instance.element.id] = instance;
    }

    return instance;
};

/**
 * Retrieves the correct element for the given CSS selector or element(s). If
 * the parameter is a single DOM element it will be returned immediately, if
 * it's an array of objects only the first one will be returned. If the
 * parameter is a string this method will return the first element for the
 * given selector.
 *
 * @example
 *  Zen.Editor.getElement($$('.some_class')); # => Element
 *
 * @author Yorick Peterse
 * @since  0.2.6
 * @param  {string|array|element} The source data from which to extract the
 * (first) element.
 * @return {element}
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
};
