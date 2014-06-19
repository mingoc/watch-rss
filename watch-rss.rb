#!/usr/bin/ruby
# encoding: utf-8
require 'rss'
require 'open-uri'
require 'mail'

mail_options = { :address         => "smtp.gmail.com",
            :port                 => 587,
            :domain               => 'HiPDA',
            :user_name            => 'wayle007',
            :password             => 'jzss1783',
            :authentication       => 'plain',
            :enable_starttls_auto => true  }

Mail.defaults do
  delivery_method :smtp, mail_options
end

record_file="record.txt"
watch_keyword=["奶粉","德国","爱他美", "喜宝" ]
urls = ['http://www.hi-pda.com/forum/rss.php?fid=2&auth=9cc34SwRu9d2A2lsQid%2FII%2FCp8Dv2SJEKR51tr7ZmDGRzH2Yt0bZcIXMj5ukQQ',
       'http://www.hi-pda.com/forum/rss.php?fid=6&auth=0dd3CvP%2Fv9mVePbuWnQ%2BksYa35kcwa4RD0XB1JMOc3h1c4ETMSOpzl8oQ3U9og'
      ]

urls.each() do |url|
    open(url) do |rss|
      feed = RSS::Parser.parse(rss)
      puts "Title: #{feed.channel.title}"
      feed.items.each do |item|
        content=item.description  #.gsub!(/(<[^>]*>)|\n|\t/s) {" "}     
        puts "Item: #{item.title}"
        if  watch_keyword.any? { |word| item.title.include?(word) } || watch_keyword.any? { |word| content.include?(word) } 
          if !File.readlines(record_file).any? { |line| line.include?(item.link)}
             puts "match!"
             Mail.deliver do
               to 'sumeiq@gmail.com'
               from 'HIPDA'
               subject "HIPDA! #{item.title}"
               body "#{content}\n#{item.link} "
           end
          File.open(record_file, 'a') { |file| file.puts("#{item.link}\n") }
         end
          
        end
      end
    end
end







