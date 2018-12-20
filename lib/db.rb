require 'accessors'

class DBFactory
  extend Accessors

  attr_accessor :db

  def initialize db
    @db = db
  end

  def query_duration sql, type = true, waiting_time = 10
    start = Time.now
    if type
      result = query(sql, waiting_time)
    else
      result = query_empty(sql, waiting_time)
    end
    finish = Time.now
    msecs = (finish - start) * 1000.0
    hash = {'result' => result, 'duration' => msecs}
    return hash
  end

  def query sql, waiting_time = 10
    result = db[sql].all
    if result.length == 0
      if waiting_time != 0
        sleep 1
        result = query(sql, waiting_time - 1)
      end
    end
    return result
  end

  def multiple_query sql
    splited_sql = sql.split(';')
    splited_sql.each do |each_sql|
      query_empty(each_sql)
    end
  end

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

  def insert sql
    db[sql]
  end
end
