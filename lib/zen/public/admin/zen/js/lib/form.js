"use strict";

namespace('Zen');

/**
 * Zen.Form is a class used for adding various dynamic features to HTML forms
 * such as automatically saving the data and handling validation errors using
 * the HTML5 constraints API.
 *
 * For the features related to the HTML5 constraints API to work properly users
 * should be using a modern browser. If this API is not implemented it will be
 * silently ignored. Automatically saving data is supported regardless of the
 * existence of this API and is handled by Zen.Autosave.
 *
 * ## Usage
 *
 * In order to use this class you'll have to create a new instance of it and
 * pass an instance of Element to it (an instance for a ``<form>`` element):
 *
 *     new Zen.Form($('my_form'));
 *
 * By passing and object to the second parameter you can customize various parts
 * of this class. The following options are available:
 *
 * * autosave_attribute: name of the attribute that contains the URL to send
 *   requests to when automatically saving form data. This option is set to
 *   "data-autosave-url" by default.
 * * tabs_selector: a CSS selector used to determine the tabs for the form, set
 *   to "div.tabs ul" by default.
 * * error_class: the primary class to use for error indicators in a tab, set to
 *   "tab_error" by default.
 *
 * An example of setting one of these options is the following:
 *
 *     new Zen.Form($('my_form'), {error_class: 'custom_tab_error'});
 *
 * Keep in mind that out of the box there's no need to manually use this class,
 * Zen already does this for you.
 *
 * ## Tabs and Errors
 *
 * This class makes it easier for users to nice form errors. This is achieved by
 * showing a small error icon in a tab of which the corresponding tab field
 * contains a number of invalid form elements. For this to work properly you
 * should add the class "tab_field" to each tab field:
 *
 *     <div id="general" class="tab_field">
 *         <!-- Tab field's content -->
 *     </div>
 *
 * @since 2012-03-12
 */
Zen.Form = new Class(
{
    Implements: Options,

    /**
     * The form element for this class.
     *
     * @since 2012-03-12
     */
    element: null,

    /**
     * Object containing the default and custom defined options merged together.
     *
     * @since 2012-03-12
     */
    options:
    {
        // String containing the name of the attribute that contains the URL to
        // use for automatically saving forms.
        autosave_attribute: 'data-autosave-url',

        // CSS selector to use for matching the list container of a set of
        // tabs.
        tabs_selector: 'div.tabs ul',

        // The class to apply to the error indicators.
        error_class: 'tab_error'
    },

    /**
     * Creates and prepares a new instance of the class.
     *
     * @since 2012-03-12
     * @param {Element} element The form element to use for the instance of this
     *  class.
     * @param {Object} options An object containing custom options to use for
     *  a particular instance of this class.
     */
    initialize: function(element, options)
    {
        if ( typeOf(element) !== 'element' )
        {
            throw new TypeError(
                'Expected an element as the first parameter but got '
                    + typeOf(element)
                    + ' instead'
            );
        }

        this.setOptions(options);

        this.element = element;

        var _this    = this;
        var autosave = this.element.get(this.options.autosave_attribute);

        if ( autosave )
        {
            new Zen.Autosave(this.element, autosave);
        }

        // Don't bother with the errors and such if the browser vendor is too
        // lazy to properly implement the HTML5 specification.
        if ( !this.element.checkValidity ) return;

        // Don't bother with the validation bit if the form has no tab fields
        // either.
        if ( this.element.getElements('.tab_field').length <= 0 ) return;

        this.element.getElements('*').each(function(el)
        {
            var type       = el.get('type');
            var event_name = 'blur';

            // Ignore hidden fields
            if ( type === 'hidden' ) return;

            // Checkboxes and radio buttons don't call the "blur" event,
            // they instead use "change".
            if ( type === 'checkbox' || type === 'radio' )
            {
                event_name = 'change';
            }

            el.addEvent('invalid', function()
            {
                _this.invalidElement(this);
            });

            el.addEvent(event_name, function()
            {
                _this.blurElement(this);
            });
        });
    },

    /**
     * Handles the "invalid" event of individual form elements. In case an
     * element is invalid a small icon indicating that there is invalid data
     * will be displayed in the tab the field belongs to.
     *
     * @since 2012-03-12
     * @param {Element} element The invalid form element.
     */
    invalidElement: function(element)
    {
        var tab = this.getTab(element);

        if ( !tab ) return;

        var li = tab.getParent('li');

        if ( li.getElements('.' + this.options.error_class).length <= 0 )
        {
            var error = new Element('span',
            {
                'class': this.options.error_class + ' icon error'
            });

            error.inject(tab, 'before');
        }
    },

    /**
     * Handles the "blur" event of an individual form element. This event is
     * used to check if all the errors in a tab field are gone and if so will
     * remove the error indicator.
     *
     * @since 2012-03-12
     * @param {Element} element The form element that lost focus.
     */
    blurElement: function(element)
    {
        var field = element.getParent('.tab_field');

        if ( !field ) return;

        if ( field.getElements(':invalid').length <= 0 )
        {
            var tab = this.getTab(element);

            if ( !tab ) return;

            // Get the error indicator and remove it if needed.
            var error = tab.getParent('li')
                .getElement('.' + this.options.error_class);

            if ( error )
            {
                error.destroy();
            }
        }
    },

    /**
     * Given a form element (or any other kind of element in a form) this method
     * will try to retrieve the tab field the element belongs to.
     *
     * @since  2012-03-12
     * @param  {Element} element The element for which to retrieve the tab
     *  field.
     * @return {Element|null}
     */
    getTab: function(element)
    {
        var field = element.getParent('.tab_field');
        var tabs  = $$(this.options.tabs_selector);

        if ( tabs.length <= 0 || !field )
        {
            return null;
        }

        return tabs[0].getElement('a[href="#' + field.get('id') + '"]');
    },
});
