require 'rbnacl'
require 'base64'

module Lolitado
  class Box
    
    attr_accessor :box

    #
    # initialize box 
    #
    # @param key [String] ENV key value used for initialize box
    #
    def initialize key
      fail "There's no environment variable #{key}..." if ENV[key].nil?
      key = Base64.decode64(ENV[key])
      @box = RbNaCl::SimpleBox.from_secret_key(key)
    end

    #
    # encrypt file
    #
    # @param file [String] the file need to be encrypted
    #
    def file_encrypt file
      plaintext = File.read(file)
      ciphertext = box.encrypt(plaintext)
      enc_file = file + '.enc'
      File.write(enc_file, Base64.encode64(ciphertext))
    end

    #
    # decrypt file
    #
    # @param file [String] the file need to be decrypted
    #
    def file_decrypt file
      ciphertext = File.read(file)
      plaintext = box.decrypt(Base64.decode64(ciphertext))
      plain_file = file[0..-5]
      File.write(plain_file, plaintext)
    end
  end
end
