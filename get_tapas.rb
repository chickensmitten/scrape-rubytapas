#trying to resolve  cannot load such file -- mechanize"
require 'mechanize'

BATCH_SIZE = 2

def say(msg, important = false)
  puts "" if important
  puts "#{important ? '-->' : '-'} " + msg
end

def exit_with(msg)
  say msg
  puts "...existing..."
  exit
end

a = Mechanize.new

say "Logging in..."

a.get('https://rubytapas.dpdcart.com/subscriber/content') do |page|
  content_page = page.form_with(id: 'login-form') do |f|
    f.username = 'user@example.com'
    f.password = 'secret'
  end.click_button

  say "Got page: " + content_page.title

  exist_with("Couldn't log in.") if content_page.title =~ /Login/

  count = 0
  a.page.parser.css('div.blog-entry').each do |entry|
    # create a new dir, based on entry name, and switch into new dir
    entry_title = entry.css('h3').first.content rescue nil
    entry_title ? say("Found entry: " + entry_title, true) : next

    dir_name = entry_title.gsub(/\W/, '_')

    if Dir.exists?(dir_name)
      say "#{dir_name} already exists, skipping..."
      next
    else
      say 'creating dir: ' + dir_name
      Dir.mkdir(dir_name)
    end

    Dir.chdir(dir_name)
    say "in dir: " + `pwd`

    # drill down to content-post-meta

    url = entry.css('div.content-post-meta a').first['href'] rescue nil

    if url
      #click on link
      download_page = a.get(url)
      say "downloading files at: " + download_page.title

      #download links on content page
      download_page.links_with(:href => /subscriber\/download/).each do |link|
        say "downloading... " + link.inspect
          files = a.click(link)
          File.open(file.filename, 'w+b') do |f|
            f << file.body.strip
          end
      end
    else
      say "couldn't find url #{url}, skippin... "
      next
    end

    Dir.chdir('..')
    say "back out: " + `pwd`

    exit if count == BATCH_SIZE
    count += 1
  end
end



















