# The welcome widget shows a welcome message explaining a few things about Zen.
# It also shows a list of links to common resources such as the documentation.
Dashboard::Widget.add do |w|
  w.name  = :welcome
  w.title = 'dashboard.widgets.titles.welcome'
  w.data  = lambda do |instance|
    return render_file(__DIR__('../view/admin/dashboard/widget/welcome.xhtml'))
  end
end
