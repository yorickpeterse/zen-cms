"use strict";

Zen = Zen || {};

/**
 * Widget that allows developers to create a tab based navigation menu.
 * The Tabs class supports both normal tabs (fields hidden based on their IDs)
 * as well as tabs loaded using Ajax.
 *
 * In order to use the Tab class you only need some very basic markup. You'll
 * need a list element (either ordered or unordered) that will contain all links
 * and a few divs in case you're using regular tabs that don't load their content
 * using Ajax. The most basic example looks like the following:
 *
 *     <ul class="tabs">
 *         <li>
 *             <a href="#tab1">Tab #1</a>
 *         </li>
 *     </ul>
 *
 *     <div id="tab1">
 *         <p>This is the content of tab #1.</p>
 *     </div>
 *
 * When using regular tabs it doesn't matter where you put the divs for the
 * tabs. However, when using the Ajax tabs it's important to remember that the
 * content will be inserted just after the closing tags of the unordered/ordered
 * list in a div with a class of "tab_content". Example:
 *
 *     <ul class="tabs">
 *         <li>
 *             <a href="#tab1">Tab #1</a>
 *         </li>
 *     </ul>
 *
 *     <div class="tab_content">
 *         <p>This is the content of tab #1 loaded using Ajax.</p>
 *     </div>
 *
 * ## Creating and Configuration
 *
 * Now that we know how the markup works, let's create some tabs. Doing this is
 * fairly easy and at a basic level only requires the following code:
 *
 *     Zen.Objects.MyTabs = new Zen.Tabs('css_selector_for_element');
 *
 * In this case we're creating a new instance of the Tabs class for an element
 * named "css_selector_for_element". The first argument is a simple CSS selector
 * that defines what element to choose. This means that you can either use a
 * class or ID name but also a more complicated selector like
 * "div > ul ul:first-child".
 *
 * Let's create another Tab instance but use some custom configuration options
 * this time.
 *
 *     Zen.Objects.MyTabs = new Zen.Tabs('ul.some_class_name',
 *     {
 *         default: 'li:last-child',
 *         ajax: false
 *     });
 *
 * As you can see there are  configuration items available.
 *
 * * default: The default tab/tab field to show. Again this is just a CSS
 *   selector so you can easily customize it.
 * * ajax: Boolean that indicates that the tabs should be loaded from an
 *   external page using Ajax.
 *
 * Special thanks to the guys from #mootools for helping me out :)
 *
 * @since  0.1
 */
Zen.Tabs = new Class(
{
    Implements: Options,

    /**
    * Object containing all options for each tab instance.
    *
    * @since  0.1
    * @var    {object}
    */
    options:
    {
        // The default tab/field to display
        'default': 'li:first-child',

        // Specifies if the content of each tab should be loaded using Ajax.
        ajax: false
    },

    /**
    * String that contains the CSS selector that specifies which element
    * should be used for creating the tabs.
    *
    * @since  0.1
    * @var    {object}
    */
    element: null,

    /**
    * Array that will contain a list of objects for each tab/field for the
    * current element. This array will be used when binding events to each
    * tab so that we don't have to search for these tabs/fields over and over
    * again.
    *
    * @since  0.1
    * @var    {array}
    */
    fields: [],

    /**
    * Constructor method called upon initialization. Options can be
    * set as a JSON object in the first argument.
    *
    * @since  0.1
    * @param  {string} element The element to use for creating the tabs.
    * @param  {object} options Custom options used when creating the tabs
    */
    initialize: function(element, options)
    {
        this.setOptions(options);

        // Ignore the tab system if the element couldn't be found
        if ( $$(element).length <= 0 )
        {
            return;
        }

        this.element = $$(element)[0];

        // We're good to go
        if ( this.options.ajax === false )
        {
            this.generalTabs();
        }
        else
        {
            this.ajaxTabs();
        }
    },

    /**
    * Generate a set of normal tabs that will load content that's already on the
    * page. In order for these tabs to work your URLs will need to point to an
    * element with an ID. These elements will be hidden and shown upon clicking
    * the corresponding tab.
    *
    * @since  0.1
    */
    generalTabs: function()
    {
        // Create a reference to the current instance so we can
        // use data in this instance in our events and loops.
        var self = this;

        // Select our default tab element
        var default_field = this.element.getElement(self.options['default']);
            default_field = default_field.getElement('a');
        var links         = this.element.getElements('li a');

        this.element.getElement(self.options['default']).addClass('active');

        links.each(function(link)
        {
            // Hide the corresponding element
            var url   = link.get('href');
            var field = $(url.replace('#', ''));

            // Check if the field actually exists and hide it if it's a non
            // default field.
            if ( field !== null && default_field !== link )
            {
                field.setStyle('display', 'none');
            }

            self.fields.push({url: url, field: field});

            // Add an event that will show the corresponding field for each link
            link.addEvent('click', function(event)
            {
                // Prevent normal behavior
                event.stop();

                self.element.getElement('li.active').removeClass('active');

                // Now we can add the class to the current tab
                this.getParent('li').addClass('active');

                // Toggle the state of each tab and ignore any non-existing
                // fields.
                self.fields.each(function(item)
                {
                    if ( item === null || item.field === null )
                    {
                        return;
                    }

                    if ( item.url === link.get('href') )
                    {
                        item.field.setStyle('display', 'block');
                    }
                    else
                    {
                        item.field.setStyle('display', 'none');
                    }
                });
            });
        });
    }
});
