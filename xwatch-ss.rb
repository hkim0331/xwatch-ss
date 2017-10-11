#!/usr/bin/env ruby
# coding: utf-8
# this only for ubuntu, depends on xcowsay. not work on osx.
# 2016-09-23, 2016-09-29
# 2017-04-12,

def usage(s)
  puts s
  print <<EOM
Usage:
  #{$0} [--debug]
        [--conf file]
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

# linux only.
def ss(permits)
  IO.popen("/bin/ss -bt state established| awk '{print $4}'") do |pipe|
    remove_permits(pipe.readlines, permits)
  end
end

def warn(image, txt)
  cmd = "xcowsay --image=#{image} #{txt}"
  system cmd
end

# FIXME: 現行は conf ファイルの存在確認だけ。内容を見ていない。
def xwatch(conf, image, interval, thres, txt, permits)
  while File.exists?(conf)
    count = ss(permits).count
    if $debug
      puts "#{Time.now} permits: #{count} thres: #{thres}"
    end
    if ss(permits).count > thres
      warn(image, txt)
    end
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

# 1e100.net amazonaws.com cloudfront.net
allow = %w{ ^127 ^10 ^150.69 }

image = "./images/ghost-busters.png"
interval = 30
thres = 15
txt = "授業と関係ないサイトを開いてないか？"
conf = "/home/t/hkimura/Desktop/xwatch-ss.conf"

while (arg = ARGV.shift)
  case arg
  when /--debug/
    $debug = true
    txt = "デバッグ中です"
  when /--conf/
    config = ARGV.shift
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
  when /--conf/
    conf = ARGV.shift
  else
    usage("unknown arg: #{arg}")
    exit
  end
end

xwatch(conf, image, interval, thres, txt, allow.map{|x| Regexp.new(x)})
raise "bug. must not comes here."
