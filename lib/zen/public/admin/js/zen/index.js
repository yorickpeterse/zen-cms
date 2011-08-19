window.addEvent('domready', function()
{
    $$('table').each(function(table)
    {
        new Zen.HtmlTable(table);
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
     * Initialize our editor for all elements with a class of "text_editor"
     * and retrieve the editor format from the attribute "data-format".
     */
    $$('.text_editor').each(function(editor)
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
            format:      Zen.date_format
        });
    }
});
