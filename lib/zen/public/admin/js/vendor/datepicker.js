/*
---
name: Picker
description: Creates a Picker, which can be used for anything
authors: Arian Stolwijk
requires: [Core/Element.Dimensions, Core/Fx.Tween, Core/Fx.Transitions]
provides: Picker
...
*/


var Picker = new Class({

	Implements: [Options, Events],

	options: {/*
		onShow: function(){},
		onOpen: function(){},
		onHide: function(){},
		onClose: function(){},*/

		pickerClass: 'datepicker',
		inject: null,
		animationDuration: 400,
		useFadeInOut: true,
		positionOffset: {x: 0, y: 0},
		pickerPosition: 'bottom',
		draggable: true,
		showOnInit: true
	},

	initialize: function(options){
		this.setOptions(options);
		this.constructPicker();
		if (this.options.showOnInit) this.show();
	},

	constructPicker: function(){
		var options = this.options;

		var picker = this.picker = new Element('div', {
			'class': options.pickerClass,
			styles: {
				left: 0,
				top: 0,
				display: 'none',
				opacity: 0
			}
		}).inject(options.inject || document.body);

		if (options.useFadeInOut){
			picker.set('tween', {
				duration: options.animationDuration,
				link: 'cancel'
			});
		}

		// Build the header
		var header = this.header = new Element('div.header').inject(picker);

		this.closeButton = new Element('div.closeButton[text=x]')
			.addEvent('click', this.close.pass(false, this))
			.inject(header);

		var title = this.title = new Element('div.title').inject(header);
		this.titleText = new Element('div.titleText').inject(title);

		// Build the body of the picker
		var body = this.body = new Element('div.body').inject(picker);

		// oldContents and newContents are used to slide from the old content to a new one.
		var slider = this.slider = new Element('div.slider', {
			styles: {
				position: 'absolute',
				top: 0,
				left: 0
			}
		}).set('tween', {
			duration: options.animationDuration,
			transition: Fx.Transitions.Quad.easeInOut
		}).inject(body);

		this.oldContents = new Element('div', {
			styles: {
				position: 'absolute',
				top: 0
			}
		}).inject(slider);

		this.newContents = new Element('div', {
			styles: {
				position: 'absolute',
				top: 0,
				left: 0
			}
		}).inject(slider);

		// IFrameShim for select fields in IE
		var shim = this.shim = window['IframeShim'] ? new IframeShim(picker) : null;

		// Dragging
		if (options.draggable && typeOf(picker.makeDraggable) == 'function'){
			this.dragger = picker.makeDraggable(shim ? {
				onDrag: shim.position.bind(shim)
			} : null);
			picker.setStyle('cursor', 'move');
		}

		this.addEvent('open', function(){
			picker.setStyle('display', 'block');
			if (shim) shim.show();
		}, true);

		this.addEvent('hide', function(){
			picker.setStyle('display', 'none');
			if (shim) shim.hide();
		}, true);

	},

	open: function(noFx){
		if (this.opened == true) return this;
		this.opened = true;
		this.fireEvent('open');
		if (this.options.useFadeInOut && !noFx){
			this.picker.fade('in').get('tween').chain(function(){
				this.fireEvent('show');
			}.bind(this));
		} else {
			this.picker.setStyle('opacity', 1);
			this.fireEvent('show');
		}
		return this;
	},

	show: function(){
		return this.open(true);
	},

	close: function(noFx){
		if (this.opened == false) return this;
		this.opened = false;
		this.fireEvent('close');
		if (this.options.useFadeInOut && !noFx){
			this.picker.fade('out').get('tween').chain(function(){
				this.fireEvent('hide');
			}.bind(this));
		} else {
			this.picker.setStyle('opacity', 0);
			this.fireEvent('hide');
		}
		return this;
	},

	hide: function(){
		return this.close(true);
	},

	toggle: function(){
		return this[this.opened == true ? 'close' : 'open']();
	},

	destroy: function(){
		this.picker.destroy();
		if (this.shim) this.shim.destroy();
	},

	position: function(x, y){
		var offset = this.options.positionOffset,
			scroll = document.getScroll(),
			size = document.getSize(),
			pickersize = this.picker.getSize();

		if (typeOf(x) == 'element'){
			var element = x,
				where = y || this.options.pickerPosition;

			var elementCoords = element.getCoordinates();

			x = (where == 'left') ? elementCoords.left - pickersize.x
				: (where == 'bottom' || where == 'top') ? elementCoords.left
				: elementCoords.right
			y = (where == 'bottom') ? elementCoords.bottom
				: (where == 'top') ? elementCoords.top - pickersize.y
				: elementCoords.top;
		}

		x += offset.x * ((where && where == 'left') ? -1 : 1);
		y += offset.y * ((where && where == 'top') ? -1: 1);

		if ((x + pickersize.x) > (size.x + scroll.x)) x = (size.x + scroll.x) - pickersize.x;
		if ((y + pickersize.y) > (size.y + scroll.y)) y = (size.y + scroll.y) - pickersize.y;
		if (x < 0) x = 0;
		if (y < 0) y = 0;

		this.picker.setStyles({
			left: x,
			top: y
		});
		if (this.shim) this.shim.position();
		return this;
	},

	setBodySize: function(){
		var bodysize = this.bodysize = this.body.getSize();
		this.slider.setStyles({
			width: 2 * bodysize.x,
			height: bodysize.y
		});
		this.oldContents.setStyles({
			left: bodysize.x,
			width: bodysize.x,
			height: bodysize.y
		});
		this.newContents.setStyles({
			width: bodysize.x,
			height: bodysize.y
		});
	},

	setContent: function(){
		var content = Array.from(arguments), fx;

		if (['right', 'left', 'fade'].contains(content[1])) fx = content[1];
		if (content.length == 1 || fx) content = content[0];

		// swap contents so we can fill the newContents again and animate
		var old = this.oldContents;
		this.oldContents = this.newContents;
		this.newContents = old;
		this.newContents.empty();

		var type = typeOf(content);
		if (['string', 'number'].contains(type)) this.newContents.set('text', content);
		else this.newContents.adopt(content);

		this.setBodySize();

		if (fx){
			this.fx(fx);
		} else {
			this.slider.setStyle('left', 0);
			this.oldContents.setStyles({left: 0, opacity: 0});
			this.newContents.setStyles({left: 0, opacity: 1});
		}
		return this;
	},

	fx: function(fx){
		var oldContents = this.oldContents,
			newContents = this.newContents,
			slider = this.slider,
			bodysize = this.bodysize;
		if (fx == 'right'){
			oldContents.setStyles({left: 0, opacity: 1});
			newContents.setStyles({left: bodysize.x, opacity: 1});
			slider.setStyle('left', 0).tween('left', 0, -bodysize.x);
		} else if (fx == 'left'){
			oldContents.setStyles({left: bodysize.x, opacity: 1});
			newContents.setStyles({left: 0, opacity: 1});
			slider.setStyle('left', -bodysize.x).tween('left', -bodysize.x, 0);
		} else if (fx == 'fade'){
			slider.setStyle('left', 0);
			oldContents.setStyle('left', 0).set('tween', {
				duration: this.options.animationDuration / 2
			}).tween('opacity', 1, 0).get('tween').chain(function(){
				oldContents.setStyle('left', bodysize.x);
			});
			newContents.setStyles({opacity: 0, left: 0}).set('tween', {
				duration: this.options.animationDuration
			}).tween('opacity', 0, 1);
		}
	},

	toElement: function(){
		return this.picker;
	},

	setTitle: function(text){
		this.titleText.set('text', text);
		return this;
	},

	setTitleEvent: function(fn){
		this.titleText.removeEvents('click');
		if (fn) this.titleText.addEvent('click', fn);
		this.titleText.setStyle('cursor', fn ? 'pointer' : '');
		return this;
	}

});

/*
---
name: Picker.Attach
description: Adds attach and detach methods to the Picker, to attach it to element events
authors: Arian Stolwijk
requires: [Picker, Core/Element.Event]
provides: Picker.Attach
...
*/


Picker.Attach = new Class({

	Extends: Picker,

	options: {/*
		onAttachedEvent: function(event){},

		toggleElements: null, // deprecated
		toggle: null, // When set it deactivate toggling by clicking on the input */
		showOnInit: false
	},

	initialize: function(attachTo, options){
		this.parent(options);

		this.attachedEvents = [];
		this.attachedElements = [];
		this.toggles = [];
		this.inputs = [];

		var documentEvent = function(event){
			if (this.attachedElements.contains(event.target)) return null;
			this.close();
		}.bind(this);
		var document = this.picker.getDocument().addEvent('click', documentEvent);

		var preventPickerClick = function(event){
			event.stopPropagation();
			return false;
		};
		this.picker.addEvent('click', preventPickerClick);

		// Support for deprecated toggleElements
		if (this.options.toggleElements) this.options.toggle = document.getElements(this.options.toggleElements);

		this.attach(attachTo, this.options.toggle);
	},

	attach: function(attachTo, toggle){
		if (typeOf(attachTo) == 'string') attachTo = document.id(attachTo);
		if (typeOf(toggle) == 'string') toggle = document.id(toggle);

		var elements = Array.from(attachTo),
			toggles = Array.from(toggle),
			allElements = [].append(elements).combine(toggles),
			self = this;

		var eventWrapper = function(fn, element){
			return function(event){
				if (event.type == 'keydown' && ['tab', 'esc'].contains(event.key) == false) return false;
				if (event.target.get('tag') == 'a') event.stop();
				self.fireEvent('attachedEvent', [event, element]);
				self.position(element);
				fn();
			};
		};

		allElements.each(function(element, i){

			// The events are already attached!
			if (self.attachedElements.contains(element)) return null;

			var tag = element.get('tag');

			var events = {};
			if (tag == 'input'){
				// Fix in order to use togglers only
				if (!toggles.length){
					events = {
						focus: eventWrapper(self.open.bind(self), element),
						keydown: eventWrapper(self.close.bind(self), element),
						click: eventWrapper(self.open.bind(self), element)
					};
				}
				self.inputs.push(element);
			} else {
				if (toggles.contains(element)){
					self.toggles.push(element);
					events.click = eventWrapper(self.toggle.bind(self), element);
				} else {
					events.click = eventWrapper(self.open.bind(self), element);
				}
			}
			element.addEvents(events);
			self.attachedElements.push(element);
			self.attachedEvents.push(events);
		});
		return this;
	},

	detach: function(attachTo, toggle){
		if (typeOf(attachTo) == 'string') attachTo = document.id(attachTo);
		if (typeOf(toggle) == 'string') toggle = document.id(toggle);

		var elements = Array.from(attachTo),
			toggles = Array.from(toggle),
			allElements = [].append(elements).combine(toggles),
			self = this;

		if (!allElements.length) allElements = self.attachedElements;

		allElements.each(function(element){
			var i = self.attachedElements.indexOf(element);
			if (i < 0) return null;

			var events = self.attachedEvents[i];
			element.removeEvents(events);
			delete self.attachedEvents[i];
			delete self.attachedElements[i];

			var toggleIndex = self.toggles.indexOf(element);
			if (toggleIndex != -1) delete self.toggles[toggleIndex];

			var inputIndex = self.inputs.indexOf(element);
			if (toggleIndex != -1) delete self.inputs[inputIndex];

		});
		return this;
	},

	destroy: function(){
		this.detach();
		this.parent();
	}

});

/*
---
name: Locale.en-US.DatePicker
description: English Language File for DatePicker
authors: Arian Stolwijk
requires: [More/Locale]
provides: Locale.en-US.DatePicker
...
*/


Locale.define('en-US', 'DatePicker', {
	select_a_time: 'Select a time',
	use_mouse_wheel: 'Use the mouse wheel to quickly change value',
	time_confirm_button: 'OK'
});

/*
---
name: Picker.Date
description: Creates a DatePicker, can be used for picking years/months/days and time, or all of them
authors: Arian Stolwijk
requires: [Picker, Picker.Attach, Locale.en-US.DatePicker, More/Locale, More/Date]
provides: Picker.Date
...
*/


(function(){

this.DatePicker = Picker.Date = new Class({

	Extends: Picker.Attach,

	options: {/*
		onSelect: function(date){},

		minDate: new Date('3/4/2010'), // Date object or a string
		maxDate: new Date('3/4/2011'), // same as minDate
		availableDates: {}, //
		format: null,*/

		timePicker: false,
		timePickerOnly: false, // deprecated, use onlyView = 'time'
		timeWheelStep: 1, // 10,15,20,30

		yearPicker: true,
		yearsPerPage: 20,

		startDay: 1, // Sunday (0) through Saturday (6) - be aware that this may affect your layout, since the days on the right might have a different margin

		startView: 'days', // allowed values: {time, days, months, years}
		pickOnly: false, // 'years', 'months', 'days', 'time'
		canAlwaysGoUp: ['months', 'days'],

		// if you like to use your own translations
		months_abbr: null,
		days_abbr: null,
		years_title: function(date, options){
			var year = date.get('year');
			return year + '-' + (year + options.yearsPerPage - 1);
		},
		months_title: function(date, options){
			return date.get('year');
		},
		days_title: function(date, options){
			return date.format('%b %Y');
		},
		time_title: function(date, options){
			return (options.pickOnly == 'time') ? Locale.get('DatePicker.select_a_time') : date.format('%d %B, %Y');
		}
	},

	initialize: function(attachTo, options){
		this.parent(attachTo, options);

		this.setOptions(options);
		var options = this.options;

		// If we only want to use one picker / backwards compatibility
		['year', 'month', 'day', 'time'].some(function(what){
			if (options[what + 'PickerOnly']) return options.pickOnly = what;
		});
		if (options.pickOnly){
			options[options.pickOnly + 'Picker'] = true;
			options.startView = options.pickOnly;
		}

		// backward compatibility for startView
		var newViews = ['days', 'months', 'years'];
		['month', 'year', 'decades'].some(function(what, i){
			if (options.startView == what){
				options.startView = newViews[i];
				return true;
			}
		});

		options.canAlwaysGoUp = options.canAlwaysGoUp ? Array.from(options.canAlwaysGoUp) : [];

		// Set the min and max dates as Date objects
		if (options.minDate){
			if (!(options.minDate instanceof Date)) options.minDate = Date.parse(options.minDate);
			options.minDate.clearTime();
		}
		if (options.maxDate){
			if (!(options.maxDate instanceof Date)) options.maxDate = Date.parse(options.maxDate);
			options.maxDate.clearTime();
		}

		if (!options.format){
			options.format = (options.pickOnly != 'time') ? Locale.get('Date.shortDate') : '';
			if (options.timePicker) options.format = (options.format) + (options.format ? ' ' : '') + Locale.get('Date.shortTime');
		}

		// This is where we store the selected date
		this.date = limitDate(new Date(), options.minDate, options.maxDate);

		// Some link or input has fired an event!
		this.addEvent('attachedEvent', function(event, element){
			var tag = element.get('tag'), input;
			if (tag == 'input'){
				input = element;
			} else {
				var index = this.toggles.indexOf(element);
				if (this.inputs[index]) input = this.inputs[index];
			}
			this.date = new Date()
			if (input){
				var date = Date.parse(input.get('value'));
				if (date == null || !date.isValid()){
					var storeDate = input.retrieve('datepicker:value');
					if (storeDate) date = Date.parse(storeDate);
				}
				if (date != null && date.isValid()) this.date = date;
			}
			this.input = input;
		}.bind(this), true);


		// Start rendering the default view.
		this.currentView = options.startView;
		this.addEvent('open', function(){
			var view = this.currentView,
				cap = view.capitalize();
			if (this['render' + cap]){
				this['render' + cap](this.date.clone());
				this.currentView = view;
			}
		}.bind(this));

	},

	// Control the previous and next elements

	constructPicker: function(){
		this.parent();

		this.previous = new Element('div.previous[html=&#171;]').inject(this.header);
		this.next = new Element('div.next[html=&#187;]').inject(this.header);
	},

	hidePrevious: function($next, $show){
		this[$next ? 'next' : 'previous'].setStyle('display', $show ? 'block' : 'none');
		return this;
	},

	showPrevious: function($next){
		return this.hidePrevious($next, true);
	},

	setPreviousEvent: function(fn, $next){
		this[$next ? 'next' : 'previous'].removeEvents('click');
		if (fn) this[$next ? 'next' : 'previous'].addEvent('click', fn);
		return this;
	},

	hideNext: function(){
		return this.hidePrevious(true);
	},

	showNext: function(){
		return this.showPrevious(true);
	},

	setNextEvent: function(fn){
		return this.setPreviousEvent(fn, true);
	},

	// Render the Pickers

	renderYears: function(date, fx){

		var options = this.options;

		// start neatly at interval (eg. 1980 instead of 1987)
		while (date.get('year') % options.yearsPerPage > 0) date.decrement('year', 1);

		this.setTitle(options.years_title(date, options));

		this.setContent(renderers.years(
			options,
			date.clone(),
			this.date.clone(),
			function(date){
				if (options.pickOnly == 'years') this.select(date);
				else this.renderMonths(date, 'fade');
			}.bind(this)
		), fx);

		// Set limits
		var limitLeft = (options.minDate && date.get('year') <= options.minDate.get('year')),
			limitRight = (options.maxDate && (date.get('year') + options.yearsPerPage) >= options.maxDate.get('year'));
		this[(limitLeft ? 'hide' : 'show') + 'Previous']();
		this[(limitRight ? 'hide' : 'show') + 'Next']();

		this.setPreviousEvent(function(){
			this.renderYears(date.decrement('year', options.yearsPerPage), 'left');
		}.bind(this));

		this.setNextEvent(function(){
			this.renderYears(date.increment('year', options.yearsPerPage), 'right');
		}.bind(this));

		// We can't go up!
		this.setTitleEvent(null);
	},

	renderMonths: function(date, fx){
		var options = this.options;
		this.setTitle(options.months_title(date, options));

		this.setContent(renderers.months(
			options,
			date.clone(),
			this.date.clone(),
			function(date){
				if (options.pickOnly == 'months') this.select(date);
				else this.renderDays(date, 'fade');
			}.bind(this)
		), fx);

		// Set limits
		var year = date.get('year'),
			limitLeft = (options.minDate && year <= options.minDate.get('year')),
			limitRight = (options.maxDate && year >= options.maxDate.get('year'));
		this[(limitLeft ? 'hide' : 'show') + 'Previous']();
		this[(limitRight ? 'hide' : 'show') + 'Next']();

		this.setPreviousEvent(function(){
			this.renderMonths(date.decrement('year', 1), 'left');
		}.bind(this));

		this.setNextEvent(function(){
			this.renderMonths(date.increment('year', 1), 'right');
		}.bind(this));

		var canGoUp = options.yearPicker && (options.pickOnly != 'months' || options.canAlwaysGoUp.contains('months'));
		var titleEvent = (canGoUp) ? function(){
			this.renderYears(date, 'fade');
		}.bind(this) : null;
		this.setTitleEvent(titleEvent);
	},

	renderDays: function(date, fx){
		var options = this.options;
		this.setTitle(options.days_title(date, options));

		this.setContent(renderers.days(
			options,
			date.clone(),
			this.date.clone(),
			function(date){
				if (options.pickOnly == 'days' || !options.timePicker) this.select(date)
				else this.renderTime(date, 'fade');
			}.bind(this)
		), fx);

		var yearmonth = date.format('%Y%m').toInt(),
			limitLeft = (options.minDate && yearmonth <= options.minDate.format('%Y%m')),
			limitRight = (options.maxDate && yearmonth >= options.maxDate.format('%Y%m'));
		this[(limitLeft ? 'hide' : 'show') + 'Previous']();
		this[(limitRight ? 'hide' : 'show') + 'Next']();

		this.setPreviousEvent(function(){
			this.renderDays(date.decrement('month', 1), 'left');
		}.bind(this));

		this.setNextEvent(function(){
			this.renderDays(date.increment('month', 1), 'right');
		}.bind(this));

		var canGoUp = options.pickOnly != 'days' || options.canAlwaysGoUp.contains('days');
		var titleEvent = (canGoUp) ? function(){
			this.renderMonths(date, 'fade');
		}.bind(this) : null;
		this.setTitleEvent(titleEvent);
	},

	renderTime: function(date, fx){
		var options = this.options;
		this.setTitle(options.time_title(date, options));

		this.setContent(renderers.time(
			options,
			date.clone(),
			this.date.clone(),
			function(date){
				this.select(date);
			}.bind(this)
		), fx);

		// Hide « and » buttons
		this.hidePrevious()
			.hideNext()
			.setPreviousEvent(null)
			.setNextEvent(null);

		var canGoUp = options.pickOnly != 'time' || options.canAlwaysGoUp.contains('time');
		var titleEvent = (canGoUp) ? function(){
			this.renderDays(date, 'fade');
		}.bind(this) : null;
		this.setTitleEvent(titleEvent);
	},

	select: function(date){
		this.date = date;
		if (this.input){
			this.input.set('value', date.format(this.options.format))
				.store('datepicker:value', date.strftime())
		}
		this.fireEvent('select', date);
		this.close();
	}

});


// Renderers only output elements and calculate the limits!

var renderers = {

	years: function(options, date, currentDate, fn){
		var limit = {left: false, right: false},
			container = new Element('div.years'),
			today = new Date(),
			year, element, classes;

		for (var i = 0; i < options.yearsPerPage; i++){
			year = date.get('year');

			classes = '.year.year' + i;
			if (year == today.get('year')) classes += '.today';
			if (year == currentDate.get('year')) classes += '.selected';
			element = new Element('div' + classes, {text: year}).inject(container);

			if (isUnavailable('year', date, options)) element.addClass('unavailable');
			else element.addEvent('click', fn.pass(date.clone()));

			date.increment('year', 1);
		}

		return container;
	},

	months: function(options, date, currentDate, fn){
		var today = new Date(),
			month = today.get('month'),
			limit = {left: false, right: false},
			thisyear = (date.get('year') == today.get('year')),
			selectedyear = (date.get('year') == currentDate.get('year')),
			container = new Element('div.months'),
			months = options.months_abbr || Locale.get('Date.months_abbr'),
			elelement, classes;

		date.set('month', 0);
		if (options.minDate){
			date.decrement('month', 1);
			date.set('date', date.get('lastdayofmonth'));
			date.increment('month', 1);
		}

		date.set('date', date.get('lastdayofmonth'));

		for (var i = 0; i <= 11; i++){

			classes = '.month.month' + (i + 1);
			if (i == month && thisyear) classes += '.today';
			if (i == currentDate.get('month') && selectedyear) classes += '.selected';
			element = new Element('div' + classes, {text: months[i]}).inject(container);

			if (isUnavailable('month', date, options)) element.addClass('unavailable');
			else element.addEvent('click', fn.pass(date.clone()));

			date.increment('month', 1);
			date.set('date', date.get('lastdayofmonth'));
		}

		return container;
	},

	days: function(options, date, currentDate, fn){
		var month = date.get('month'),
			limit = {left: false, right: false},
			todayString = new Date().toDateString(),
			currentString = currentDate.toDateString(),
			container = new Element('div.days'),
			titles = new Element('div.titles').inject(container),
			localeDaysShort = options.days_abbr || Locale.get('Date.days_abbr'),
			day, classes, element, weekcontainer, dateString;

		date.setDate(1);
		while (date.getDay() != options.startDay) date.setDate(date.getDate() - 1);

		for (day = options.startDay; day < (options.startDay + 7); day++){
			new Element('div.title.day.day' + (day % 7), {
				text: localeDaysShort[(day % 7)]
			}).inject(titles);
		}

		for (var i = 0; i < 42; i++){

			if (i % 7 == 0){
				weekcontainer = new Element('div.week.week' + (Math.floor(i / 7))).inject(container);
			}

			dateString = date.toDateString();
			classes = '.day.day' + date.get('day');
			if (dateString == todayString) classes += '.today';
			if (dateString == currentString) classes += '.selected';
			if (date.get('month') != month) classes += '.otherMonth';

			element = new Element('div' + classes, {text: date.getDate()}).inject(weekcontainer);

			if (isUnavailable('date', date, options)) element.addClass('unavailable');
			else element.addEvent('click', fn.pass(date.clone()));

			date.increment('day',  1);
		}

		return container;
	},

	time: function(options, date, currentDate, fn){
		var container = new Element('div.time'),
			// make sure that the minutes are timeWheelStep * k
			initMinutes = (date.get('minutes') / options.timeWheelStep).round() * options.timeWheelStep

		if (initMinutes >= 60) initMinutes = 0;
		date.set('minutes', initMinutes);

		var hoursInput = new Element('input.hour[type=text]', {
			title: Locale.get('DatePicker.use_mouse_wheel'),
			value: date.format('%H'),
			events: {
				click: function(event){
					event.target.focus();
					event.stop();
				},
				mousewheel: function(event){
					event.stop();
					hoursInput.focus();
					var value = hoursInput.get('value').toInt();
					value = (event.wheel > 0) ? ((value < 23) ? value + 1 : 0)
						: ((value > 0) ? value - 1 : 23)
					date.set('hours', value);
					hoursInput.set('value', date.format('%H'));
				}.bind(this)
			},
			maxlength: 2
		}).inject(container);

		var minutesInput = new Element('input.minutes[type=text]', {
			title: Locale.get('DatePicker.use_mouse_wheel'),
			value: date.format('%M'),
			events: {
				click: function(event){
					event.target.focus();
					event.stop();
				},
				mousewheel: function(event){
					event.stop();
					minutesInput.focus();
					var value = minutesInput.get('value').toInt();
					value = (event.wheel > 0) ? ((value < 59) ? (value + options.timeWheelStep) : 0)
						: ((value > 0) ? (value - options.timeWheelStep) : (60 - options.timeWheelStep));
					if (value >= 60) value = 0;
					date.set('minutes', value);
					minutesInput.set('value', date.format('%M'));
				}.bind(this)
			},
			maxlength: 2
		}).inject(container);

		new Element('div.separator[text=:]').inject(container);

		new Element('input.ok[type=submit]', {
			value: Locale.get('DatePicker.time_confirm_button'),
			events: {click: function(event){
				event.stop();
				date.set({
					hours: hoursInput.get('value').toInt(),
					minutes: minutesInput.get('value').toInt()
				});
				fn(date.clone());
			}}
		}).inject(container);

		return container;
	}

};


Picker.Date.defineRenderer = function(name, fn){
	renderers[name] = fn;
	return this;
};


var limitDate = function(date, min, max){
	if (min && date < min) return min;
	if (max && date > max) return max;
	return date;
};

var isUnavailable = function(type, date, options){
	var minDate = options.minDate,
		maxDate = options.maxDate,
		availableDates = options.availableDates;

	if (!minDate && !maxDate && !availableDates) return false;
	date.clearTime();

	if (type == 'year'){
		var year = date.get('year');
		return (
			(minDate && year < minDate.get('year')) ||
			(maxDate && year > maxDate.get('year')) ||
			(
				(availableDates != null) && (
					availableDates[year] == null ||
					Object.getLength(availableDates[year]) == 0 ||
					Object.getLength(
						Object.filter(availableDates[year], function(days){
							return (days.length > 0);
						})
					) == 0
				)
			)
		);
	}

	if (type == 'month'){
		var year = date.get('year'),
			month = date.get('month') + 1,
			ms = date.format('%Y%m').toInt();
		return (
			(minDate && ms < minDate.format('%Y%m').toInt()) ||
			(maxDate && ms > maxDate.format('%Y%m').toInt()) ||
			(
				(availableDates != null) && (
					availableDates[year] == null ||
					availableDates[year][month] == null ||
					availableDates[year][month].length == 0
				)
			)
		);
	}

	// type == 'date'
	var year = date.get('year'),
		month = date.get('month') + 1,
		day = date.get('date');
	return (
		(minDate && date < minDate) ||
		(maxDate && date > maxDate) ||
		(
			(availableDates != null) && (
				availableDates[year] == null ||
				availableDates[year][month] == null ||
				!availableDates[year][month].contains(day)
			)
		)
	);
};


// Parse times
Date.defineParsers(
	'%H:%M( ?%p)?' // "11:05pm", "11:05 am" and "11:05"
);

})();
