# Taxonomy Parser

This gem can be used any time there is a need for the ITA Taxonomy, currently housed as XML in Webprotege, to be available on a Ruby back end.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'taxonomy_parser', github: 'GovWizely/taxonomy_parser'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install taxonomy_parser

## Usage

Initialize a new parser and call the parse method to download and parse the terms.  A valid path or URL must be provided (to the ZIP file containing the .owl XML):

```ruby
my_parser = TaxonomyParser.new('path/or/url/to/zip')
my_parser.parse
```

You can then view the concepts and concept groups by calling their respective methods:

```ruby
my_parser.concepts
my_parser.concept_groups
```

Each of these methods will return an array of hashes that contain the following symbolized keys:

* label
* leaf_node
* subject
* subClassOf
* annotations
* datatype_properties
* object_properties

There are other possible fields as well, depending on the source data.  An example concept showing the structure:
```ruby
 {:label=>"Market Research Services",
  :subClassOf=>
   [{:id=>"http://webprotege.stanford.edu/RZAYCEhJ1RvOk65kuqHWF7",
     :label=>"Marketing Services"}],
  :source=>"ITA",
  :prefLabel=>"Market Research Services",
  :datatype_properties=>{},
  :object_properties=>
   {:has_broader=>
     [{:id=>"http://webprotege.stanford.edu/RZAYCEhJ1RvOk65kuqHWF7",
       :label=>"Marketing Services"}],
    :member_of=>
     [{:id=>"http://webprotege.stanford.edu/RCSUVZOLMw17ZnTq4SY2JcX",
       :label=>"Product Class"}]},
  :leaf_node=>true,
  :subject=>"http://webprotege.stanford.edu/RDV1ccixsBYCOyBPN4RYvkw"}
```

There are a few built in lookup methods:

```ruby
my_parser.get_all_geo_terms_for_country('AF')
my_parser.get_all_geo_terms_for_country('United States')
```
Returns an array of terms that are a member of World Regions and Trade Regions relating to the given country.  This method accepts a country name or ISO-2 code.

```ruby
my_parser.get_concepts_by_concept_group("Countries")
```
Returns an array of terms that are a member of the given concept group.

```ruby
my_parser.get_concept_by_label('Aviation')
```
Returns a single hash term given it's name.

```ruby
my_parser.raw_source
```
Returns a string containing the raw XML source from Webprotege.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/GovWizely/taxonomy_parser.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

