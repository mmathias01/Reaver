# Usage:
# git log | ruby git_commit_parser.rb
# https://gist.github.com/881641
# By: Jason Amster
# jayamster@gmail.com

require 'rubygems'
require 'pp'
require 'rubygems'
require 'zip/zipfilesystem'
require 'fileutils'

def execute(command, directory = ".")
    directory = ARGV.first unless ARGV.empty?
    `cd #{directory}; #{command}`
end

logs = execute "git show --pretty=\"format:\" --name-only HEAD"
logs = logs.split("\n")
logs.shift

logs = logs.map do |log|
  l = log.split("/")
  l.pop
  folder = l
  log = folder.join('/')
end
pp logs.uniq
