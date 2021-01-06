
require 'libxml-ruby'

class XMLCallbacks

    include LibXML::XML::SaxParser::Callbacks

    def initialize(dst)
        @dst = dst
        @depth = 0
    end

    def on_start_element(name, attrs)
        @depth += 1
        case @depth
        when 2  # row element start
            @row = attrs
        when 3  # item element start
            @key = attrs.first[1]
            @val = ''
        end
    end

    def on_end_element(name)
        case @depth
        when 2  # row element end
            @dst.row @row
            @row = nil
        when 3  # item element end
            @row[@key] = @val
            @key = @val = nil
        end
        @depth -= 1
    end

    def on_characters chars
        @val << chars if @val
    end

    def on_cdata_block chars
        @val << chars if @val
    end

end

class FromXML < FinPipe

    def initialize(io = nil)
        @io = io
    end

    def call(io = nil)
        io = @io unless io
        # TODO: ensure close file
        parser = io.is_a?(String) ? LibXML::XML::SaxParser.file(io) : LibXML::XML::SaxParser.io(io)
        parser.callbacks = XMLCallbacks.new @dst
        parser.parse
    end

end

class ToXML

    def initialize(io, root, row, item = nil, attr = nil, *attrs, **options)
        @io = io
        @root = root
        @row = row
        @item = item
        @attr = attr
        @attrs = attrs
        @options = options
    end

    def head(row)
        @xml ||= start()
    end

    def row(row)
        @xml ||= start()
        @xml.start_element(@row)
        if @item
            row.each do |key, val|
                next unless @attrs.include? key
                @xml.write_attribute(key.to_s, val.to_s)
            end
            row.each do |key, val|
                next if @attrs.include? key
                @xml.start_element(@item)
                @xml.write_attribute(@attr.to_s, key.to_s)
                @xml.write_string(val.to_s)
                @xml.end_element()
            end
        else
            row.each do |key, val|
                @xml.write_attribute(key.to_s, val.to_s)
            end
        end
        @xml.end_element()
    end

    def finish(ok)
        if ok && @xml
            @xml.end_element()
            @xml.end_document()
        end
        @io.close if @close
    end

    private

    def start()
        if @io.is_a? String
            @io = File.new(@io, 'w')
            @close = true
        end
        xml = LibXML::XML::Writer.io(@io)
        xml.set_indent(@options[:indent])
        xml.set_indent_string(@options[:indent_string])

        xml.start_document(encoding: LibXML::XML::Encoding::UTF_8)
        xml.start_element(@root)
        xml
    end

end
