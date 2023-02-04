
# generic base classes

class Pipe
    # note: operator >> would be the obvious choice, but operator ** is right-associative
    def **(dst)
        if @dst
            @dst.**(dst)
        else
            @dst = dst
        end
        self
    end
end

class FinPipe < Pipe
    def finish(ok)
        @dst.finish(ok)
    end
end

class Fork < Pipe
    def initialize(*dsts)
        @dsts = dsts
    end
end

class FinFork < Fork
    def finish(ok)
        @dsts.each { |dst| dst.finish(ok) }
        @dst.finish(ok) if @dst
    end
end

# generic row-handling classes

class PipeRows < FinPipe
    def head(row)
        @dst.head(row)
    end

    def row(row)
        @dst.row(row)
    end
end

class ForkRows < FinFork
    def head(row)
        @dsts.each { |dst| dst.head(row) }
        @dst.head(row) if @dst
    end

    def row(row)
        @dsts.each { |dst| dst.row(row) }
        @dst.row(row) if @dst
    end
end

def fork_rows(*dsts)
    ForkRows.new(*dsts)
end

# generic row-processing base classes

class ModRows < PipeRows
    def initialize(dup)
        @dup = dup
    end

    def head(row)
        @dst.head(mod_head(@dup ? row.dup : row))
    end

    def row(row)
        @dst.row(mod_row(@dup ? row.dup : row))
    end

    private

    def mod_head(row)
        mod(row)
    end

    def mod_row(row)
        mod(row)
    end

    def mod(row)
        row
    end
end

class FilterRows < PipeRows
    def initialize(keep)
        @keep = keep
    end

    def head(row)
        @dst.head(row) if test_head(row) == @keep
    end

    def row(row)
        @dst.row(row) if test_row(row) == @keep
    end

    private

    def test_head(row)
        test(row)
    end

    def test_row(row)
        test(row)
    end

    def test(row)
        @keep
    end
end

# concrete row-processing classes

class DropCols < ModRows
    def initialize(dup, *keys)
        super(dup)
        @keys = keys
    end

    private

    def mod(row)
        @keys.each { |key| row.delete(key) }
        row
    end
end

def drop_cols(*keys)
    DropCols.new(true, *keys)
end

def drop_cols!(*keys)
    DropCols.new(false, *keys)
end

class KeepCols < ModRows
    def initialize(dup, *keys)
        super(dup)
        @keys = keys
    end

    private

    def mod(row)
        row.delete_if { |key| ! @keys.include? key }
    end
end

def keep_cols(*keys)
    KeepCols.new(true, *keys)
end

def keep_cols!(*keys)
    KeepCols.new(false, *keys)
end

class MoveCols < ModRows
    def initialize(dup, **cols)
        super(dup)
        @cols = cols
    end

    private

    def mod_head(row)
        @cols.each { |key, _| row.delete(key); row << key }
        row
    end

    def mod_row(row)
        @cols.each { |key, val| row[key] = row.delete(key) { val } }
        row
    end
end

def move_cols(**cols)
    MoveCols.new(true, **cols)
end

def move_cols!(**cols)
    MoveCols.new(false, **cols)
end

class RenameCols < ModRows
    def initialize(dup, **cols)
        super(dup)
        cols.default_proc = -> { _2 }
        @cols = cols
    end

    private

    def mod_head(row)
        row.map! { @cols[_1] }
    end

    def mod_row(row)
        row.transform_keys! { @cols[_1] }
    end
end

def rename_cols(**cols)
    RenameCols.new(true, **cols)
end

def rename_cols!(**cols)
    RenameCols.new(false, **cols)
end

class AddCols < ModRows
    def initialize(dup, **cols)
        super(dup)
        @cols = cols
    end

    private

    def mod_head(row)
        @cols.each do |key, _|
            next if row.include? key
            row << key
        end
        row
    end

    def mod_row(row)
        @cols.each do |key, map|
            next if row.include? key
            row[key] = case map
            when Proc, Method then map[row]
            else map end
        end
        row
    end
end

def add_cols(**cols)
    AddCols.new(true, **cols)
end

def add_cols!(**cols)
    AddCols.new(false, **cols)
end

class MapCols < ModRows
    def initialize(dup, *rfns, **cfns)
        super(dup)
        @rfns = rfns
        @cfns = cfns
    end

    private

    def mod_row(row)
        @rfns.each { |fn| fn.call(row) }
        @cfns.each do |key, map|
            next unless row.include? key
            val = case map
            when Proc, Method, Hash then map[row[key]]
            # TODO: Proc or Method with arity two should take row[key] and row
            else map end
            raise "mapping for value '#{row[key]}' in column '#{key}' is nil" if val.nil?
            row[key] = val
        end
        row
    end
end

def map_cols(*rfns, **cfns)
    MapCols.new(true, *rfns, **cfns)
end

def map_cols!(*rfns, **cfns)
    MapCols.new(false, *rfns, **cfns)
end

class MapColsExcept < ModRows
    def initialize(dup, map, *except)
        super(dup)
        @map = map
        @except = except
    end

    private

    def mod_row(row)
        row.each do |key, val|
            next if @except.include? key
            row[key] = case @map
            when Proc, Method, Hash then @map[val]
            # TODO: Proc or Method with arity two should take val and row
            else @map end
        end
        row
    end
end

def map_cols_except(map, *except)
    MapColsExcept.new(true, map, *except)
end

def map_cols_except!(map, *except)
    MapColsExcept.new(false, map, *except)
end

class KeepRows < FilterRows
    def initialize(keep, *rfns, **cfns)
        super(keep)
        @rfns = rfns
        @cfns = cfns
    end

    private

    def test_row(row)
        @rfns.any? { |fn| fn.call(row) } ||
        @cfns.any? do |key, val|
            case val
            when Proc, Method, Hash then val[row[key]]
            when Array then val.include? row[key]
            else val == row[key] end
        end
    end
end

def keep_rows(*rfns, **cfns)
    KeepRows.new(true, *rfns, **cfns)
end

def drop_rows(*rfns, **cfns)
    KeepRows.new(false, *rfns, **cfns)
end

class ReduceCol < PipeRows
    def initialize(dup, col, init, op)
        @dup = dup
        @col = col
        @vals = Hash.new(init)
        @op = op.is_a?(Symbol) ? op.to_proc : op
    end

    def row(row)
        row = row.dup if @dup
        val = row[@col]
        row[@col] = nil
        @vals[row] = @op.call(@vals[row], val)
    end

    def finish(ok)
        if ok
            ok = false
            @vals.each do |row, val|
                row[@col] = val
                @dst.row(row)
            end
            ok = true
        end
    ensure
        @dst.finish(ok)
    end
end

def reduce_col(col, init, op)
    ReduceCol.new(true, col, init, op)
end

def reduce_col!(col, init, op)
    ReduceCol.new(false, col, init, op)
end

class AccumCols < PipeRows
    def initialize(init, op, val, *cols, **vals)
        @init = init
        @op = op.is_a?(Symbol) ? op.to_proc : op
        @val = val
        @cols = cols
        @vals = vals
    end

    def head(row)
        @row ||= init(row)
        super
    end

    def row(row)
        @row ||= init(row.keys)
        if @cols.empty?
            row.each_key do |key|
                next if @vals.include?(key)
                @row[key] = @op.call(@row[key], row[key])
            end
        else
            @cols.each do |key|
                @row[key] = @op.call(@row[key], row[key])
            end
        end
        super
    end

    def finish(ok)
        if ok
            ok = false
            @dst.row(@row)
            ok = true
        end
    ensure
        @dst.finish(ok)
    end

    private

    def init(keys)
        row = {}
        keys.each do |key|
            row[key] =
            if @vals.include?(key) then @vals[key]
            elsif @cols.empty? || @cols.include?(key) then @init
            else @val end
        end
        row
    end
end

def accum_cols(...)
    AccumCols.new(...)
end

class PivotRows < PipeRows
    def initialize(dup, kcol, vcol, default)
        @dup = dup
        @kcol = kcol
        @vcol = vcol
        @keys = {}
        @rows = Hash.new { |hash, key| hash[key] = Hash.new(default) }
    end

    def head(row)
        row = row.dup if @dup
        row.delete(@kcol)
        row.delete(@vcol)
        @heads = row
    end

    def row(row)
        row = row.dup if @dup
        key = row.delete(@kcol)
        val = row.delete(@vcol)
        @keys[key] = nil
        @rows[row][key] = val
    end

    def finish(ok)
        if ok
            ok = false
            keys = @keys.keys.sort!
            @dst.head(@heads + keys) if @heads
            @rows.each do |row, vals|
                keys.each { |key| row[key] = vals[key] }
                @dst.row(row)
            end
            ok = true
        end
    ensure
        @dst.finish(ok)
    end
end

def pivot_rows(kcol, vcol, default)
    PivotRows.new(true, kcol, vcol, default)
end

def pivot_rows!(kcol, vcol, default)
    PivotRows.new(false, kcol, vcol, default)
end

class UnpivotRows < PipeRows
    def initialize(dup, kcol, vcol, *keys)
        @dup = dup
        @kcol = kcol
        @vcol = vcol
        @keys = keys
    end

    def head(row)
        row = row.dup if @dup
        row.delete_if { @keys.include?(_1) }
        row << @kcol
        row << @vcol
        @dst.head(row)
    end

    def row(row)
        row = row.dup if @dup
        vals = row.slice(*@keys)
        row.delete_if { vals.include?(_1) }
        vals.each do |key, val|
            dup = row.dup
            dup[@kcol] = key
            dup[@vcol] = val
            @dst.row(dup)
        end
    end
end

def unpivot_rows(kcol, vcol, *keys)
    UnpivotRows.new(true, kcol, vcol, *keys)
end

def unpivot_rows!(kcol, vcol, *keys)
    UnpivotRows.new(false, kcol, vcol, *keys)
end

# generic IO classes

class EnsureFinish < Pipe
    def call(...)
        ok = false
        @dst.call(...)
        ok = true
    ensure
        @dst.finish(ok)
    end
end

def ensure_finish()
    EnsureFinish.new()
end

class EachFile < FinPipe
    def initialize(dir = nil, order = nil, *globs)
        @dir = dir
        @order = order
        @globs = globs
    end

    def call(dir = nil, order = nil, *globs)
        dir = @dir unless dir
        order = @order unless order
        @globs.concat(globs)
        names = Dir.glob(@globs, base: dir)
        if order
            names.sort_by!(&order)
        else
            names.sort!
        end
        names.each do |name|
            path = File.join dir, name
            @dst.call(path)
        end
    end
end

def each_file(...)
    EachFile.new(...)
end

class SingleHead < FilterRows
    def initialize
        super(false)
        @heads = 0
    end

    def row(row)
        if @heads == 0
            @dst.head(row.keys)
            @heads += 1
        end
        super
    end

    private

    def test_head(row)
        @heads += 1
        @heads > 1
    end
end

def single_head()
    SingleHead.new()
end

# CSV

def from_csv(...)
    require_relative 'pipe_csv'
    FromCSV.new(...)
end

def to_csv(...)
    require_relative 'pipe_csv'
    ToCSV.new(...)
end

# XML

def from_xml(...)
    require_relative 'pipe_xml'
    FromXML.new(...)
end

def to_xml(...)
    require_relative 'pipe_xml'
    ToXML.new(...)
end

# DB

def from_db(...)
    require_relative 'pipe_db'
    FromDB.new(...)
end

def to_db(...)
    require_relative 'pipe_db'
    ToDB.new(...)
end
