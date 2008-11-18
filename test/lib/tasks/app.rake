namespace :app do
  desc 'Delete generate model views and controllers'
  task :prepare do
    File.delete(*FileList["app/**/*"].reject{|item| File.directory?(item) || item =~ /application/ })
    File.delete(*FileList["db/migrate/*"])
  end
  desc 'Recreate database'
  task :recreate do
    Rake::Task['db:drop'].invoke
    Rake::Task['db:create'].invoke
    Rake::Task['db:migrate'].invoke
    Rake::Task['db:test:clone'].invoke
  end
end
