require 'rbnacl'
require 'base64'

class Box

  def initialize key
    key_env = ENV[key]
    if key_env.nil?
      puts "There's no environment variable #{key}..."
      return
    end
    key = Base64.decode64(key_env)
    @box = RbNaCl::SimpleBox.from_secret_key(key)
  end

  def file_encrypt file
    plaintext = File.read(file)
    ciphertext = @box.encrypt(plaintext)
    enc_file = file + '.enc'
    File.write(enc_file, Base64.encode64(ciphertext))
  end

  def file_decrypt file
    ciphertext = File.read(file)
    plaintext = @box.decrypt(Base64.decode64(ciphertext))
    plain_file = file[0..-5]
    File.write(plain_file, plaintext)
  end
end
