#!/usr/bin/env ruby
# encoding: utf-8
require 'rubygems'
require 'mechanize'
require 'mail'

record_file="watch-record.txt"
watch_keyword=["奶粉","德国","爱他美", "喜宝","三星" ]
$login_url='http://www.hi-pda.com/forum/logging.php?action=login'

urls = ['http://www.hi-pda.com/forum/forumdisplay.php?fid=2',
       'http://www.hi-pda.com/forum/forumdisplay.php?fid=6'
      ]




mail_options = { :address         => "smtp.webfaction.com",
            :port                 => 587,
            :domain               => 'HiPDA',
            :user_name            => 'sumeiq',
            :password             => 'jzss1783',
            :authentication       => 'plain',
            :enable_starttls_auto => true  }

Mail.defaults do
  delivery_method :smtp, mail_options
end

Dir.chdir(File.dirname(__FILE__))
#puts Dir.pwd

def submit_login(agent)
    agent.get($login_url) do |page|
      page.forms[0]["username"] = "cxmtime"
      page.forms[0]["password"] = "jzss1783" 
      page.forms[0].submit
    end
    puts "login done. save cookie."
    agent.cookie_jar.save_as( 'cookies.yml', :session => true, :format => :yaml)
end

def login(agent)
  if !agent.cookie_jar.load 'cookies.yml'
       puts "load cookie fail. login again "
    submit_login(agent)
  end
end


agent = Mechanize.new
login(agent)

urls.each() do |url|
  agent.get(url) do |page|
    agent.page.links.each do |link|
      if link.href.include?('logging.php?action=login')
          puts "need login again."
          submit_login(agent)
          break
      end
      text = link.text.strip        
      #puts "#{text}|#{link.href}" 
      if watch_keyword.any? { |word| text.include?(word) } 
          puts "find： #{link.href} "
          if !File.readlines(record_file).any? { |line| line.include?(link.href)}
             puts "Not in record history."
             Mail.deliver do
               to 'sumeiq@gmail.com'
               from 'denila@hkgreentree.com'
               subject "HIPDA! #{text}"
               body "http://hi-pda.com/forum/#{link.href} "
             end
             File.open(record_file, 'a') { |file| file.puts("#{link.href}\n") }
          end          
      end
    end
  end
end







