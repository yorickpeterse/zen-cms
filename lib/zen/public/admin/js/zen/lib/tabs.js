"use strict";

Zen = Zen || {};

/**
 * Zen.Tabs is a Mootools class for rendering tab based navigation menus. Tabs
 * managed by this class can be activated by both clicking on the various tabs
 * or by changing the URL hash (clicking a tab actually does the latter).
 *
 * The use of URL hashes (stored in ``window.location.hash``) also make it
 * possible for non default tabs to be set as the active tab whenever a page is
 * reloaded.  If no URL hash is set then a CSS selector will be used to
 * determine the default tab field to activate. If there is a URL hash present
 * that will be used instead.
 *
 * For example, take the following URL:
 *
 * * http://hello.com/admin/extensions/
 *
 * and the following tab fields (where each item is the ID of the field):
 *
 * * packages
 * * themes
 * * languages
 *
 * These fields could be activated by navigating to one of the following URLs
 * (or just by clicking the corresponding tab which will then do this for you):
 *
 * * http://hello.com/admin/extensions#packages
 * * http://hello.com/admin/extensions#themes
 * * http://hello.com/admin/extensions#languages
 *
 * ## General Usage
 *
 * Using this class is pretty straight forward, just create a new instance of it
 * and pass a CSS selector to the constructor:
 *
 *     new Zen.Tabs('.tabs ul');
 *
 * If you want to change any options you can set these as the second parameter:
 *
 *     new Zen.Tabs('.tabs ul', {'default': 'li:last-child'});
 *
 * ## Options
 *
 * * default: a CSS selector that should result in a ``<li>`` element to
 *   activate by default if no ID is specified in the URL hash.
 */
Zen.Tabs = new Class(
{
    Implements: Options,

    /**
     * Object containing all options for each tab instance.
     *
     * @since 0.1
     */
    options:
    {
        // The default tab/field to display
        'default': 'li:first-child',
    },

    /**
     * Contains the element that contains all the tab items.
     *
     * @since 0.1
     */
    element: null,

    /**
    * Constructor method called upon initialization. Options can be
    * set as a JSON object in the first argument.
    *
    * @since  0.1
    * @param  {string} selector A CSS selector that should result in a ``<ul>``
    *  element containing various tabs.
    * @param  {object} options Custom options used when creating the tabs
    */
    initialize: function(selector, options)
    {
        this.setOptions(options);

        var found = $$(selector);

        if ( found.length <= 0 )
        {
            throw new Error(
                'No elements could be found for the selector ' + selector
            );
        }

        this.element = found[0];

        this.displayDefault();
        this.addEvents();
    },

    /**
     * Binds various events to show the right tab fields when a tab is clicked
     * or when the URL hash is changed.
     *
     * @since 21-12-2011
     */
    addEvents: function()
    {
        var _this = this;

        // Only bind the event if the browser doesn't support the onhashchange
        // event.
        if ( !"onhashchange" in window )
        {
            this.element.getElements('a').addEvent('click', function(e)
            {
                e.stop();

                window.location.hash = this.get('href');
                window.fireEvent('hashchange');
            });
        }

        window.addEvent('hashchange', function()
        {
            var id = new Zen.Hash(window.location.hash).segments[0];

            if ( id && $(id) )
            {
                _this.toggleTab(id);
            }
        });
    },

    /**
     * Determines the default tab field to display based on the option
     * ``this.options.default`` or the current hash URL.
     *
     * @since 21-12-2011
     */
    displayDefault: function()
    {
        var id = null;

        // Don't bother parsing the URL hash if there is none to begin with.
        if ( window.location.hash && window.location.hash.length > 0 )
        {
            id = new Zen.Hash(window.location.hash).segments[0];
        }

        if ( !id || id.length <= 0 )
        {
            var active = this.element.getElements(this.options['default']);

            if ( active.length > 0 )
            {
                active[0].addClass('active');

                id = active[0].getElement('a').get('href').replace(/^#/, '');
            }
        }

        this.toggleTab(id);
    },

    /**
     * Activates the tab field for the given ID.
     *
     * @since 21-12-2011
     * @param {string} id The ID of the tab field to show.
     */
    toggleTab: function(id)
    {
        this.element.getElements('a').each(function(el)
        {
            var el_id = el.get('href').replace(/^#/, '');

            if ( el_id === id )
            {
                el.getParent().addClass('active');

                var found = $(id);

                if ( found ) found.show();
            }
            else
            {
                el.getParent().removeClass('active');

                var found = $(el_id);

                if ( found ) found.hide();
            }
        });
    },
});
