"use strict";

Zen = Zen || {};

/**
 * The Window class can be used to create basic windows with a title and a set
 * of buttons. These windows can be used for a preview of an article, showing an
 * image or asking for a confirmation.
 *
 * ## Usage
 *
 * In order to create a new window you simply need to create a new instance of
 * the class. The first parameter is the content to display and is required, the
 * second parameter is an object containing all custom options to use such as
 * the title.
 *
 *     var modal = new Zen.Window('Hello, world!');
 *
 * If you want to set a title you'd do the following:
 *
 *     var modal = new Zen.Window('Hello, world!', {title: 'My Window'});
 *
 * For a full list of options see Zen.Window.options.
 *
 * ## Buttons
 *
 * Buttons can be added by setting the "buttons" key in the options object to an
 * array of objects. Each object should have the following three keys:
 *
 * * name: the name of the button, also used as the class (should be unique).
 * * label: the text to display in the button.
 * * onClick: a function that will be called whenever the button is clicked.
 *   This function takes a single parameter which is set to the instance of the
 *   window the button belongs to.
 *
 * An example of setting a button can be seen below.
 *
 *     var modal = new Zen.Window(
 *         'A window with buttons',
 *         {
 *             buttons:
 *             [
 *                 {
 *                     name:    'close',
 *                     label:   'Close',
 *                     onClick: function(instance)
 *                     {
 *                         instance.destroy();
 *                     }
 *                 }
 *             ]
 *         }
 *     );
 *
 * @since  0.2.6
 */
Zen.Window = new Class(
{
    Implements: Options,

    /**
     * Object containing all the custom options as well as the ones specified by
     * the user.
     *
     * @since  0.2.6
     */
    options:
    {
        // The height of the window
        height: null,

        // The width of the window
        width:  400,

        // The title of the window, set to null for no title
        title:  null,

        // When set to true the window can be resized
        resize: false,

        // When set to true the user can drag the window around
        move: false,

        // A collection of buttons to display inside the window
        buttons:
        [
            {
                name:   'close',
                label:   Zen.translations['zen_general.buttons.close'],
                onClick: function(instance)
                {
                    instance.destroy();
                }
            }
        ]
    },

    /**
     * DOM element for the current window instance.
     *
     * @since  0.2.6
     */
    element: null,

    /**
     * The background overlay for the current window.
     *
     * @since 18-12-2011
     */
    overlay: null,

    /**
     * Creates a new instance of the class and displays the window.
     *
     * @since  0.2.6
     * @param  {string} content The content to display inside the window.
     * @param  {object} options Object containing a collection of custom options
     * for the window.
     */
    initialize: function(content, options)
    {
        if ( !content )
        {
            throw new SyntaxError("You need to specify the content to display.");
        }

        this.setOptions(options);

        var container = new Element('div',
        {
            'class': 'window',
            styles:
            {
                width:  this.options.width,
                height: this.options.height
            }
        });

        var body    = new Element('div', {'class': 'body', html: content});
        var current = this;

        // Do we have a title?
        if ( this.options.title !== null )
        {
            var header = new Element('div', {'class': 'header'});
            var title  = new Element('h2', {html: this.options.title});

            title.inject(header);
            header.inject(container);
        }

        body.inject(container);

        // Add all the buttons
        if ( this.options.buttons.length > 0 )
        {
            var buttons_container = new Element(
                'div',
                {'class': 'buttons'}
            );

            this.options.buttons.each(function(button)
            {
                var btn = new Element('button',
                {
                    text:    button.label,
                    'class': 'button ' + button.name
                });

                btn.addEvent('click', function()
                {
                    button.onClick(current);
                });

                btn.inject(buttons_container);
            });

            buttons_container.inject(container);
        }

        // Allow the window to be resized if this has been specified
        if ( this.options.resize === true )
        {
            container.addClass('resize');
            container.makeResizable();
        }

        if ( this.options.move === true )
        {
            container.addClass('move');
            container.makeDraggable();
        }

        // Set a negative margin so that the window can be aligned when
        // positioning it absolute.
        var margin = this.options.width - ( this.options.width * 1.5 );
        container.setStyle('margin-left', margin);

        if ( $$('.window_overlay').length <= 0 )
        {
            this.overlay = new Element('div', {'class': 'window_overlay'});
            this.overlay.inject(document.body);
        }

        // Last step: inject the HTML into the DOM
        this.element = container;
        this.element.inject(document.body);

    },

    /**
     * Removes the window from the DOM.
     *
     * @since  0.2.6
     */
    destroy: function()
    {
        this.element.destroy();

        if ( this.overlay )
        {
            this.overlay.destroy();
        }
    }
});
