"use strict";

namespace('Zen');

/**
 * Zen.Autosave automatically saves form data at a given interval. Automatically
 * saving form data makes it more pleasant for users to work with their data as
 * the risk of data loss is minimized.
 *
 * Basic usage of this class is as following:
 *
 *     new Zen.Autosave(
 *         $('my_form'),
 *         'http://localhost/admin/category-groups/autosave'
 *     );
 *
 * When creating a new instance of this class you are required to specify a
 * single Element instance as well as the URL to submit the data to. The element
 * is specified as the first parameter, the URL as the second one. The optional
 * third parameter can be used for setting optional options such as the interval
 * and the HTTP method to use for submitting the data.
 *
 * By default the interval is set to 10 minutes, this can be changed as
 * following:
 *
 *     new Zen.Autosave(element, url, {interval: 300000});
 *
 * This would cause the form data to be saved every 5 minutes instead of every
 * 10 minutes.
 *
 * This class only submits forms for existing objects, this is based on the
 * value of the primary column. By default the name for this column is set to
 * "id" but this can be changed as following:
 *
 *     new Zen.Autosave(element, url, {primary: 'my_id'});
 *
 * If the field with this name has a non empty value then the form will be
 * submitted at a given interval, otherwise it will be ignored.
 *
 * @since 2012-02-15
 */
Zen.Autosave = new Class(
{
    Implements: Options,

    /**
     * Element containing the form element.
     *
     * @since 2012-02-16
     */
    element: null,

    /**
     * The URL to submit the data to.
     *
     * @since 2012-02-16
     */
    url: null,

    /**
     * Object containing various options to customize the auto saving behaviour.
     *
     * @since 2012-02-16
     */
    options:
    {
        // The amount of miliseconds to wait between each save.
        interval: 600000,

        // The HTTP method to use for submitting the data.
        method: 'POST',

        // The name of the field that contains the primary value of an object.
        primary: 'id'
    },

    /**
     * Creates a new instance of the class.
     *
     * @since 2012-02-16
     * @param {Element} element The form element to submit.
     * @param {String} url The URL to submit the data to.
     * @param {Object} options Object containing custom options. See
     *  Zen.Autosave.options for more information.
     */
    initialize: function(element, url, options)
    {
        this.setOptions(options);

        if ( typeOf(url) !== 'string' )
        {
            throw new TypeError(
                'You have to specify an instance of String for the URL'
            );
        }

        this.element = element;
        this.url     = url;
        var _this    = this;
        var primary  = element
            .getElement('input[name="' + this.options.primary + '"]');

        if ( !primary || primary.get('value').length <= 0 )
        {
            return;
        }

        setInterval(function() { _this.sendRequest() }, this.options.interval);
    },

    /**
     * Submits the form data to the server. Upon success the CSRF token is
     * updated, upon failure the validation errors will be displayed.
     *
     * @since 2012-02-16
     */
    sendRequest: function()
    {
        var _this   = this;
        var request = new Request.JSON(
        {
            url:       this.url,
            method:    this.options.method,
            data:      this.element.toQueryString(),
            onSuccess: function(response)
            {
                _this.setToken(response.csrf_token);
                _this.element.getElements('span.error').destroy();
            },
            onFailure: function(xhr)
            {
                var response = JSON.decode(xhr.responseText);

                _this.displayErrors(response.errors);
            }
        });

        request.send();
    },

    /**
     * Displays the validation errors of a set of fields.
     *
     * @since 2012-02-16
     * @param {Object} form_errors Object containing the form errors. The keys
     *  should be the names of the fields and the values arrays of error messages
     *  to display.
     */
    displayErrors: function(form_errors)
    {
        var _this = this;

        Object.each(form_errors, function(errors, field)
        {
            var label = _this.element
                .getElement('input[name="' + field + '"]')
                .getSiblings('label')[0];

            if ( label.getElements('span.error').length === 0 )
            {
                errors.each(function(error)
                {
                    var span = new Element('span',
                    {
                        'class': 'error',
                        html:    error
                    });

                    span.inject(label);
                });
            }
        });
    },

    /**
     * Updates the CSRF token with the given value.
     *
     * @since 2012-02-16
     * @param {String} token The new CSRF token.
     */
    setToken: function(token)
    {
        this.element.getElement('input[name="csrf_token"]').set('value', token);
    }
});
