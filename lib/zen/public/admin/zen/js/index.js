"use strict";

window.addEvent('domready', function()
{
    $$('table:not(.no_sort)').each(function(table)
    {
        new Zen.HtmlTable(table);
    });

    // Create a new instance of the Tabs class. This will create a regular tab
    // system for the CSS selector "div.tabs ul".
    if ( $$('div.tabs ul').length > 0 && Zen.Tabs )
    {
        new Zen.Tabs('div.tabs ul');
    }

    // Initialize our editor for all elements with a class of "text_editor"
    // and retrieve the editor format from the attribute "data-format".
    $$('.text_editor').each(function(editor)
    {
        var markup = editor.get('data-format');

        if ( typeOf(markup) === 'undefined' )
        {
            markup = 'html';
        }

        Zen.Editor.create(markup, editor);
    });

    $$('input.date').each(function(el)
    {
        var format = el.get('data-date-format') || Zen.date_format;
        var time   = el.get('data-date-time');
        time       = (time && (time === '1' || time === 'true')) || false;
        var min    = el.get('data-date-min');
        var max    = el.get('data-date-max');

        new Picker.Date(el,
        {
            timePicker:  time,
            pickerClass: 'datepicker',
            format:      format,
            draggable:   false,
            minDate:     min,
            maxDate:     max
        });
    });

    $$('form:not(#search_form)').each(function(form)
    {
        new Zen.Form(form);
    });
});
