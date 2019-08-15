# lolitado
Library for using database and API

----
## How to call database?


You need to do these things：

* put all sql in sql.yml or in code
* put database connect info in xx_db.yml
----
run case like

````ruby
pool = Lolitado:Pool.new('xx_db.yml')
db = pool.use(:db =>'db_name')
sql = "select * from identity.user where phone = '+86 139 0000 0000"
result = db.query(sql)
````
----
## How to call API?

----
run case like

````ruby
 * Rest API
  class TestRest
    include Lolitado

    def initialize
      base_uri 'https://xxx.com'
    end

    def get_details_of_a_city city_slug, locale
      add_headers({'Accept-Language' => locale})
      request('get', "/cities/#{city_slug}")
    end
  end

* Graph API
  class TestGraph
    include Lolitado

    def initialize
      base_uri 'https://xxx.com'
    end

    def user_login payload
      add_headers({'Content-Type' => "application/json"})
      query = "mutation login($input: UserLoginInput!) {userLogin(input:$input) {authToken}}"
      graph_request(query, payload)
    end
  end
````
----
## How to encrypt/decrypt credential file?

* Initialize Box with secret key of environment variable
* file_encrypt to encrypt the file
* file_decrypt to decrypt the file

----
````ruby
box = Lolitado:Box.new('ENV_KEY')
box.file_encrypt('file_name')
box.file_decrypt('encrypt_file_name')
````
