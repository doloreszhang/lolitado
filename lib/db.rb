require 'accessors'

class DBFactory
  extend Accessors

  attr_accessor :db

  def initialize db
    @db = db
  end

  def query sql, waiting_time = 10
    result = db[sql].all
    return result
  end

  def multiple_query sql
    splited_sql = sql.split(';')
    splited_sql.each do |each_sql|
      query(each_sql)
    end
  end

  def insert sql
    db[sql]
  end
end
