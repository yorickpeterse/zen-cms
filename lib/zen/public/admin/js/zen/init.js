window.addEvent('domready', function()
{
    /**
     * Show a notification whenever we find an error, success or notice hash in the 
     * Zen.Flash object.
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
     * Enable the automatic checking of all checkboxes in a table with a class of "table". 
     * Perhaps I'll use a class for this in the future but for now this is good enough.
     */
    var tables = $$('.table');
    
    if ( tables.length > 0 )
    {
        tables.each(function(table)
        {
            var check_all = table.getElement(
                'thead tr th:first-child input[type=checkbox]'
            );
            
            check_all.addEvent('click', function()
            {
                var check_all_status = check_all.get('checked');
                
                tables.getElements(
                    'tbody tr td:first-child input[type=checkbox]'
                ).each(function(c)
                {
                    c.set('checked', check_all_status);
                });
            });
        });
    }

    /**
     * Create a new instance of the Tabs class. This will create a regular tab system for
     * the CSS selector "div.tabs ul".
     */
    var tab_selector = 'div.tabs ul';
    var tab_elements = $$(tab_selector).length;

    // Double check there are any elements
    if ( tab_elements > 0 )
    {
        new Zen.Tabs(tab_selector);
    }
    
    /**
     * Initialize our editor for all elements with a class of "visual_editor" and 
     * retrieve the editor format from the attribute "data-format".
     */
    var editor_elements = $$('.visual_editor');

    if ( editor_elements.length > 0 )
    {
        editor_elements.each(function(editor)
        {
            var markup = editor.get('data-format');

            if ( typeOf(markup) === 'undefined' )
            {
                markup = 'html';
            }

            Zen.Editor.init(markup, editor);
        });
    }

    /**
     * Initializes a datepicker object whenever it's loaded and the correct element was 
     * found.
     */
    var date_elements = $$('input[type="text"].date');

    if ( date_elements.length > 0 )
    {
        new Picker.Date(date_elements,
        {
            timePicker:  true,
            pickerClass: 'datepicker',
            format:      '%Y-%m-%d %H:%M:%S'
        });
    }
});
