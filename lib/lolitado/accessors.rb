#
# Contains the class level methods that are inserted into your api class
#
module Accessors

  # just for example "how to create method in accesors"
  def row name, identifier
    define_method("delete_#{name}") do |value|
      db[identifier[:table].to_sym].filter(value).delete
    end
  end

  def column name, identifier
    define_method("avg_#{name}") do |value|
      db[identifier[:table].to_sym].filter(value).avg(identifier.values.last.to_sym)
    end
    define_method("query_#{name}") do |value|
      db[identifier[:table].to_sym].filter(value).all
    end
  end

end
