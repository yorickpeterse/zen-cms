/**
 * The Modal class is a very simple Mootools class that can be used to create
 * modal windows. The class itself does not apply any CSS styles, it only adds
 * a few IDs/classes. All styling should be done in separate CSS files.
 *
 * h2. Basic Usage
 *
 * Using this class is super-duper simple:
 *
 * bc. new Modal("Hello, world!");
 *
 * That creates a container, a background div and the actual modal window
 * along with the specified content. It doesn't matter what kind of content
 * you're trying to add as long as it's valid HTML you're good to go.
 * For example, an image could be shown as following:
 *
 * bc. new Modal($('some_image_id'))
 *
 * Note that iFrames are not supported simply because I never had the need for them.
 * If you want to load remote data you'd have to do some processing before generating
 * the modal window:
 *
 * bc. var iframe = new Element('iframe', {src: 'url/of/iframe'});
 * new Modal(iframe);
 *
 * This class also does not animate the modals, this should also be handled by CSS
 * and can be done quite easily using CSS3.
 *
 * h2. Closing Modal Windows
 *
 * The Modal class will add a div element with an id of "modal_close" to the modal window.
 * Whenever this element is clicked the callback specified in options.callback will be triggered.
 *
 * h2. HTML
 *
 * The Modal class generates the following HTML:
 *
 * bc. <div id="modal_container">
 *   <div id="modal_window">
 *     <div id="modal_close"></div>
 *     <!-- Content goes here -->
 *   </div>
 * </div>
 * <div id="modal_background"></div>
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
Zen.Modal = new Class(
{
  Implements: Options,
  
  /**
   * Object containing all default options for each modal window.
   * The following options are available:
   *
   * * height: specifies the width of the window (pixels, em, etc)
   * * width: specifies the height of the modal window
   * * fullscreen: specifies if the modal window should have a class of "fullscreen".
   * * callback: an event that's triggered whenever the close element is clicked.
   *
   * @var object
   */
  options: {
    height:      '200px',
    width:       '200px',
    fullscreen:  false,
    callback:     function()
    {
      // Remove all elements
      $('modal_background').destroy();
      $('modal_container').destroy();
    }
  },
  
  /**
   * Creates a new instance of the modal window and shows it.
   * Basic usage is as following:
   *
   * bc. modal = new Modal("Hello, world!");
   *
   * If you want to specify any additional options you can do so as following:
   *
   * bc. modal = new Modal("Hello, world!", {fullscreen: true});
   *
   * Note that calling this method will also show the message rather than just
   * initializing the class.
   *
   * @author Yorick Peterse
   * @param  [String] content The content to display inside the modal window.
   * @param  [Object] options JSON object containing all custom options.
   * @return [Object]
   */
  initialize: function(content, options)
  {
    this.setOptions(options);
    
    if ( this.options.fullscreen == true )
    {
      var modal_class = "fullscreen";
    }
    else
    {
      var modal_class = null; 
    }
    
    var styles = {width: this.options.width, height: this.options.height};
    
    // Create our base elements
    var modal_container  = new Element('div', {id: 'modal_container'});
    var modal_window     = new Element('div', {id: 'modal_window', 'class': modal_class});
    var modal_close      = new Element('div', {id: 'modal_close'});
    var modal_background = new Element('div', {id: 'modal_background'});
    
    // Strings will be inserted using the html() method. Other elements
    // will be injected into the modal window.
    if ( typeof content == "string" )
    {
      modal_window.set('html', content);
    }
    else
    {
      modal_window.adopt(content.clone());
    }
    
    // Inject the close button
    modal_close.inject(modal_window);
    
    // Bind the events
    modal_close.addEvent('click', this.options.callback);
    
    modal_window.inject(modal_container);
    modal_background.inject(document.body);
    modal_container.inject(document.body);
  }
});