"use strict";

namespace('Zen');

/**
 * Zen.Hash is a class that can be used to parse and generate shebang/hash bang
 * URLs. Parsing is done using ``Zen.Hash#parse`` and generating URLs using
 * ``Zen.Hash#getHash``.
 *
 * ## Parsing
 *
 * Parsing a URL is relatively simple and the end output is similar to how you'd
 * parse URLs with query string parameters. First create a new instance of this
 * class:
 *
 *     var hash = new Zen.Hash('#!/users/active?limit=10');
 *
 * The supplied string will be parsed straight away and the result can be
 * retrieved from two attributes:
 *
 * * segments
 * * params
 *
 * The first attribute contains an array with all the URL segments, the second
 * one is an object containing all the query string parameters. In case of the
 * above example that would lead to the following data being stored in these
 * attributes:
 *
 *     console.log(hash.segments); // => ["users", "active"]
 *     console.log(hash.params);   // => {limit: '10'}
 *
 * Keep in mind that calling ``Zen.Hash#parse`` will overwrite existing segments
 * and parameters.
 *
 * ## Generating
 *
 * Generating a full shebang URL is pretty straight forward and can be done by
 * calling ``getHash()``. This method returns a string containing the shebang
 * URL including the prefix:
 *
 *     hash.getHash(); // => "#!/users/active?limit=10"
 *
 * @since 19-12-2011
 */
Zen.Hash = new Class(
{
    /**
     * String containing the raw URL hash before it was parsed.
     *
     * @since 19-12-2011
     */
    raw_hash: '',

    /**
     * Object containing all the parsed hash parameters.
     *
     * @since 19-12-2011
     */
    params: {},

    /**
     * Array containing all the hash segments.
     *
     * @since 19-12-2011
     */
    segments: [],

    /**
     * Creates a new instance of the class, sets the raw hash and parses it.
     *
     * @since 19-12-2011
     * @param {string} hash The URL hash to parse.
     */
    initialize: function(hash)
    {
        if ( hash && hash.length > 0 ) this.parse(hash);
    },

    /**
     * Parses the supplied hash and stores the results in ``this.params``.
     *
     * @since 19-12-2011
     * @param {string} hash The hash to parse.
     */
    parse: function(hash)
    {
        if ( typeOf(hash) !== 'string' )
        {
            throw new Error(
                'Expected a string to parse but got ' + typeOf(hash) + ' instead'
            );
        }

        this.raw_hash = hash;
        this.params   = {};
        this.segments = [];

        hash = hash.replace(/^#/, '').split('?');

        // Index 0 always contains the path, index 1 the parameters.
        if ( hash[0] && hash[0].length > 0 )
        {
            this.segments = hash[0].split('/');
        }

        if ( hash[1] && hash[1].length > 0 )
        {
            var _this = this;
            hash[1]   = hash[1].split('&');

            hash[1].each(function(key_value)
            {
                key_value = key_value.split('=');

                // Assign the key and value. If the key already exists it should
                // be turned into an array.
                if ( _this.params[key_value[0]] )
                {
                    if ( typeOf(_this.params[key_value[0]]) !== 'array' )
                    {
                        _this.params[key_value[0]] = [
                            _this.params[key_value[0]],
                            key_value[1]
                        ];
                    }
                    else
                    {
                        _this.params[key_value[0]].push(key_value[1]);
                    }
                }
                else
                {
                    _this.params[key_value[0]] = key_value[1];
                }
            });
        }
    },

    /**
     * Returns a string containing the hash URL for the current segments and
     * parameters.
     *
     * @since  19-12-2011
     * @return {string}
     */
    getHash: function()
    {
        if ( typeOf(this.segments) !== 'array' )
        {
            throw new Error(
                'Expected an array for the URL segments but got '
                    + typeOf(this.segments)
                    + ' instead'
            );
        }

        if ( typeOf(this.params) !== 'object' )
        {
            throw new Error(
                'Expected an object for the hash parameters but got '
                    + typeOf(this.params)
                    + ' instead'
            );
        }

        var hash   = '#' + this.segments.join('/');
        var groups = [];

        Object.each(this.params, function(value, key)
        {
            if ( typeOf(value) === 'array' )
            {
                value.each(function(val)
                {
                    groups.push(key + '=' + val);
                });
            }
            else
            {
                groups.push(key + '=' + value);
            }
        });

        if ( groups.length > 0 )
        {
            hash += '?' + groups.join('&');
        }

        return hash;
    }
});
