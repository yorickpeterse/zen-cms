require 'open3'

# Task group used for building various elements such as the Gem and the
# documentation.
namespace :build do
  desc 'Builds the documentation using YARD'
  task :doc do
    zen_path = File.expand_path('../../../../', __FILE__)
    command  = "yard doc #{zen_path}/lib -m markdown -M rdiscount -o #{zen_path}/doc "
    command += "-r #{zen_path}/README.md --private --protected"

    sh(command)
  end

  desc 'Builds a new Gem'
  task :gem do
    zen_path = File.expand_path('../../../../', __FILE__)

    # Build and install the gem
    sh("gem build #{zen_path}/zen.gemspec")
    sh("mv #{zen_path}/zen-#{Zen::Version}.gem #{zen_path}/pkg")
    sh("gem install #{zen_path}/pkg/zen-#{Zen::Version}.gem")
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
