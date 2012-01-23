namespace :build do
  desc 'Build the YARD docs'
  task :doc => ['clean:yard'] do
    root = File.expand_path('../../../../', __FILE__)
    Dir.chdir(root)

    sh('yard doc')
  end

  desc 'Builds a new Gem'
  task :gem do
    root = File.expand_path('../../../../', __FILE__)
    name = "#{Zen::Gemspec.name}-#{Zen::Gemspec.version.version}.gem"
    path = File.join(root, name)
    pkg  = File.join(root, 'pkg', name)

    # Build and install the gem
    sh('gem', 'build', File.join(root, 'zen.gemspec'))
    sh('mv' , path, pkg)
    sh('gem', 'install', pkg)
  end

  # Stolen from Ramaze
  desc 'Build a list of contributors'
  task :authors do
    authors = Hash.new(0)

    `git shortlog -nse`.scan(/(\d+)\s(.+)\s<(.*)>$/) do |count, name, email|
      authors[[name, email]] += count.to_i
    end

    File.open('AUTHORS', 'w+') do |io|
      io.puts "Following persons have contributed to Zen."
      io.puts '(Sorted by number of submitted patches, then alphabetically)'
      io.puts ''
      authors.sort_by { |(n,e),c| [-c, n.downcase] }.each do |(name, email), count|
        io.puts("%6d %s <%s>" % [count, name, email])
      end
    end
  end

  desc 'Build a list of changes'
  task :changes, [:tag] do |t, args|
    args.with_defaults(:tag => `git tag`.split(/\n/)[-1])

    stop = `git log -1 --pretty=oneline --color=never`.split(/\s+/)[0]
    log  = `git --no-pager log --color=never --pretty=oneline \
      #{args[:tag]}..#{stop}`.split(/\n/)

    log.each do |line|
      line    = line.split(/\s+/, 2)[1].strip
      wrapped = '* '
      chars   = 0

      # Wrap the string
      line.split(/\s+/).each do |chunk|
        length = chunk.length

        if ( chars + length ) <= ( 80 - length )
          wrapped += "#{chunk} "
          chars   += length
        else
          wrapped += "\n  #{chunk} "
          chars    = 0
        end
      end

      puts wrapped
    end
  end
end
