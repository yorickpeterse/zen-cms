/**
 * A MooTools class that allows sorting of a nested tree structure.
 *
 * The code for this class was originally written by Ryan Mitchell and can be
 * found here: https://github.com/ryanmitchell/Nested-Sortables. I've made the
 * following changes to this class:
 *
 * * Documentation style has been changed to match Zen's style
 * * Tabs have been replaced with spaces
 * * Various code changes so that JS Lint doesn't spit out a large number of
 *   warnings.
 * * Code aligned to 80 characters per line.
 * * Added the methods serializeArray() and serializeItems().
 * * Replaced various while() loops with calls to getParents() and the like.
 *
 * @since 11-02-2012
 */
var NestedSortables = new Class(
{
    Implements: [Options, Events],

    /**
     * Object containing all the options that can be set in the secondary
     * parameter of the constructor.
     *
     * @since 11-02-2012
     */
    options:
    {
        // The child tag to drag.
        childTag: 'li',

        // When set to true a copy of the element will be created and displayed
        // under the cursor.
        ghost: true,

        // The class to apply to the element that was cloned, only used if the
        // "ghost" option is set to true.
        ghostClass: 'ghost',

        // The offset of the cloned element relative to the cursor's position.
        ghostOffset: { x: 20, y: 10 },

        // The amount of pixels that have to be moved before an item is assigned
        // to a parent item (ore removed).
        childStep: 30,

        // The class of the element that has to be dragged.
        handleClass: null,

        // The event to call when the user starts dragging an item.
        onStart: Class.empty,

        // The event to call when the user finished dragging an item.
        onComplete: Class.empty,

        // Whether or not elements can be collapsed.
        collapse: false,

        // The class to apply to elements that can be collapsed.
        collapseClass: 'collapse',

        // The key to press to expand an element.
        expandKey: 'shift',

        // Whether or not to lock sorting to a parent element.
        lock: null,

        // The depth for locked items.
        lockDepth: null,

        // The class to apply to elements that will be locked.
        lockClass: 'unlocked'
    },

    /**
     * Creates a new instance of the class.
     *
     * @since 11-02-2012
     * @param {string} list The ID of the list container.
     * @param {object} options Object containing custom options to set. See
     *  NestedSortables.options for all the available options.
     */
    initialize: function(list, options)
    {
        this.setOptions(options);

        this.list              = $(list);
        this.options.childTag  = this.options.childTag.toLowerCase();
        this.options.parentTag = this.list.get('tag').toLowerCase();
        this.bound             = {};
        this.bound.start       = this.start.bind(this);

        this.list.addEvent('mousedown', this.bound.start);

        if ( this.options.collapse )
        {
            this.bound.collapse = this.collapse.bind(this);
            this.list.addEvent('click', this.bound.collapse);
        }

        this.fireEvent('initialized', this);
    },

    /**
     * Starts dragging an element.
     *
     * @since 11-02-2012
     * @param {Event} event
     */
    start: function(event)
    {
        var el = $(event.target);

        if ( this.options.handleClass )
        {
            if ( !el.hasClass(this.options.handleClass) )
            {
                return true;
            }
        }

        el = el.getParent(this.options.childTag);

        if ( this.options.lock === 'class'
        && !el.hasClass(this.options.lockClass) )
        {
            return;
        }

        if ( this.options.ghost )
        {
            this.ghost = el.clone();

            this.ghost.setStyles(
            {
                'list-style-type': 'none',
                'opacity':         0.5,
                'position':        'absolute',
                'visibility':      'hidden',
                'top':  (event.page.y+this.options.ghostOffset.y) + 'px',
                'left': (event.page.x+this.options.ghostOffset.x) + 'px'
            });

            this.ghost.addClass(this.options.ghostClass)
                .inject(document.body, 'inside');
        }

        el.depth = this.getDepth(el);
        el.moved = false;
        var self = this;

        this.bound.movement = function(ev) { self.movement(ev, el); };
        this.bound.end      = function(ev) { self.end(ev, el); };

        this.list.removeEvent('mousedown', this.bound.start);
        this.list.addEvent('mousedown', this.bound.end);
        this.list.addEvent('mousemove', this.bound.movement);
        document.addEvent('mouseup', this.bound.end);

        if ( Browser.ie6 || Browser.ie7 )
        {
            this.bound.stop = this.stop.bind(this);

            $(document.body)
                .addEvent('drag', this.bound.stop)
                .addEvent('selectstart', this.bound.stop);
        }

        this.fireEvent('start', el);

        event.stop();
    },

    /**
     * Event that is called whenever an element is collapsed.
     *
     * @since 11-02-2012
     * @param {Event} event
     */
    collapse: function(event)
    {
        var el = $(event.target);

        if ( this.options.handleClass )
        {
            if ( !el.hasClass(this.options.handleClass) )
            {
                return true;
            }
        }

        el = el.getParent(this.options.childTag);

        if ( !el.moved )
        {
            var sub = el.getElement(this.options.parentTag);

            if ( sub )
            {
                if ( sub.getStyle('display') === 'none' )
                {
                    sub.setStyle('display', 'block');
                    el.removeClass(this.options.collapseClass);
                }
                else
                {
                    sub.setStyle('display', 'none');
                    el.addClass(this.options.collapseClass);
                }
            }
        }

        event.stop();
    },

    /**
     * Stops an event.
     *
     * @since 11-02-2012
     * @param {Event} event
     */
    stop: function(event)
    {
        event.stop();
        return false;
    },

    /**
     * Gets the depth of an element.
     *
     * @since  11-02-2012
     * @param  {Element} el
     * @param  {boolean} add
     * @return {number}
     */
    getDepth: function(el, add)
    {
        var counter = (add) ? 1 : 0;

        return counter + (el.getParents(this.options.parentTag).length - 1);
    },

    /**
     * Removes the events of various elements.
     *
     * @since 11-02-2012
     */
    detach: function()
    {
        this.list.removeEvent('mousedown', this.start.bind(this));

        if ( this.options.collapse )
        {
            this.list.removeEvent('click', this.bound.collapse);
        }
    },

    /**
     * Stops the process of dragging an element.
     *
     * @since 11-02-2012
     * @param {Event} event
     * @param {Element} el
     */
    end: function(event, el)
    {
        if ( this.options.ghost )
        {
            this.ghost.destroy();
        }

        this.list.removeEvent('mousemove', this.bound.movement);
        this.list.removeEvent('mousedown', this.bound.end);
        this.list.addEvent('mousedown', this.bound.start);

        document.removeEvent('mouseup', this.bound.end);

        this.fireEvent('complete', el);

        if ( Browser.ie )
        {
            $(document.body)
                .removeEvent('drag', this.bound.stop)
                .removeEvent('selectstart', this.bound.stop);
        }
    },

    /**
     * Method that is called whenever an element is being moved.
     *
     * @since 11-02-2012
     * @param {Event} event
     * @param {Element} el
     */
    movement: function(event, el)
    {
        var dir, over, check, items;
        var dest, move, prev, prevParent;
        var abort = false;

        if ( this.options.ghost && el.moved )
        {
            this.ghost.setStyles(
            {
                'position':   'absolute',
                'visibility': 'visible',
                'top':        (event.page.y+this.options.ghostOffset.y)+'px',
                'left':       (event.page.x+this.options.ghostOffset.x)+'px'
            });
        }

        //over = event.target.getParent(this.options.childTag);
        over            = event.target;
        var over_parent = event.target.getParent(this.options.childTag);

        if ( over_parent )
        {
            over = over_parent;
        }

        if ( event[this.options.expandKey]
        && over !== el
        && over.hasClass(this.options.collapseClass) )
        {
            check = over.getElement(this.options.parentTag);
            over.removeClass(this.options.collapseClass);
            check.setStyle('display', 'block');
        }

        if ( el !== over )
        {
            items = over.getElements(this.options.childTag);

            items.each(function(item)
            {
                if ( event.page.y > item.getCoordinates().top
                && item.offsetHeight > 0 )
                {
                    over = item;
                }
            });
        }

        // store the previous parent 'ol' to remove it if a move makes it empty
        prevParent = el.getParent();
        dir        = (event.page.y < el.getCoordinates().top) ? 'up' : 'down';
        move       = 'before';
        dest       = el;

        if ( el !== over )
        {
            check = over;

            while ( check !== null && check !== el )
            {
                check = check.getParent();
            }

            if ( check === el )
            {
                return;
            }

            if ( dir === 'up' )
            {
                move = 'before';
                dest = over;
            }
            else
            {
                sub = over.getElement(this.options.childTag);

                if ( sub && sub.offsetHeight > 0 )
                {
                    move = 'before';
                    dest = sub;
                }
                else
                {
                    move = 'after';
                    dest = over;
                }
            }
        }

        // Check if we're trying to go deeper -->>
        prev = ( move === 'before' ) ? dest.getPrevious() : dest;

        if ( prev )
        {
            move  = 'after';
            dest  = prev;
            check = dest.getElement(this.options.parentTag);

            while ( check
            && event.page.x > check.getCoordinates().left
            && check.offsetHeight > 0 )
            {
                dest  = check.getLast();
                check = dest.getElement(this.options.parentTag);
            }

            if ( !check
            && event.page.x > dest.getCoordinates().left+this.options.childStep )
            {
                move = 'inside';
            }
        }

        last = dest.getParent().getLast();

        while ( ((move === 'after' && last === dest) || last === el)
        && dest.getParent() !== this.list
        && event.page.x < dest.getCoordinates().left )
        {
            move = 'after';
            dest = $(dest.parentNode.parentNode);
            last = dest.getParent().getLast();
        }

        abort = false;

        if ( move !== '' )
        {
            abort += (dest === el);
            abort += (move === 'after' && dest.getNext() === el);
            abort += (move === 'before' && dest.getPrevious() === el);

            abort += (this.options.lock === 'depth'
                && this.options.lockDepth !== null
                && this.getDepth(dest, (move === 'inside')) <= this.options.lockDepth);

            abort += (this.options.lock === 'depth'
                && this.options.lockDepth === null
                && el.depth !== this.getDepth(dest, (move === 'inside')));

            abort += (this.options.lock === 'parent'
                && (move === 'inside' || dest.parentNode !== el.parentNode));

            abort += (this.options.lock === 'list'
                && this.getDepth(dest, (move === 'inside')) === 0);

            abort += (dest.offsetHeight === 0);

            sub = over.getElement(this.options.parentTag);
            sub = (sub) ? sub.getCoordinates().top : 0;
            sub = (sub > 0) ? sub-over.getCoordinates().top : over.offsetHeight;

            abort += (event.page.y < (sub-el.offsetHeight)
                + over.getCoordinates().top);

            if ( !abort )
            {
                if ( move === 'inside' )
                {
                    dest = new Element(this.options.parentTag)
                        .inject(dest, 'inside');
                }

                $(el).inject(dest, move);

                el.moved = true;

                if ( !prevParent.getFirst() )
                {
                    prevParent.destroy();
                }
            }
        }

        event.stop();
    },

    /**
     * Serializes the structure and returns it as an object. The keys are the
     * IDs of each element and the values are either "true" to indicate that
     * there are no sub elements or an object of sub elements (with the same
     * structure).
     *
     * @since  11-02-2012
     * @param  {Function} fn
     * @param  {Element} base
     * @return {object}
     */
    serialize: function(fn, base)
    {
        if ( !base )
        {
            base = this.list;
        }

        if ( !fn )
        {
            fn = function(el) { return el.get('id'); };
        }

        var result = {};

        base.getChildren('li').each(
            function(el)
            {
                var child = el.getElement('ul');

                result[fn(el)] = child ? this.serialize(fn, child) : true;
            },
            this
        );

        return result;
    },

    /**
     * Builds an array containing all the menu items and their parent IDs. This
     * array is sorted based on the sort order specified by the user.
     *
     * @since  11-02-2012
     * @return {array}
     */
    serializeArray: function()
    {
        return this.serializeItems(this.serialize());
    },

    /**
     * @since 11-02-2012
     * @see   NestedSortables.serializeArray()
     */
    serializeItems: function(items, parent_id)
    {
        parent_id     = parent_id || null;
        var structure = [];
        var _this     = this;

        Object.forEach(items, function(value, key)
        {
            var id = key.replace(/^menu_item_/, '');

            structure.push({id: id, parent_id: parent_id});

            if ( typeOf(value) === 'object' )
            {
                structure = structure.concat(_this.serializeItems(value, id));
            }
        });

        return structure;
    }
});
