# Peek::Rblineconf

Peek into how much each line of your Rails application takes throughout a request.

Things this peek view provides:

- Total time it takes to render individual lines within your codebase
- Total network time spent waiting per line

## Installation

Add this line to your application's Gemfile:

    gem 'peek-rblineconf'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install peek-rblineconf

## Usage

Add the following to your `config/initializers/peek.rb`:

```ruby
Peek.into Peek::Views::Rblineconf
```

## Contributors

- [@tmm1](https://github.com/tmm1) Wrote rblineprof
- [@dewski](https://github.com/dewski) Wrote peek-rblineprof

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
