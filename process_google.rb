
raise 'expected arguments: src dir, dst prefix, versions file' if ARGV.length != 3
$src_dir, $dst_prefix, $versions_file = ARGV

require_relative 'process'

header_converter =
    replace('App Version Code' => 'Version', 'Daily Device Installs' => 'Units') >>
    nil_except('Date', 'Version', 'Units') >>
    abbr_sym()

$src_options[:header_converters] = header_converter

$versions = {}
CSV.foreach($versions_file, col_sep: "\t") do |row|
    next unless row[4]  # skip unpublished versions
    $versions[row[3]] = Gem::Version.new(row[2])
end
$date = date('%Y-%m-%d')

pipe =
ensure_finish() **

# read files
each_file($src_dir, nil, '**/installs_*_app_version.csv') **
from_csv(**$src_options) **
single_head() **

# clean columns
drop_cols!(nil) **

# parse data
map_cols!(date: $date, version: $versions, units: $integer) **

# prepare for output
map_cols!(date: -> { _1.year }) **
rename_cols!(date: :year) **

# process and output
calc_sums() **
to_csv_xml_db($dst_prefix)

pipe.call()
