namespace :clean do
  desc 'Removes all built gems'
  task :gem do
    glob_pattern = File.expand_path('../../../../pkg/*.gem', __FILE__)

    Dir.glob(glob_pattern).each do |gem|
      File.unlink(gem)
    end
  end

  desc 'Removes all YARD files'
  task :yard do
    require 'fileutils'

    root = File.expand_path('../../../../', __FILE__)

    FileUtils.rm_rf("#{root}/doc")
    FileUtils.rm_rf("#{root}/.yardoc")
  end

  desc 'Removes all spec assets'
  task :assets do
    path = File.expand_path('../../../../spec/public/minified/*', __FILE__)

    Dir.glob(path).each do |file|
      File.unlink(file)
    end
  end
end
