# Zen.Hash

Zen.Hash is a class that can be used to parse and generate shebang/hash bang
URLs. Parsing is done using ``Zen.Hash#parse`` and generating URLs using
``Zen.Hash#getHash``.

Parsing a URL is relatively simple and the end output is similar to how you'd
parse URLs with query string parameters. First create a new instance of this
class:

    var hash = new Zen.Hash('#!/users/active?limit=10');

The supplied string will be parsed straight away and the result can be
retrieved from two attributes:

* segments
* params

The first attribute contains an array with all the URL segments, the second
one is an object containing all the query string parameters. In case of the
above example that would lead to the following data being stored in these
attributes:

    console.log(hash.segments); // => ["users", "active"]
    console.log(hash.params);   // => {limit: '10'}

Keep in mind that calling ``Zen.Hash#parse`` will overwrite existing segments
and parameters.

Generating a full shebang URL is pretty straight forward as well and can be done
by calling ``getHash()``. This method returns a string containing the shebang
URL including the prefix:

    hash.getHash(); // => "#!/users/active?limit=10"
