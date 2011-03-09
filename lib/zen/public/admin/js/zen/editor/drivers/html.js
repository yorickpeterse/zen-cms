/**
 * HTML driver for the visual editor. This driver supports the following elements:
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
Zen.Editor.Html = new Class(
{
    /**
     * Replaces the selected text or inserts a block
     * of <strong> tags.
     *
     * @author Yorick Peterse
     * @since  0.1
     * @param  {object} editor instance of the editor to which this callback belongs.
     * @return {void}
     */
    bold: function(editor)
    {
        editor.insertAroundCursor({before: '<strong>', after: '</strong>'});
    },
    
    /**
     * Inserts a block of italic tags at the current cursor or
     * around the currently selected text.
     *
     * @author Yorick Peterse
     * @since  0.1
     * @param  {object} editor instance of the editor to which this callback belongs.
     * @return {void}
     */
    italic: function(editor)
    {
        editor.insertAroundCursor({before: '<em>', after: '</em>'});
    },
    
    /**
     * Inserts an anchor tag.
     *
     * @author Yorick Peterse
     * @since  0.1
     * @param  {object} editor instance of the editor to which this callback belongs.
     * @return {void}
     */
    link: function(editor)
    {
        var link = prompt("URL");
      
        if ( link != '' && link != null )
        {
            editor.insertAroundCursor({before: '<a href="' + link + '">', after: '</a>'}); 
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
        editor.insertAroundCursor({before: "<ol>\n", after: "\n</ol>"});
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
        editor.insertAroundCursor({before: "<ul>\n", after: "\n</ul>"});
    }
});
