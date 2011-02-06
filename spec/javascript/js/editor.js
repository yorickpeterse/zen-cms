window.addEvent('domready', function()
{
  new Zen.Editor.Base('.editor').display();
  new Zen.Editor.Base('.textile' , {format: 'textile'}).display();
  new Zen.Editor.Base('.markdown', {format: 'markdown'}).display();
  
  // Custom editor buttons
  custom = new Zen.Editor.Base('.custom', {format: 'html'})
  custom.addButtons(
  [
    {name: 'alert' , html: 'Alert!', callback: function() {alert("Alert alert!");}},
    {name: 'smiley', html: ':D'    , callback: function() {alert(":D");}}
  ]);
  
  custom.display();
});