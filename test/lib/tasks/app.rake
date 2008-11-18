namespace :app do
  desc 'Delete generate model views and controllers'
  task :prepare do
    File.delete(*FileList["app/**/*"].reject{|item| File.directory?(item) || item =~ /application/ })
    File.delete(*FileList["db/migrate/*"])
  end
  
  desc 'Delete models re-generate the short_message_service'
  task :regenerate => :prepare do
    exec('ruby script/generate short_message_service short_message delivery_receipt -s')
    Rake::Task['app:db:recreate'].invoke
  end
  
  namespace :db do
    desc 'Recreate database'
    task :recreate do
      Rake::Task['db:drop'].invoke
      Rake::Task['db:create'].invoke
      Rake::Task['db:migrate'].invoke
      Rake::Task['db:test:clone'].invoke
    end
  end
end
