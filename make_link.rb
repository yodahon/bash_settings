#!/usr/bin/env ruby

require 'pp'
require 'time'
TS = Time.now
def ts;TS;end

def windows?
  ENV.key?("OS") and ENV["OS"].include?("Windows")
end

def user_dir
  return ENV["HOMEPATH"] if windows?
  require 'etc'
  return Etc.getpwuid.dir
end


def rename_file(dest_link)
    if File.exists?(dest_link)
      puts "[exists] '#{dest_link}'\nDo you want current file rename to '#{dest_link}.#{ts.to_i}'?[y/n]"
      if gets.downcase.strip == 'y'
        File.rename dest_link, "#{dest_link}.#{ts.to_i}"
      end
    end
end
def make_symlink user_dir, target
    dest_link = "%s/%s"% [user_dir,target]
    rename_file(dest_link)
    goal = dest_link
    unless File.exists?(goal)
      puts "[make]  #{goal}"
      File.symlink(File.expand_path(target), goal)
    else
      puts "[exists] #{goal}"
    end 
end


#for window
def make_mklink user_dir, target
  options = ""
  options = "/D" if File.directory? target
  goal = case target
    when ".vim" then "vimfiles"
    when ".hgrc" then "Mercurial.ini"
    else target
  end

  dest_link = "%s\\%s"% [user_dir,goal]
  rename_file(dest_link)
  cur_dir = `cmd /C cd`.strip

  cmd = "cmd /C 'mklink #{options} #{dest_link} #{cur_dir}\\#{target}'"
  puts "run #{cmd}"
  system(cmd)
end

Dir.chdir(File.dirname __FILE__) do 
  targets = Dir.glob(".*") + Dir.glob("*")
  targets -= %w(.. . .svn .bashrc .git README) << File.split(__FILE__)[1]

  puts "This script try link for \n\t#{targets.join("\n\t")}\nPress any key."
  gets
  targets.each do |target|
    make_symlink user_dir,target unless windows?
    make_mklink user_dir, target if windows?
  end
end


