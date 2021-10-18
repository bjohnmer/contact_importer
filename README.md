# Koombea Assessment

### Installation

This project requires [Ruby](https://www.ruby-lang.org) v2.7.0+, Redis and ProsgreSQL.

Also is needed to create an .env file with:
```
REDISCLOUD_URL=redis://localhost:6379
RAILS_DEFAULT_URL=localhost:3000
ASW_S3_BUCKET=
AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=
AWS_REGION=
```

```sh
$ yarn install
$ bundle install
$ bundle exec rails db:setup
```

To run the server...

Terminal #1
```sh
$ redis-server
```

Terminal #2
```sh
$ bundle exec sidekiq
```

Terminal #3
```sh
$ bundle exec rails s
```

### Usage
 * Browse to http://localhost:3000
 * Login or Signup(http://localhost:3000/auth/sign_up)
 * To import CSV file go to http://localhost:3000/contacts and click Import Contacts
 * Fill each text field to match the database field and click upload
 * Then you will be redirected to Imported Files index (http://localhost:3000/imported_files/index) and you will see the list of uploaded files with the corresponding status
 * In this list you can click on any of the uploaded files and see its stats
 * CSV example file can be found in spec/fixtures/contacts.csv

### Demo
https://bj-contact-importer.herokuapp.com

### TODO
 * Dinamically change the imported file status when it is processed

## Developer
Eng. Johnmer Bencomo
Oct, 2021


