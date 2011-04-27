window.addEvent('domready', function()
{
    /**
     * Create a new instance of the Tabs class.
     * This will create a regular tab system for
     * the CSS selector "div.tabs ul".
     */
    new Zen.Tabs('div.tabs ul');
    
    /**
     * Show a notification whenever we find an error, success
     * or notice hash in the Zen.Flash object.
     */
    if ( Zen.Flash.notification )
    {
        new Zen.Notification(
        {
            title:   Zen.Flash.notification.title,
            content: Zen.Flash.notification.content,
            image:   Zen.Flash.notification.image,
            sticky:  Zen.Flash.notification.sticky
        });
    }
    
    /**
     * Enable the automatic checking of all checkboxes in a table with a class
     * of "table". Perhaps I'll use a class for this in the future but for now
     * this is good enough.
     */
    var tables = $$('.table');
    
    if ( tables.length > 0 )
    {
        tables.each(function(table)
        {
            var check_all = table.getElement('thead tr th:first-child input[type=checkbox]');
            
            check_all.addEvent('click', function()
            {
                var check_all_status = check_all.get('checked');
                
                tables.getElements('tbody tr td:first-child input[type=checkbox]').each(function(c)
                {
                    c.set('checked', check_all_status);
                });
            });
        });
    }
    
    /**
     * Initialize our editor for all elements with a class of "visual_editor" and retrieve
     * the editor format from the attribute "data-format".
     */
    if ( $$('.visual_editor').length > 0 )
    {
        new Zen.Editor.Base('.visual_editor[data-format="html"]',
        {
            format: 'html'
        }).display();

        new Zen.Editor.Base('.visual_editor[data-format="textile"]',
        {
            format: 'textile'
        }).display();

        new Zen.Editor.Base('.visual_editor[data-format="markdown"]',
        {
            format: 'markdown'
        }).display();
    }

    /**
     * Initializes a datepicker object whenever it's loaded and the correct element was found.
     */
    if ( typeof Picker != "undefined" && typeof Picker.Date != "undefined" )
    {
        new Picker.Date($$('form input[type="text"].date'),
        {
            timePicker:  true,
            pickerClass: 'datepicker',
            format:      '%Y-%m-%d %H:%M:%S'
        });
    }
});
