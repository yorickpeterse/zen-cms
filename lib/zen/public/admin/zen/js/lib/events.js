"use strict";

/**
 * Adds support for the onhashchange event when using ``window.addEvent()``.
 *
 * Basic usage is as following:
 *
 *     window.addEvent('hashchange', function(e, hash)
 *     {
 *         console.log(hash);
 *     });
 *
 * Do note that this implementation does not offer any backwards compatibility
 * with browsers that don't natively support ``window.onhashchange``.
 *
 * @since 2011-12-21
 */
Element.Events.hashchange = {
    onAdd: function()
    {
        var _this = this;

        this.onhashchange = function()
        {
            this.fireEvent('hashchange');
        };
    }
};

/**
 * Adds support for the "invalid" event that is raised for invalid form fields.
 *
 * @since 2012-03-10
 */
Element.Events.invalid = {
    onAdd: function()
    {
        var _this = this;

        this.oninvalid = function()
        {
            _this.fireEvent('invalid');
        };
    }
};
