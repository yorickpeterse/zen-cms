window.addEvent('domready', function()
{
  $('normal').addEvent('click', function(event)
  {
    event.preventDefault(); new Zen.Modal("Normal modal window");
  });
  
  $('fullscreen').addEvent('click', function(event)
  {
    event.preventDefault(); new Zen.Modal("Fullscreen modal window", {fullscreen: true});
  });
});