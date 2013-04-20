# Peek::Rblineprof

Peek into how much each line of your Rails application takes throughout a request.

Things this peek view provides:

- Total time it takes to render individual lines within your codebase
- Total network time spent waiting per line

You can also drill down to only certain parts of your codebase like:

- app, everything within `Rails.root/(app|lib)`
- views, everything within `Rails.root/app/view`
- gems, everything within `Rails.root/vendor/gems`
- all, everything within `Rails.root`
- stdlib

## Installation

Add this line to your application's Gemfile:

    gem 'peek-rblineprof'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install peek-rblineprof

## Usage

Add the following to your `config/initializers/peek.rb`:

```ruby
Peek.into Peek::Views::Rblineprof
```

You'll then need to add the following CSS and CoffeeScript:

CSS:

```scss
//= require peek
//= require peek/views/rblineprof
```

CoffeeScript:

```coffeescript
#= require peek
#= require peek/views/rblineprof
```

## Integration with pygments.rb

By default peek-rblineprof renders the code of each file in plain text with no
syntax highlighting for performance reasons. If you'd like to have your code
highlighted as it does on GitHub.com, just include the [pygments.rb](https://github.com/tmm1/pygments.rb) gem:

```ruby
gem 'pygments.rb', :require => false
```

peek-rblineprof will now highlight each file for you, but there's one more thing...

To use the default theme that peek-rblineprof provides just add the following
to your peek specific or application stylesheet:

```scss
//= require peek/views/rblineprof/pygments
```

That's it! Now your code will look :sparkles:

## Contributors

- [@tmm1](https://github.com/tmm1) wrote rblineprof
- [@dewski](https://github.com/dewski) wrote peek-rblineprof

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
