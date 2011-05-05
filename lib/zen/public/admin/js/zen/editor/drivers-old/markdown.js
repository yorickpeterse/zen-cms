/**
 * Markdown driver for the visual editor. This driver supports the following elements:
 *
 * * bold tags
 * * italic tags
 * * link tags
 * * ol tags 
 * * ul tags
 * 
 * @author   Yorick Peterse
 * @link     http://yorickpeterse.com/ Yorick Peterse's Website
 * @link     http://zen-cms.com/ Zen Website
 * @license  http://code.yorickpeterse.com/license.txt The MIT license
 * @since    0.1
 */
Zen.Editor.Markdown = new Class(
{
    /**
     * Inserts bold tags (*text*)
     *
     * @author Yorick Peterse
     * @since  0.1
     * @param  {object} editor instance of the editor to which this callback belongs.
     * @return {void}
     */
    bold: function(editor)
    {
        editor.insertAroundCursor({before: '**', after: '**'});
    },
    
    /**
     * Inserts italic tags (_text_)
     *
     * @author Yorick Peterse
     * @since  0.1
     * @param  {object} editor instance of the editor to which this callback belongs.
     * @return {void}
     */
    italic: function(editor)
    {
        editor.insertAroundCursor({before: '_', after: '_'});
    },
    
    /**
     * Inserts an anchor tag ("text":"url").
     *
     * @author Yorick Peterse
     * @since  0.1
     * @param  {object} editor instance of the editor to which this callback belongs.
     * @return {void}
     */
    link: function(editor)
    {
        var link = prompt("URL");
      
        if ( link !== '' && link != null )
        {
            editor.insertAroundCursor({before: '[', after: '](' + link + ')'}); 
        }
    },
    
    /**
     * Inserts an ordered list into the current text field
     * 
     * @author Yorick Peterse
     * @since  0.1
     * @param  {object} editor instance of the editor to which this callback belongs.
     * @return {void}
     */
    ol: function(editor)
    {
        editor.insertAroundCursor({before: "\n1. "});
    },
    
    /**
     * Inserts an unordered list into the current text field
     * 
     * @author Yorick Peterse
     * @since  0.1
     * @param  {object} editor instance of the editor to which this callback belongs.
     * @return {void}
     */
    ul: function(editor)
    {
        editor.insertAroundCursor({before: "\n* "});
    }
});
