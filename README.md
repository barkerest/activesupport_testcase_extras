# ActivesupportTestcaseExtras

I found it desirable to add additional test and assertion methods to unit tests.  This is the result.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'activesupport_testcase_extras'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install activesupport_testcase_extras

## Usage

Use the additional methods in your assertions.

```ruby
test "should require name" do
  assert_required @item, :name
end

test "should limit length of name" do
  assert_max_length @item, :name, 100
end

test "name should be unique" do
  assert_uniqueness @item, :name
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/barkerest/activesupport_testcase_extras.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
