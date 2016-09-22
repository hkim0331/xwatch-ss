#!/usr/bin/env ruby
# coding: utf-8
# this only for ubuntu, depends on xcowsay. not work on osx.
#

def usage
  print <<EOM
usage:
  #{$0} [--debug]
        [--image image_file]
        [--interval sec]
        [--thres n]
        [--txt text]
        [--allow pat1] [--allow pat2] ...
EOM
end

$allow = %w{ ssh imaps 1e100.net }

# FIXME: should compile $allow?
# FIXME: avoid using global variables?
def remove_allowed(array)
  ret = []
  puts "*before*\n#{array.join}" if $debug
  array.each do |entry|
    found = false
    $allow.each do |pat|
      if entry =~ /#{pat}/
        found = true
        break
      end
    end
    ret.push(entry) unless found
  end
  puts "*after*\n#{ret.join}" if $debug
  ret
end

def ss()
  IO.popen("/bin/ss -rt | grep ESTAB | grep -v kyutech") do |pipe|
    ret = remove_allowed(pipe.readlines)
    ret.count
  end
end

def warn(image, txt)
  cmd = "xcowsay --image=#{image} #{txt}"
  system cmd
end

def xwatch(image, interval, thres, txt)
  puts "#{image}, #{interval}, #{thres}, #{txt}" if $debug
  while (true)
    warn(image, txt) if ss() > thres
    sleep interval
  end
end

#
# main starts here
#

if `which xcowsay` == ""
  print <<EOM
#{$0} depends on xcowsay.
Your system has xcowsay?
EOM
  exit
end

$debug = false
image = "./images/ghost-busters.png"
interval = 30
thres = 2
txt = "授業と関係ないサイトを開いてないか？"

while (arg = ARGV.shift)
  case arg
  when /--debug/
    $debug = true
    interval = 5
    txt = "デバッグ中です"
  when /--image/
    image = ARGV.shift
  when /--interval/
    interval = ARGV.shift.to_i
  when /--thres/
    thres = ARGV.shift.to_i
  when /--txt/
    txt = ARGV.shift
  when /--allow/
    $allow.push ARGV.shift
  else
    usage()
    exit
  end
end

xwatch(image, interval, thres, txt)
rails "bug. must not comes here."
