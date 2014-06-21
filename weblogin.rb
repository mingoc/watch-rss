#!/usr/bin/env ruby
require 'rubygems'
require 'mechanize'

agent = Mechanize.new
agent.get('http://www.hi-pda.com/forum/logging.php?action=login') do |page|

  page.forms[0]["username"] = "cxmtime"
  page.forms[0]["password"] = "jzss1783" 
  page.forms[0].submit
end

agent.get('http://www.hi-pda.com/forum/forumdisplay.php?fid=2') do |page|
  agent.page.links.each do |link|
    text = link.text.strip        
    puts "#{text}|#{link.href}" 
  end
end

 
#puts page.at('#top-story h2').text.strip

