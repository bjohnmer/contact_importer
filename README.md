# Koombea Assessment

### Installation

This project requires [Ruby](https://www.ruby-lang.org) v2.7.0+ to run.

Install the dependencies and devDependencies and start the server.

```sh
$ bundle install
$ bundle exec rails db:create
$ bundle exec rails db:migrate
```

To run the server...

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


### TODO
  * Import process in background job to properly manage the upload statusses
  * Upload the File to S3
  * Test Coverage
  * Front-end design


## Developer
Eng. Johnmer Bencomo
Oct, 2021