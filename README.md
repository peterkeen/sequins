# Sequins

Sequences allows you to define temporal sequences of actions.
A sequence is one or more steps that run in any order you choose with any delay between them you choose.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'sequins'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sequins

## Usage

```ruby
class ExampleSequence < Sequins::Base
  sequence do
    step :start, initial: true do
      ExampleMailer.example_message(target.id).deliver_later

      delay 3.days, then: :step_2
    end

    step :step2 do
      ExampleMailer.example_step_2(target.id).deliver_later
      end_sequence
    end
  end
end

# somewhere else in your codebase

ExampleSequence.trigger(current_user)
```

## Configuration

```ruby
# in config/initializers/sequins.rb

Sequins.configure do |config|
  # Specify the default time zone in tz format.
  # If you are using Sequins inside Rails this will be set to Rails.configuration.time_zone.
  # You can also change this per-target by providing a `local_time_zone` method on your target.
  config.default_time_zone = 'America/Chicago'
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/eggheadio/sequins. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

Copyright (c) egghead.io LLC. The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Sequins project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/eggheadio/sequins/blob/master/CODE_OF_CONDUCT.md).
