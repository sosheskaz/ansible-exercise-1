#!/usr/bin/env ruby
require 'securerandom'

puts 'Enter your AWS access key.'
aws_access = gets
puts 'Enter your AWS secret key.'
aws_secret = gets
puts 'Enter the VPC ID to run under.'
vpc = gets
puts 'Enter your email.'
email = gets

dir = File.dirname(__FILE__)
def pw()
  return SecureRandom.uuid
end

open("#{dir}/vars/secrets.yml", 'w') { |f|
  f.puts "aws_access_key: #{aws_access}"
  f.puts "aws_secret_key: #{aws_secret}"
  f.puts "aws_vpc_id: #{vpc}"
  f.puts "wp_admin_email: #{email}"
  f.puts "wp_admin_pass: #{pw()}"
  f.puts "mysql_root_password: #{pw()}"
  f.puts "wp_db_password: #{pw()}"
}

`ansible-vault encrypt #{dir}/vars/secrets.yml`
