module Lolitado
  class Database

    attr_accessor :db

    def initialize db
      @db = db
    end

    # Return the data by sql.
    # @param [String] sql the sql you wanna query
    def query sql
      result = db[sql].all
      return result
    end

    # Return the data by sql.
    # @param [String] sql the sql you wanna query, the multiple sql should be split by ;
    def multiple_query sql
      splited_sql = sql.split(';')
      splited_sql.each do |each_sql|
        query(each_sql)
      end
    end

    # Return the data and execute duration by sql.
    # @param [String] sql the sql you wanna query
    # @param [Boolean] type the default value is true that the expected result is not empty, otherwise, the expected result is empty
    # @param [Number] waiting_time the default value is 10 that maxium execute duration is 10 second
    def query_duration sql, type = true, waiting_time = 10
      start = Time.now
      if type
        result = query_wait(sql, waiting_time)
      else
        result = query_empty(sql, waiting_time)
      end
      finish = Time.now
      msecs = (finish - start) * 1000.0
      hash = {'result' => result, 'duration' => msecs}
      return hash
    end

    # Expect to return data for the query. If the result is empty then it will be called again until waiting_time reach.
    # @param [String] sql the sql you wanna query
    # @param [Number] waiting_time the default value is 10 that maxium execute duration is 10 second
    def query_wait sql, waiting_time = 10
      result = db[sql].all
      if result.empty?
        if waiting_time != 0
          sleep 1
          result = query_wait(sql, waiting_time - 1)
        end
      end
      return result
    end

    # Expect to return empty for the query. If the result is not empty then it will be called again until waiting_time reach.
    # @param [String] sql the sql you wanna query
    # @param [Number] waiting_time the default value is 10 that maxium execute duration is 10 second
    def query_empty sql, waiting_time = 10
      result = db[sql].all
      if result.length != 0
        if waiting_time != 0
          sleep 1
          result = query(sql, waiting_time - 1)
        end
      end
      return result
    end

    # Execute by sql, the sql is normally update or insert.
    # @param [String] sql the sql you wanna execute
    def execute sql
      db[sql]
    end

    # Insert data by data.
    # @param [String] data the data wanna insert which is array or hash
    # @param [String] table the table wanna insert
    def insert_by_data data, table
      sql = "insert into #{table} "
      case data
        when Array
          data.each do |d|
            insert_by_data(d, table)
          end
        when Hash
          columns = data.keys.to_s.gsub('[','(').gsub(']',')').gsub('"','')
          values = data.values.to_s.gsub('[','(').gsub(']',')').gsub('nil','NULL')
          sql = sql + columns + " values " + values
          query(sql)
      end
    end

    # Update data by data.
    # @param [Hash] data the data wanna update which is hash
    # @param [String] table the table for the update
    # @param [Hash] condition the condition for the update
    def update data, table, condition = {}
      sql = "update #{table} set"
      data.each do |k,v|
        v = v.to_json if v.is_a?(Hash)
        if !!v == v
          sql = "#{sql} #{k}=#{v},"
        else
          sql = "#{sql} #{k}='#{v}',"
        end
      end
      sql = sql[0..-2] + " where"
      condition.each do |k,v|
        sql = "#{sql} #{k} = '#{v}' and"
      end
      query(sql[0..-4])
    end
  end
end
