
require 'csv'

class FromCSV < FinPipe

    def initialize(path = nil, **options)
        @path = path
        @options = options
    end

    def call(path = nil)
        path = @path unless path
        CSV.foreach(path, **@options) do |row|
            if row.header_row?
                @dst.head(row.headers)
            else
                @dst.row(row.to_hash)
            end
        end
    end

end

class ToCSV

    def initialize(io, **options)
        @io = io
        @options = options
    end

    def head(row)
        @csv ||= start()
        @csv << row
    end

    def row(row)
        @csv ||= start()
        @csv << row.values
    end

    def finish(ok)
        @io.close if @close
    end

    private

    def start()
        if @io.is_a? String
            @io = File.new(@io, 'w')
            @close = true
        end
        CSV.new(@io, **@options)
    end

end
