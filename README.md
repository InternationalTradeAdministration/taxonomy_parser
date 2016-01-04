# Taxonomy Parser

This gem can be used any time we need the ITA Taxonomy, currently housed as XML in Webprotege, to be available on a Ruby back end.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'taxonomy_parser'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install taxonomy_parser

## Usage

Initialize a new parser and call the parse method to download and parse the terms:

```
my_parser = TaxonomyParser.new
my_parser.parse
```

You can then view the concepts and concept groups by calling their respective methods:

```
my_parser.concepts
my_parser.concept_groups
```

Each of these methods will return an array of hashes that contain the following fields:

* label
* leaf_node
* path
* subject
* concept_groups
* broader_terms

There are a few built in lookup methods:

```my_parser.get_all_geo_terms_for_country('AF')```
Returns an array of terms that are a member of World Regions and Trade Regions relating to the given country.  Right now this only accepts a valid ISO-2 code.

```my_parser.get_concepts_by_concept_group("Countries")```
Returns an array of terms that are a member of the given concept group.

```my_parser.get_concept_by_label('Aviation')```
Returns a single hash term given it's name.


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/GovWizely/taxonomy_parser.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

