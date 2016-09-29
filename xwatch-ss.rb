#!/usr/bin/env ruby
# coding: utf-8
# this only for ubuntu, depends on xcowsay. not work on osx.
# 2016-09-23, 2016-09-29

def usage
  print <<EOM
Usage:
  #{$0} [--debug]
        [--image image_file]
        [--interval sec]
        [--thres n]
        [--txt text]
        [--allow pat1] [--allow pat2] ...
        [--version]
Example:

EOM
end

def remove_permits(lines, permits)
  puts "*before*\n#{lines.join}" if $debug
  ret = lines.find_all do |line|
    permits.all? do |pat|
      line !~ pat
    end
  end
  puts "*after*\n#{ret.join}" if $debug
  ret
end

def ss(permits)
  IO.popen("/bin/ss -rt | grep ESTAB | grep -v kyutech") do |pipe|
    remove_permits(pipe.readlines, permits)
  end
end

def warn(image, txt)
  cmd = "xcowsay --image=#{image} #{txt}"
  system cmd
end

def xwatch(image, interval, thres, txt, permits)
  puts "#{image}, #{interval}, #{thres}, #{txt}" if $debug
  while (true)
    warn(image, txt) if ss(permits).count > thres
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

# initial values
# 1e100.net amazonaws.com cloudfront.net
allow = %w{ ssh imaps }
image = "./images/ghost-busters.png"
interval = 30
thres = 10
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
    allow.push ARGV.shift
  else
    usage()
    exit
  end
end

xwatch(image, interval, thres, txt, allow.map{|x| Regexp.new(x)})
raise "bug. must not comes here."
