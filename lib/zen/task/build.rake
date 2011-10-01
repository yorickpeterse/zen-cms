namespace :build do
  desc 'Builds the documentation using YARD'
  task :doc do
    root = File.expand_path('../../../../', __FILE__)
    Dir.chdir(root)

    sh('rm -rf doc; yard doc')
  end

  desc 'Builds a new Gem'
  task :gem do
    root         = __DIR__('../../../')
    gemspec_path = File.join(
      root,
      "#{Zen::Gemspec.name}-#{Zen::Gemspec.version.version}.gem"
    )

    pkg_path = File.join(
      root,
      'pkg',
      "#{Zen::Gemspec.name}-#{Zen::Gemspec.version.version}.gem"
    )

    # Build and install the gem
    sh('gem', 'build'     , File.join(root, 'zen.gemspec'))
    sh('mv' , gemspec_path, pkg_path)
    sh('gem', 'install'   , pkg_path)
  end

  # Stolen from Ramaze
  desc 'Builds a list of all the people that have contributed to Zen'
  task :authors do
    authors = Hash.new(0)

    `git shortlog -nse`.scan(/(\d+)\s(.+)\s<(.*)>$/) do |count, name, email|
      authors[[name, email]] += count.to_i
    end

    File.open('AUTHORS', 'w+') do |io|
      io.puts "Following persons have contributed to Zen."
      io.puts '(Sorted by number of submitted patches, then alphabetically)'
      io.puts ''
      authors.sort_by{|(n,e),c| [-c, n.downcase] }.each do |(name, email), count|
        io.puts("%6d %s <%s>" % [count, name, email])
      end
    end
  end
end # namespace :build
