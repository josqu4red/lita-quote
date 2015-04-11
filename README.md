# lita-quote

[![Build Status](https://travis-ci.org/josqu4red/lita-quote.png?branch=master)](https://travis-ci.org/josqu4red/lita-quote)
[![Coverage Status](https://coveralls.io/repos/josqu4red/lita-quote/badge.png)](https://coveralls.io/r/josqu4red/lita-quote)

[**lita-quote**](https://github.com/josqu4red/lita-quote) is a handler for [Lita](https://github.com/jimmycuadra/lita) to store and retrieve user quotes. The **fork** of lita-quote found here supports retrieving quotes by content, but is not ready for normal use. 

## Compatibility with existing lita-quote installs
This is not a drop in replacement for mainline lita-quote. The redis data structure has changed, and at the moment there is no utility to update existing data to the new structure. 

## Configuration

* `date_format` (String) - `strftime`-style date format to be appended to the quote. Optional, defaults to nil (no date appended).

### Example

```ruby
Lita.configure do |config|
  config.handlers.quote.date_format = "[%Y-%m-%d]"
end
```

## Usage

### Chat functions

Store a quote:
```
Lita: qadd content of the quote # or addquote
Added quote #42
```

Get a random quote:
```
Lita: qget # or getquote
#36: a random quote [2014-03-21]
```

Get a random quote containing given words:
```
Lita: qget content quote # or getquote
#42: content of the quote [2014-03-22]
```

Get a given quote:
```
Lita: qget 42 # or getquote
#42: content of the quote [2014-03-22]
```

Delete a quote:
```
Lita: qdel 42 # or delquote
Deleted quote #42
```

## License

[MIT](http://opensource.org/licenses/MIT)
