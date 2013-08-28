# ArelSearch

Work in progress, use at your own risk but feel free to contribute :)

## Installation

Add this line to your application's Gemfile:

    gem 'arel_search'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install arel_search

## Usage

### Basic

    params = {'orders.status.eq' => 50}
    ArelSearch::Base.new(Order, params).search

### Query by association

    params = {'orders.status.eq' => 50, 'customer.name.matches' => 'Marcus'}
    ArelSearch::Base.new(Order, params).search

### Paginate (3rd party)

    params = {'orders.status.eq' => 50, 'customer.name.matches' => 'Marcus'}
    ArelSearch::Base.new(Order, params).search(page: 1, per_page: 10)

## TODO

* Work with namespace
* Allow 'OR' conditions

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
