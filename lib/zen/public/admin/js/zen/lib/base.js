"use strict";

/**
 * Turns the specified string into an object (and sub objects) that can be used
 * to namespace classes and other data.
 *
 * Basic usage:
 *
 *     console.log(Foo); // => ReferenceError
 *
 *     namespace('Foo.Bar.Baz');
 *
 *     console.log(Foo); // => {Bar: {Baz: {}}}
 *
 * If segments of the namespace already exist they will remain untouched, this
 * function merely creates non existing segments.
 *
 * @example
 *  namespace('Zen.Editor');
 *
 *  Zen.Editor.Markdown = new Class(...);
 *
 * @since 22-12-2011
 * @param {string} name The namespace to create.
 */
function namespace(name)
{
    var stack = window;

    name.split('.').each(function(segment)
    {
        stack[segment] = stack[segment] || {};
        stack          = stack[segment];
    });
}

/**
 * Returns the translation for the given string. This function allows you to
 * retrieve languages in the same way as you would do in the Ruby code for your
 * application:
 *
 *     var string = lang('foo.bar');
 *
 * This code is the same as the following:
 *
 *     var string = Zen.translations['foo.bar'];
 *
 * @since  22-12-2011
 * @param  {string} key The language key to retrieve.
 * @return {string}
 */
function lang(key)
{
    if ( !Zen.translations[key] )
    {
        throw new Error('The language key "' + key + '" does not exist');
    }

    return Zen.translations[key];
}
