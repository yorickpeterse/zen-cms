window.addEvent('domready', function()
{
  // Create a new instance of a regular set of tabs
  Zen.Objects.Tabs = new Zen.Tabs('.tabs');
  
  // Create a new instance of a set of tabs powered by Ajax
  Zen.Objects.AjaxTabs = new Zen.Tabs('.ajax_tabs', { ajax: true, default: 'li:last-child' });
});