# lolitado
Library for using database and API

----
## How to call database?
We use these files to support database fuction:

* assceeors.rb
* db.rb
* pool.rb

Besides, you need to do these things：

* put all sql in sql.yml
* put database connect info in xx_db.yml
----
run case like

````ruby
POOL = Pool.new('lolitado/data/stage_db.yml')
DBFACTORY = DBFactory.new(POOL.use(:db =>'db_name'))
sql = "select * from identity.user where phone = '+86 139 0000 0000"
result = DBFACTORY.query(sql)
````
----
## How to call API?

* We use *request.rb* to process with http requests
* We use *yaml.rb*  to load api config yml
* You need to add api.yml to put API config in it

----
run case like

````ruby
API = Request.new()
def user_login payload
API.add_headers({'Content-Type' => "application/json"})
API.request('https://aaa.aa.com', 'post', '/users/login', payload.to_json)
end
payload = {}
payload['login_type'] = 'login_type'
payload['social_id'] = 'social_id'
response = user_login(payload)
````
----
## How to encrypt/decrypt credential file?

* Initialize Box with secret key of environment variable
* file_encrypt to encrypt the file
* file_decrypt to decrypt the file

----
````ruby
box = Box.new('CLERIC_ENCRYPT_KEY')
box.file_encrypt('config/stage.yml')
box.file_decrypt('config/stage.yml.enc')
````
