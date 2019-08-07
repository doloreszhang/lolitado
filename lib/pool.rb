require 'mysql2'
require 'sequel'
require 'net/ssh/gateway'
require 'psych'
require 'db'

class Pool

  def initialize file_path
    @@db_pool = {}
    @@ssh_pool = {}
    @@file = Psych.load_file(file_path)
  end

  def use(params = {})
    ssh_name = params.fetch(:ssh, false)
    db_name = params.fetch(:db, false)
    if db_name
      return get_db db_name
    elsif ssh_name
      return get_ssh ssh_name
    else
      fail "Please provide :ssh or :db"
    end
  end

  def get_db name
    if @@db_pool[name].nil?
      db_conf =  @@file[name]
      if db_conf['proxy'].nil?
        db = connect_database db_conf
      else
        db = connect_database_by_proxy db_conf
      end
      @@db_pool[name] = Database.new(db)
    end
    return @@db_pool[name]
  end

  def get_ssh name
    if @@ssh_pool[name].nil?
      ssh = connect_remote_server name
      @@ssh_pool[name] = ssh
    else
      @@ssh_pool[name]
    end
  end

  def connect_database_by_proxy conf
    port = forward_port conf['proxy']
    connect_database conf, port
  end

  def connect_database conf, port = false
    conf.delete('proxy') if port
    conf = conf.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}
    conf = conf.merge(:port => port) if port
    begin
      Sequel.connect(conf)
    rescue
      fail "database configuration \n #{conf} \n is not correct, please double check"
    end
  end

  def connect_remote_server name
    ssh_conf = @@file[name]
    host = ssh_conf.delete('host')
    user = ssh_conf.delete('user')
    options = ssh_conf.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}
    begin
      Net::SSH::Gateway.new(host, user, options)
    rescue
      fail "ssh configuration \n #{ssh_conf} \n is not correct, please double check"
    end
  end

  def forward_port conf
    ssh = get_ssh conf['ssh']
    host = conf['database']['host']
    remote_port = conf['database']['remote_port']
    local_port = conf['database']['local_port']
    # puts "forward remote port #{remote_port} to local port #{local_port}"
    begin
      ssh.open(host, remote_port, local_port)
    rescue Errno::EADDRINUSE
      return local_port
    rescue
      fail "fail to forward remote port #{remote_port} to local_port #{local_port}"
    end
  end
end
