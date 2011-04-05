window.addEvent('domready', function()
{
  $('standard_notification').addEvent('click', function(event)
  {
    event.stop();
    
    // Trigger a new notification
    new Zen.Notification(
    {
      title: 'Standard Notification',
      content: 'This is an example of a standard notification',
      image: '../images/info.png'
    });
  });
  
  $('sticky_notification').addEvent('click', function(event)
  {
    event.stop();
    
    // Trigger a new notification
    new Zen.Notification(
    {
      title: 'Sticky Notification',
      content: 'This is an example of a sticky notification. You\'ll have to click it in order to remove it.',
      image: '../images/info.png',
      sticky: true
    });
  });
  
  $('delay_notification').addEvent('click', function(event)
  {
    event.stop();
    
    // Trigger a new notification
    new Zen.Notification(
    {
      title: 'Delayed Notification',
      content: 'This notification will fade out after 5 seconds.',
      image: '../images/info.png',
      duration: 5000
    });
  });
});
