namespace :clean do
  desc 'Removes all the gems located in pkg/'
  task :gem do
    glob_pattern = __DIR__('../../../pkg/*.gem')

    Dir.glob(glob_pattern).each do |gem|
      File.unlink(gem)
    end
  end

  desc 'Removes all YARD files'
  task :yard do
    require 'fileutils'

    root = __DIR__('../../../')

    FileUtils.rm_rf("#{root}/doc")
    FileUtils.rm_rf("#{root}/.yardoc")
  end

  desc 'Removes all the minified assets used for the specs'
  task :assets do
    path = __DIR__('../../../spec/public/minified/*')

    Dir.glob(path).each do |file|
      File.unlink(file)
    end
  end
end
