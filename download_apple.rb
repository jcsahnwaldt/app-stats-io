#!/usr/bin/env ruby

# Reverse engineered from Reporter.jar
# See https://help.apple.com/itc/appsreporterguide/

if ARGV.length == 0
    require_relative 'config'
    $token, $vendor, $delay, $dir = APPLE_TOKEN, APPLE_VENDOR, APPLE_DELAY, APPLE_DOWNLOAD_DIR
elsif ARGV.length == 4
    $token, $vendor, $delay, $dir = ARGV
else
    raise 'expected arguments: access token, vendor number, delay, target directory'
end
$delay = Float($delay)

require 'net/http'
require 'json'
require 'date'
require 'zlib'
require 'fileutils'

$counts = Hash.new(0)
$lock = Mutex.new

def log(key, mode, date, msg = nil)
    puts "#{key} #{mode} #{date} #{msg}"
    $lock.synchronize do
        $counts[key] += 1
    end
end

$uri = URI('https://reportingitc-reporter.apple.com/reportservice/sales/v1')

$threads = []

def download(mode, date)
    $threads << Thread.new do
        cmd = "_=, Sales.getReport, #{$vendor},Sales,Summary,#{mode},#{date},"
        query = {
            accesstoken: $token,
            queryInput: cmd
        }
        tries = 0
        log('START', mode, date)
        begin
            res = Net::HTTP.post_form($uri, jsonRequest: JSON.generate(query))
            name = res['filename']
            if name
                gz = name.end_with?('.gz')
                dst = File.join($dir, gz ? name[0..-4] : name)
                FileUtils.mkdir_p($dir)
                IO.write(dst, gz ? Zlib.gunzip(res.body) : res.body)
                log('OK   ', mode, date, res['downloadMsg'])
            else
                log("#{res.code}  ", mode, date, "#{res.msg}: #{res.body}")
            end
        rescue => e
            tries += 1
            if tries < 2
                log('RETRY', mode, date, e)
                sleep(tries * $delay)
                retry
            else
                log('FAIL ', mode, date, e)
            end
        end
    end
end

def download_all(mode, date, last, method, delta, pat)
    while date < last
        download(mode, date.strftime(pat))
        date = date.send(method, delta)
        sleep($delay)
    end
end

now = Date.today

last = now
first = last.next_day(-365)
download_all('Daily  ', first, last, :next_day, 1, '%Y%m%d')

last = now + 7 - now.wday  # next sunday
first = last.next_day(-53 * 7)
download_all('Weekly ', first, last, :next_day, 7, '%Y%m%d')

last = Date.new(now.year, now.month, 1)
first = last.next_month(-12)
download_all('Monthly', first, last, :next_month, 1, '%Y%m  ')

last = Date.new(now.year, 1, 1)
first = Date.new(2013)
download_all('Yearly ', first, last, :next_year, 1, '%Y    ')

$threads.each &:join

puts 'counts:'
$counts.each { |key, count| puts "#{key} #{count}" }
