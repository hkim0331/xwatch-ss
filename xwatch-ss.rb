#!/usr/bin/env ruby
# coding: utf-8
# this only for ubuntu, depends on xcowsay. not work on osx.
#
# FIXME: add --allow pat

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

$allow = %w{ 1e100.net }

# FIXME
def remove_allowed(array)
  array
end

def ss()
  IO.popen("/bin/ss -rt | grep -v kyutech") do |pipe|
    ret = remove_allowed(pipe.readlines)
    puts ret if $debug
    ret.count
  end
end

def warn(image, txt)
  cmd = "xcowsay --image=#{image} #{txt}"
  puts cmd if $debug
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
    thres = 1
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
