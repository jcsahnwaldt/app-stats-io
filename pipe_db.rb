
require 'sqlite3'

class FromDB < FinPipe

    def initialize(path = nil, table = nil)
        @path = path
        @table = table
    end

    def call(path = nil, table = nil)
        path = @path unless path
        table = @table unless table
        SQLite3::Database.new(path) do |db|
            select = %{SELECT * FROM "#{table}";}
            db.prepare(select) do |stmt|
                result = stmt.execute()
                @dst.head(stmt.columns)
                result.each_hash { @dst.row(_1) }
            end
        end
    end

end

class ToDB

    def initialize(path, table)
        @path = path
        @table = table
    end

    def head(row)
        @db ||= start()
    end

    def row(row)
        @db ||= start()
        @stmt ||= prepare_db(row)
        @stmt.execute row.values
    end

    def finish(ok)
        if @db
            if ok then @db.commit
            else @db.rollback end
            @stmt.close if @stmt
            @db.close
        end
    end

    private

    def start()
        db = SQLite3::Database.new(@path)
        db.transaction
        db
    end

    def prepare_db(row)
        drop = %{DROP TABLE IF EXISTS "#{@table}";}

        types = Hash.new('BLOB').merge!(Integer => 'INTEGER', Float => 'REAL', String => 'TEXT')
        col_types = row.map { |key, val| %{"#{key}" #{types[val.class]}} }.join(', ')
        create = %{CREATE TABLE "#{@table}" (#{col_types});}

        params = row.map{'?'}.join(', ')
        insert = %{INSERT INTO "#{@table}" VALUES (#{params});}

        @db.execute drop
        @db.execute create
        @db.prepare insert
    end

end
