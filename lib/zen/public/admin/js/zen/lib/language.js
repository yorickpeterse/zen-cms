/**
 * Retrieves the specified language key if it exists, otherwise it raises an
 * error.
 *
 * @author Yorick Peterse
 * @since  0.3
 * @param  {string} key The language key to retrieve.
 * @return {string}
 */
function lang(key)
{
    if ( Zen.translations[key] )
    {
        return Zen.translations[key];
    }
    else
    {
        throw new Error('The language key ' + key + ' is invalid');
    }
}
