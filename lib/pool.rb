require 'mysql2'
require 'sequel'
require 'net/ssh/gateway'

class Pool

  attr_accessor :db_pool, :ssh_pool, :file_path

  def initialize file_path
    @db_pool = {}
    @ssh_pool = {}
    @file_path = file_path
  end

  def use(params ={})
    ssh_name = params.fetch(:ssh, false)
    db_name = params.fetch(:db, false)
    if db_pool[db_name].nil? && db_name
      ssh_key = fetch_ssh_config db_name
      unless ssh_key.nil?
        ssh = create_or_use_ssh ssh_key
        port = forward_port ssh, ssh_key
        db = connect_database db_name, port
        db_pool[db_name] = db
      else
        db = connect_database_directly db_name
        db_pool[db_name] = db
      end
    elsif ssh_name
      create_or_use_ssh ssh_name
    else
      db_pool[db_name]
    end
  end

  def create_or_use_ssh name
    if ssh_pool[name].nil?
      ssh = connect_remote_server name
      ssh_pool[name] = ssh
    else
      ssh_pool[name]
    end
  end

  def connect_database name, port=false
    database_file = YAML.load_file(file_path)
    db_conf = database_file[name]
    db_conf = db_conf.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}
    db_conf = db_conf.merge(:port => port) if port
    db = get_ready_for_database db_conf
  end

  def get_ready_for_database conf
    begin
      Sequel.connect(conf)
    rescue
      fail "database configuration \n #{conf} \n is not correct, please double check"
    end
  end

  def connect_remote_server name
    database_file = YAML.load_file(file_path)
    ssh_conf = database_file[name]
    ssh_conf = ssh_conf.delete_if { |key,value| key == 'database'}
    ssh = get_ready_for_ssh ssh_conf
    return ssh
  end

  def get_ready_for_ssh conf
    host = conf.delete('host')
    user = conf.delete('user')
    options = conf.delete_if {|key,value| key == 'host' && 'user'}
    options = options.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}
    begin
      Net::SSH::Gateway.new(host, user, options)
    rescue
      fail "ssh configuration \n #{conf} \n is not correct, please double check"
    end
  end

  def forward_port ssh, name
    database_file = YAML.load_file(file_path)
    ssh_conf = database_file[name]
    new_conf = ssh_conf.delete('database')
    host = new_conf.delete('host')
    remote_port = new_conf.delete('remote_port')
    local_port = new_conf.delete('local_port')
    begin
      ssh.open(host, remote_port, local_port)
    rescue Errno::EADDRINUSE
      return local_port
    rescue
      fail "fail to forward remote port #{remote_port} to local_port #{local_port}"
    end
  end

  def fetch_ssh_config db_name
    database_file = YAML.load_file(file_path)
    db_conf  = database_file[db_name]
    ssh_key = db_conf.delete('ssh')
  end

  def connect_database_directly db_name
    database_file = YAML.load_file(file_path)
    db_conf  = database_file[db_name]
    db_conf = db_conf.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}
    db = Sequel.connect(db_conf)
  end
end
