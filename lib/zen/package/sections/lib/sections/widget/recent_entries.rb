# Widget that shows the 10 most recent section entries.
Dashboard::Widget.add do |w|
  w.name       = :recent_entries
  w.title      = 'section_entries.widgets.titles.recent_entries'
  w.permission = :show_section_entry
  w.data       = lambda do |instance|
    entries = Sections::Model::SectionEntry.order(:created_at.desc).limit(10)

    return render_file(
      __DIR__('../view/admin/section-entries/recent_entries.xhtml'),
      :entries => entries
    )
  end
end
