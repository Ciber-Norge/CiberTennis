# -*- coding: utf-8 -*-
require_relative 'web.rb'

require 'gmail'

SCHEDULER_DAY = ENV['SCHEDULER_DAY'] || "monday"
SPORTS_DAY = ENV['SPORTS_DAY'] || "wednesday"

unless GMAIL_USERNAME = ENV['GMAIL_USERNAME']
  raise "You must specify the GMAIL_USERNAME env variable"
end

unless GMAIL_PASSWORD = ENV['GMAIL_PASSWORD']
  raise "You must specify the GMAIL_PASSWORD env variable"
end

unless MAILING_LIST = ENV['MAILING_LIST']
  raise "You must specify the MAILING_LIST env variable"
end

def start_task
  now = DateTime.now
  p "Running scheduler at #{now}"
  if now.send(SCHEDULER_DAY + "?") then
    p "It's #{SCHEDULER_DAY}, time to make an event"
    while not now.send(SPORTS_DAY + "?") do
      now = now + 1
    end
    add_event! DateTime.new(now.year, now.month, now.day, 18, 0, 0, 0)
    p "Sending e-mails to users"
    send_email()
    p "Done with task"
  else
    p "It's not #{SCHEDULER_DAY}..."
  end
end

def send_email
  Gmail.connect!(GMAIL_USERNAME, GMAIL_PASSWORD) { | gmail | 
    gmail.deliver do
      to MAILING_LIST
      subject ENV['MAIL_SUBJECT']
      text_part do
        content_type 'text/text; charset=UTF-8'
        body ENV['MAIL_BODY_TEXT']
      end
      html_part do
        content_type 'text/html; charset=UTF-8'
        body ENV['MAIL_BODY_HTML']
      end
    end
  }
end

start_task
