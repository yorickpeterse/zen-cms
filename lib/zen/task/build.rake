namespace :build do
  desc 'Generates a .gems file for RVM'
  task :gems do
    handle   = File.open(File.expand_path('../../../../.gems', __FILE__), 'w')
    run_deps = ['# Runtime Dependencies']
    dev_deps = ['# Development Dependencies']

    GEMSPEC.dependencies.each do |gem|
      if gem.type == :runtime
        run_deps << gem.name + ' -v ' + gem.requirement.to_s.gsub('~> ', '')
      else
        dev_deps << gem.name
      end
    end

    handle.write(run_deps.sort.join("\n") + "\n\n" + dev_deps.sort.join("\n"))
    handle.close
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
