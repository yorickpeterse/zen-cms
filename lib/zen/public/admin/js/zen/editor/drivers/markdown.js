/**
 * Markdown driver for the text editor that ships with Zen.
 *
 * @author    Yorick Peterse
 * @since     0.2.6
 * @namespace Zen
 * @extend    Editor
 */
Zen.Editor.Markdown = new Class(
{
    Extends: Zen.Editor,

    /**
     * Overrides Zen.Editor.bold.
     *
     * @author Yorick Peterse
     * @since  0.2.6
     * @param  [Element] editor The textarea to insert the tags into.
     */
    bold: function(editor)
    {
        editor.insertAroundCursor({before: '**', after: '**'});
    },

    /**
     * Overrides Zen.Editor.italic.
     *
     * @author Yorick Peterse
     * @since  0.2.6
     * @param  [Element] editor The textarea to insert the tags into.
     */
    italic: function(editor)
    {
        editor.insertAroundCursor({before: '*', after: '*'});
    },

    /**
     * Overrides Zen.Editor.link.
     *
     * @author Yorick Peterse
     * @since  0.2.6
     * @param  [Element] editor The textarea to insert the tags into.
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
     * @author Yorick Peterse
     * @since  0.2.6
     * @param  [Element] editor The textarea to insert the tags into.
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
     * @author Yorick Peterse
     * @since  0.2.6
     * @param  [Element] editor The textarea to insert the tags into.
     */
    ol: function(editor)
    {
        editor.insertAroundCursor(
        {
            before: "\n1. "
        });
    },
});
