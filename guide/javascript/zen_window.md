# @title Zen.Window
# Zen.Window

The Window class can be used to display modal windows with (or without) a set of
custom buttons. These windows can be used for displaying pictures, confirmation
messages and so on. In order to display a window you'll need to create a new
instance of the class. The syntax of this looks like the following:

    var some_window = new Zen.Window(content[, options]);

<div class="note deprecated">
    <p>
        <strong>Warning</strong>: When creating an instance of Zen.Window you
        should never save it in a variable named "window" as this is a reserved
        variable that refers to the browser window.
    </p>
</div>

The first parameter is the content to display and can either be plain text or
HTML. The second parameter is an object containing various options that can be
used to customize the window. The following options can be set in this object:

* height: a number indicating a fixed height to use for the window.
* width: the same but for the width.
* title: the title to display in the title bar containing the close button.
* resize: boolean that when set to true allows the user to resize the window.
* move: boolean that when set to true allows the user to move the window around.
* buttons: an array of buttons to display at the bottom of the window.

Creating a new window with some of these options would look something like the
following:

    var some_window = new Zen.Window('Hello, world!', {title: 'This is a window!'});

Note that you're not required to call any extra methods, the window will be
displayed whenever a new instance of the window is created.

Buttons can be added by setting the "buttons" option to an array of objects of
which each object has the following format:

    {
      name:   'foobar',
      label:  'Foobar',
      onClick: function() {}
    }

* name: the name of the button, should be unique as it's used for the class of
  the ``li`` element of the button.
* label: the text displayed in the button.
* onClick: a function that will be called whenever the button is clicked.
