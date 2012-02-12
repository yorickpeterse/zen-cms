"use strict";

/**
 * Javascript file loaded by the Users package. The code in this file is used to
 * make it easier for users to check all the checkboxes for a package when
 * managing a user or user group's permissions.
 *
 * @since  0.3
 */
window.addEvent('domready', function()
{
    // Button that can be used to allow all the permissions for a package.
    $$('.package .button.allow').addEvent('click', function()
    {
        var checkboxes = this.getParent('.package')
            .getChildren('.permissions input[type="checkbox"]');

        checkboxes.each(function(checkbox)
        {
            checkbox.set('checked', true);
        });
    });

    // Button that can be used to deny all the permissions for a package.
    $$('.package .button.deny').addEvent('click', function()
    {
        var checkboxes = this.getParent('.package')
            .getChildren('.permissions input[type="checkbox"]');

        checkboxes.each(function(checkbox)
        {
            checkbox.set('checked', false);
        });
    });
});
