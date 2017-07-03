#!/usr/bin/env ruby
# This is in ruby because ruby is more portable to Windows than sh.
require 'open3'

dir = File.dirname(__FILE__)

puts "/usr/bin/env ansible-playbook -i #{dir}/hosts -v #{dir}/main.yml"

open("#{dir}/playbook.log", 'w') { |f|
  Open3.popen2e("/usr/bin/env ansible-playbook -i #{dir}/hosts #{dir}/main.yml") do |stdin, stdout_and_stderr, wait_thr|
    while line=stdout_and_stderr.gets do
      puts line
      f.puts line
      f.flush
    end
  end
}
