require 'psych'

module Cleric
  module YAML

    CONFIGURE_PATH = File.expand_path("../data/stage.yml",__FILE__)

    def self.fetch_corresponding_conf_by name
      all_hash_values = load_yml(CONFIGURE_PATH)
      conf_value = fetch_value_by all_hash_values, name
      return conf_value
    end

    def self.load_yml path
      Psych.load_file(path)
    end

    def self.fetch_value_by hash, key
      if hash == false
        fail "no configuration in #{ENV['PLATFORM']}.yml"
      else
        if hash[key].nil?
          fail "can not find corresponding configure value for #{key}"
        else
          hash[key]
        end
      end
    end

  end
end
