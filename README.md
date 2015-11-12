# DuoApi
[![Build Status](https://travis-ci.org/highrisehq/duo-api.svg)](https://travis-ci.org/highrisehq/duo-api)

A thin, zero depedency library for connecting to the Duo Auth API.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'duo-api'
```

And then execute:

```
$ bundle
```

Or install it yourself as:

```
$ gem install duo-api
```

## Configuration

During app initialization:
```ruby
require 'duo-api'
DuoApi.config do |config|
  # Found on Duo Admin panel for the application you've set up
  config.hostname = "api-xxxxx.duosecurity.com"
  config.integration_key = "asdf"
  config.secret_key = "asdf"

  # ONLY for Duo Web
  # Generate a somewhat long secret token (40+ characters).
  # If you're using Rails, `Rails.application.secret_token` should suffice
  # can also run `duo-api app_secret`
  config.app_secret = "Long app secret"
end
```

For Rails this would go in something like `config/initializers/duo.rb`.
Keep in mind, you likely don't want to store these keys in your repository.

### Configuration Caveat

Upon completion of the general features we noticed that Duo needs separate
credentials for different APIs. This config is currently Global. We (or someone)
should be adding a way to switch between credentials or perhaps it would be best
to initialize a Client class for each credential set

## Usage

```ruby
response = DuoApi.get("/auth/v2/check")
response.success? # => true
response.body["response"]["time"] # => 1357020061

response = DuoApi.post("/auth/v2/preauth", :params => { :username => "jphenow" })
response.success? # => true
response.code # => "200"
response.body["response"]["result"] # => "auth"
response.message # => "Account is active"

response = DuoApi.post("/auth/v2/preauth")
response.success? # => false
response.code # => "400"
response.message # => "Missing required request parameters"
```

See the Duo [API documentation](https://www.duosecurity.com/docs/authapi) for a full list of
available endpoints.


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/duo-api. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

