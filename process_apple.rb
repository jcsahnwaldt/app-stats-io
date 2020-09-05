#!/usr/bin/env ruby

if ARGV.length == 0
    require_relative 'config'
    $src_dir, $dst_prefix =  APPLE_DOWNLOAD_DIR, APPLE_PROCESS_PREFIX
elsif ARGV.length == 2
    $src_dir, $dst_prefix = ARGV
else
    raise 'expected arguments: src dir, dst prefix'
end

require_relative 'process'

header_converter =
    replace('Product Type Identifier' => 'Action') >>
    nil_except('Version', 'Action', 'Units', 'Begin Date', 'End Date', 'Country Code', 'Device') >>
    abbr_sym()

$src_options[:col_sep] = "\t"
$src_options[:header_converters] = header_converter

$actions = {'1' => 'install', '1F' => 'install', '3' => 're-install', '3F' => 're-install', '7' => 'update', '7F' => 'update'}
$version = Gem::Version.method(:new)
$date = date('%m/%d/%Y')

# sort by date, name format is S_Y_*_YYYY.txt and S_D_*_YYYYMMDD.txt
$file_order = -> name { name.match(/_(\d+)\.txt/)[1] }

pipe =
ensure_finish() **

# read files: only day data for 2020, only year data for other years
each_file($src_dir, $file_order, 'S_D_*_2020*.txt', 'S_Y_*.txt') **
from_csv(**$src_options) **
single_head() **

# clean columns
drop_cols!(nil) **

# parse data
map_cols!(begin: $date, end: $date, units: $integer, action: $actions) **

# remove garbage data
drop_rows(
    device: 'Desktop', country: 'CN', version: [nil, 'N/A'],  # garbage data
    action: ['update', 're-install']  # irrelevant
) **
drop_cols!(:device, :end, :country, :action) **

# prepare for output
map_cols!(version: $version, begin: -> { _1.year }) **
rename_cols!(begin: :year) **

# process and output
calc_sums() **
to_csv_xml_db($dst_prefix)

pipe.call()
