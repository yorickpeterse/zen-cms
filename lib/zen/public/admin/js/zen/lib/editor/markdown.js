"use strict";

Zen        = Zen        || {};
Zen.Editor = Zen.Editor || {};

/**
 * Markdown driver for the text editor that ships with Zen.
 *
 * @since  0.2.6
 */
Zen.Editor.Markdown = new Class(
{
    Extends: Zen.Editor,

    /**
     * Overrides Zen.Editor.bold.
     *
     * @since  0.2.6
     * @param  {element} editor The textarea to insert the tags into.
     */
    bold: function(editor)
    {
        editor.insertAroundCursor({before: '**', after: '**'});
    },

    /**
     * Overrides Zen.Editor.italic.
     *
     * @since  0.2.6
     * @param  {element} editor The textarea to insert the tags into.
     */
    italic: function(editor)
    {
        editor.insertAroundCursor({before: '*', after: '*'});
    },

    /**
     * Overrides Zen.Editor.link.
     *
     * @since  0.2.6
     * @param  {element} editor The textarea to insert the tags into.
     */
    link: function(editor)
    {
        var link = prompt('URL', 'http://');

        editor.insertAroundCursor(
        {
            before: '[',
            after:  '](' + link + ')'
        });
    },

    /**
     * Overrides Zen.Editor.ul.
     *
     * @since  0.2.6
     * @param  {element} editor The textarea to insert the tags into.
     */
    ul: function(editor)
    {
        editor.insertAroundCursor(
        {
            before: "\n* "
        });
    },

    /**
     * Overrides Zen.Editor.ol.
     *
     * @since  0.2.6
     * @param  {element} editor The textarea to insert the tags into.
     */
    ol: function(editor)
    {
        editor.insertAroundCursor(
        {
            before: "\n1. "
        });
    }
});
