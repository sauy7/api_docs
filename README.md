# API Docs [![Build Status](https://secure.travis-ci.org/twg/api_docs.png)](http://travis-ci.org/twg/api_docs)
A tool to help you generate documentation for your API using integration tests in Rails.

## Installation
Add gem definition to your Gemfile and `bundle install`:

```
gem 'api_docs'
```

To access generated docs mount it to a path in your `routes.rb` like this:

``` ruby
mount ApiDocs::Web => '/api-docs'
```

To clean the docs folder at the start of running tests, add the following code to your `test_helper.rb`:

``` ruby
if ApiDocs.config.reload_docs_folder
  Dir["#{ApiDocs.config.docs_path}/*.yml"].each do |file| 
    FileUtils.rm file
  end
end
```

and set `config.reload_docs_folder = true` in an initializer (see: [Configuration](#configuration))

Documents view is made to work with [Twitter Bootstrap](http://twitter.github.com/bootstrap) css and js libraries.

## Generating Api Docs
Documentation is automatically generated into yaml files from tests you create to test your api controllers. To start, let's create integration test by running `rails g integration_test users`. This will create a file for you to work with. Here's a simple test we can do:

``` ruby
class UsersTest < ActionDispatch::IntegrationTest
  def test_get_user
    user = users(:default)
    api_call(:get, '/users/:id', :id => user.to_param, :format => 'json') do |doc|
      assert_response :success
      assert_equal ({
        'id'    => user.id,
        'name'  => user.name
      }), JSON.parse(response.body)
    end
  end

  def test_get_user_failure
    api_call(:get, '/users/:id', :id => 'invalid', :format => 'json') do |doc|
      doc[:description] = 'When bad user id is passed'
      assert_response :not_found
      assert_equal ({
        'message' => 'User not found'
      }), JSON.parse(response.body)
    end
  end
end
```

Assuming that tests pass their details are doing to be recorded into `docs/api/users.yml` and they will look like this:

``` yml
show:
  ID-f385895c2c5265b8a84d19b9885eebe0:
    method: GET
    path: /users/:id
    params:
      id: 12345
      format: json
    status: 200
    body:
      id: 12345
      name: John Doe
  ID-3691338c8b1f567ec48e0e2ebdba2e0d:
    meta:
      description: When bad user id is passed
    method: GET
    path: /users/:id
    params:
      id: invalid
      format: json
    status: 404
    body:
      message: User not found
```

## Add Documentation on Controller

You just need to add a file on doc folder, with the same name yml file was generated.
So in our case:

`docs/api/users.yml`
`docs/api/users.md`

and after you will see something like this:

![Api Docs Example](https://github.com/guiferrpereira/api_docs/blob/master/doc/markdown_reader_controller.png)

## Usage
Just navigate to the path you mounted *api_docs* to. Perhaps `http://yourapp/api-docs`.

## Configuration<a name="configuration"></a>

You can change the default configuration of this gem by adding the following code to your initializers folder:

``` ruby
ApiDocs.configure do |config|
  # Folder path where api docs are saved to
  config.docs_path = Rails.root.join('doc/api')

  # Remove doc files before running tests. False by default.
  config.reload_docs_folder = false

  # Generates docs on demand only. False by default.
  # When enabled docs will generate only if `ENV['API_DOCS']` is set
  attr_accessor :generate_on_demand

  # Exclude params if they are always dynamic
  config.exclude_key_params = [:token]
end
```

![Api Docs Example](https://github.com/twg/api_docs/raw/master/doc/screenshot.png)

## Development

Clone project and run `bundle install`.

Tests are run with `rake test`.

---

Copyright 2012 Oleg Khabarov, Jack Neto, [The Working Group, Inc](http://twg.ca)

