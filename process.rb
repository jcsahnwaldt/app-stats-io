
require_relative 'pipe'
require 'date'

def replace(**hash) -> key, * { hash.fetch(key) { _1 } } end
def nil_except(*keys) -> key, * { key if keys.include?(key) } end
def abbr_sym() -> s, * { s.split(' ')[0].downcase.to_sym if s } end

$src_options = {
    strip: ' ',
    headers: true,
    return_headers: true,
    nil_value: ''
}

$csv_options = {
    quote_empty: false
}

$xml_options = {
    indent: true,
    indent_string: '  '
}

$string = method(:String)
$integer = method(:Integer)
def date(fmt) -> { Date.strptime(_1, fmt) } end
def sum(cls) -> row { row.select{ _1.is_a?(cls) }.values.sum } end

def to_csv_xml_db(prefix)
    fork_rows(
        to_csv("#{prefix}.csv", **$csv_options),
        to_xml("#{prefix}.xml", 'data', 'entry', 'units', 'version', :year, **$xml_options),
        to_db("#{prefix}.db", 'data')
    )
end

def calc_sums()
    reduce_col!(:units, 0, :+) **
    pivot_rows!(:version, :units, 0) **
    add_cols(all: sum(Gem::Version)) **
    accum_cols(0, :+, nil, year: 'all')
end
