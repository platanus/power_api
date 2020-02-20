# Power API

It is a Rails engine that gathers a set of other gems and configurations designed to build incredible APIs

## Installation

Add to your Gemfile:

```ruby
gem "power_api"

group :development, :test do
  gem 'factory_bot_rails'
  gem 'rspec-rails'
  gem 'rswag-specs'
  gem 'rubocop'
  gem 'rubocop-rspec'
end
```

```bash
bundle install
```

Then, run the installer:

```bash
rails generate power_api:install
```

## Usage

TODO

## Testing

To run the specs you need to execute, **in the root path of the gem**, the following command:

```bash
bundle exec guard
```

You need to put **all your tests** in the `/power_api/spec/dummy/spec/` directory.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Credits

Thank you [contributors](https://github.com/platanus/power_api/graphs/contributors)!

<img src="http://platan.us/gravatar_with_text.png" alt="Platanus" width="250"/>

Power API is maintained by [platanus](http://platan.us).

## License

Power API is © 2019 platanus, spa. It is free software and may be redistributed under the terms specified in the LICENSE file.
