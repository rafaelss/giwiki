namespace :git do

  desc 'Generate git repository for wiki pages'
  task :repos => :environment do
    puts `rm -rf pages && mkdir pages && cd pages && git init`

    File.open('pages/Welcome', 'w') do |f|
      f.print 'You need edit this page with relevant information'
    end

    puts `cd pages && git add Welcome && git commit -m 'added default files' --author='0 <admin@giwiki.com>'`
  end
end
