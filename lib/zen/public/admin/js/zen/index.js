window.addEvent('domready', function()
{
    // Enable the automatic checking of all checkboxes in a table. 
    $$('table').each(function(table)
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

    /**
     * Create a new instance of the Tabs class. This will create a regular tab 
     * system for the CSS selector "div.tabs ul".
     */
    if ( $$('div.tabs ul').length > 0 && Zen.Tabs )
    {
        new Zen.Tabs('div.tabs ul');
    }
    
    /**
     * Initialize our editor for all elements with a class of "visual_editor" 
     * and retrieve the editor format from the attribute "data-format".
     */
    $$('.visual_editor').each(function(editor)
    {
        var markup = editor.get('data-format');

        if ( typeOf(markup) === 'undefined' )
        {
            markup = 'html';
        }

        Zen.Editor.create(markup, editor);
    });

    /**
     * Initializes a datepicker object whenever it's loaded and the correct 
     * element was found.
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
