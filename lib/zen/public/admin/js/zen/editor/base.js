Zen.Editor = {}

/**
 * The Editor class can be used to create simple text editors that support HTML,
 * Textile and Markdown (more might be supported in the future). The generated
 * output is very simple and very easy to style (the class doesn't inject any CSS).
 * 
 * h2. Usage
 *
 * Adding an editor requires 2 steps. First you'll need to create a new instance
 * of the editor:
 *
 * bc. editor = new Zen.Editor.Base('css selector');
 *
 * Once the instance is created you can call the display() method to show the editor:
 *
 * bc. editor.display();
 *
 * This will render the editor using the default format, HTML.
 *
 * h2. Customizing
 *
 * By default the editor will generate HTML tags but this can be changed by passing
 * a JSON object as the second argument of the constructor method:
 *
 * bc. editor = new Zen.Editor.Base('css selector', {format: '...'});
 *
 * The second argument accepts the following 2 options:
 *
 * format: the formatting engine to use. You can choose from "html" (default),
 * "textile" and "markdown". You can also create your own driver as long as you make
 * sure the class is loaded and defined under Zen.Editor.DriverName, where DriverName
 * is the PascalCased version of the driver name.
 * 
 * buttons: an array of default buttons. Note that in most cased you'd want to use the
 * addButtons() method as specifying an array of buttons in the constructor will prevent
 * the default buttons from being added.
 *
 * h2. Adding Buttons
 *
 * The recommended way of adding buttons is using the addButtons method. This method takes
 * a single argument which is an array of JSON objects. Each JSON object should contain the
 * following keys:
 *
 * * name: the name of the button, used to generate the CSS class
 * * html: the content of the button (text, html, etc)
 * * callback: the function/method called whenever the button is clicked.
 *
 * Example:
 *
 * bc. editor.addButtons(
 * [
 *   {name: 'hello', html: 'Hello', callback: function() { alert('Hello!'); }}
 * ]);
 *
 * When the callback is invoked the instance of the editor to which the button belongs will
 * be sent to the callback.
 *
 * h2. Drivers
 *
 * The Base class relies on so called "drivers": small classes that handle actions
 * whenever a button is clicked. By default there are 3 drivers, HTML, Textile and Markdown.
 * In order to use your own driver while still supporting the default buttons (bold, italic, etc)
 * your class has to implement the following methods:
 *
 * * bold
 * * italic
 * * link
 * * ol 
 * * ul
 *
 * When creating a method for a driver they should accept a single parameter, the instance
 * of the editor to which the button belongs. Say your button wraps the currently selected
 * text in an element you'd do something like the following:
 *
 * bc. my_method: function(editor)
 * {
 *   editor.insertAroundCursor({before: '<', after: '>'})
 * }
 *
 * Also keep in mind that you don't have to create an entire class, you can also specify
 * a closure in the "callback" key when adding a button.
 *
 * h2. Markup
 *
 * The Editor class generates the following markup:
 *
 * bc. <div class="editor_container">
 *   <div class="editor_toolbar">
 *     <ul>
 *       <li class="button name">button HTML</li>
 *     </ul>
 *   </div>
 *
 *   <textarea></textarea>
 * </div>
 *
 * As you can see the markup is very simple and no CSS rules are injected. This does however
 * mean you generally spend a bit more time styling the editor but it also gives
 * you much more flexibility and less trouble.
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
Zen.Editor.Base = new Class(
{
  Implements: Options,
  
  /**
   * JSON object with all default options.
   * The following options are available:
   *
   * * format: the text format (textile, markdown, etc)
   * * buttons: Array of all buttons and their callbacks.
   * Note that by default this object is empty, all buttons will be
   * added by the initialize() method as the callbacks won't be available
   * until the drivers have been loaded.
   *
   * @type [Object]
   */
  options:
  {
    format: 'html',
    buttons: []
  },
  
  /**
   * Collection of objects for the CSS selector specified
   * when initializing this class.
   *
   * @type [Array]
   */
  elements: [],
  
  /**
   * New instance of the driver for the current editor.
   *
   * @type [Object]
   */
  driver: {},
  
  /**
   * Initializes a new instance of the visual editor. The first
   * argument is the CSS selector and the second a JSON object
   * with additional options.
   *
   * @author Yorick Peterse
   * @param  [String] css_selector The CSS selector for the editor.
   * @param  [Ojbect] options JSON object with additional options.
   * @return [Object]
   * @since  0.1
   */
  initialize: function(css_selector, options)
  {
    this.setOptions(options);
    
    this.elements = $$(css_selector);
    
    // Load our driver
    var driver  = this.options.format.capitalize().camelCase();
    this.driver = new Zen.Editor[driver]();
    
    // Add our buttons
    if ( this.options.buttons.length <= 0 )
    {
      this.options.buttons = [
        {name: 'bold'   , html: 'Bold'   , callback: this.driver.bold},
        {name: 'italic' , html: 'Italic' , callback: this.driver.italic},
        {name: 'link'   , html: 'Link'   , callback: this.driver.link},
        {name: 'ol'     , html: 'Ordered list'  , callback: this.driver.ol},
        {name: 'ul'     , html: 'Unordered list', callback: this.driver.ul}
      ]; 
    }
  },
  
  /**
   * Generates the required markup for the editor along
   * with binding all events for all the available buttons.
   * 
   * @author Yorick Peterse
   * @return [Void]
   */
  display: function()
  {
    // Ignore the entire process if no elements have been found
    if ( this.elements.length == 0 ) { return; }
    
    // Generate our markup
    var toolbar   = new Element('div', {'class': 'editor_toolbar'});
    var ul        = new Element('ul');
    
    // Generate all the buttons
    this.options.buttons.each(function(btn)
    {
      var li = new Element('li', {'class': btn.name});
      
      // Add the html?
      if ( btn.html ) { li.set('html', btn.html); }
      
      li.addEvent('click', function()
      {
        // Get the editor closest to this button
        var current_editor = this.getParent('.editor_container');
            current_editor = current_editor.getElement('textarea');

        btn.callback(current_editor);
      });
      
      li.inject(ul);
    });
    
    this.elements.each(function(element)
    {
      var container = new Element('div', {'class': 'editor_container'});
      
      // Replace the text area with all our elements
      ul.inject(toolbar);
      toolbar.inject(container);
      container.inject(element, 'before');
      element.inject(container);
    });
  },
  
  /**
   * Adds the specified buttons to this.options.buttons.
   * Buttons can also be added by directly setting them in the construct
   * but that will prevent the default buttons from getting added.
   *
   * @author Yorick Peterse
   * @param  [Array] buttons An array of the buttons to add
   * @return [Void]
   */
  addButtons: function(buttons)
  {
    var self = this;
    
    buttons.each(function(button)
    {
      self.options.buttons.push(button);
    });
  }
});