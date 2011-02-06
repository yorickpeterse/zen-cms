/**
 * Textile driver for the visual editor. This driver supports the following elements:
 *
 * * bold tags
 * * italic tags
 * * link tags
 * * ol tags 
 * * ul tags
 * 
 * @author    Yorick Peterse
 * @link      http://yorickpeterse.com/
 * @license   MIT License
 * @package   Zen
 * @since     0.1
 *
 * Copyright (c) 2011, Yorick Peterse
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */
Zen.Editor.Textile = new Class(
{
  /**
   * Inserts bold tags (*text*)
   *
   * @author Yorick Peterse
   * @param  [Object] editor instance of the editor to which this callback belongs.
   * @return [Void]
   */
  bold: function(editor)
  {
    editor.insertAroundCursor({before: '*', after: '*'});
  },
  
  /**
   * Inserts italic tags (_text_)
   *
   * @author Yorick Peterse
   * @param  [Object] editor instance of the editor to which this callback belongs.
   * @return [Void]
   */
  italic: function(editor)
  {
    editor.insertAroundCursor({before: '_', after: '_'});
  },
  
  /**
   * Inserts an anchor tag ("text":"url").
   *
   * @author Yorick Peterse
   * @param  [Object] editor instance of the editor to which this callback belongs.
   * @return [Void]
   */
  link: function(editor)
  {
    var link = prompt("URL");
    
    if ( link != '' && link != null )
    {
      editor.insertAroundCursor({before: '"', after: '":' + link}); 
    }
  },
  
  /**
   * Inserts an ordered list into the current text field
   * 
   * @author Yorick Peterse
   * @param  [Object] editor instance of the editor to which this callback belongs.
   * @return [Void]
   */
  ol: function(editor)
  {
    editor.insertAroundCursor({before: "\n# "});
  },
  
  /**
   * Inserts an unordered list into the current text field
   * 
   * @author Yorick Peterse
   * @param  [Object] editor instance of the editor to which this callback belongs.
   * @return [Void]
   */
  ul: function(editor)
  {
    editor.insertAroundCursor({before: "\n* "});
  }
});