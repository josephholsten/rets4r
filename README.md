# RETS4R

RETS4R provides a native Ruby interface to the RETS (Real Estate Transaction Standard). It currently is built for the 1.5 specification, but support for 1.7 and 2.0 are planned. It does not currently implement all of the specification, but the most commonly used portions. Specifically, there is no support for Update transactions.

This is the first "native" Ruby RETS library currently available, but there is another available from estately called [rets][], there is another client [resync][], which uses ruby bindings to the standard C++ [librets][], both from the Center for Realtor® Technology.

## Links

-   Rubygem: [![Version](http://img.shields.io/gem/v/rets4r.svg)](https://rubygems.org/gems/rets4r)
-   Mailing List: <rets4r@librelist.com> [Archive][]
-   Documentation: <http://rdoc.info/github/josephholsten/rets4r>
-   Source: <http://github.com/josephholsten/rets4r>
-   Build Status: [![Build Status](http://img.shields.io/travis/com/josephholsten/rets4r.svg)](https://app.travis-ci.com/github/josephholsten/rets4r)
-   Coverage: [![Coverage](https://img.shields.io/coveralls/josephholsten/rets4r.svg)](https://coveralls.io/r/josephholsten/rets4r)

## Requirements

-   Ruby \>= 1.9.3
-   Nokogiri \>= 1.3.2

## License

Please see the LICENSE file.

## Acknowledgments

This project was made possible in part by the [Contra Costa Association of Realtors®][].

## Getting Started

Take a look at the [examples/][examples/] directory. You'll find it more helpful than the unit tests because the unit tests work off of local files and mock objects, rather than making real transaction calls.

Due to the nature of this library, it is HIGHLY recommended that you have at least a basic understanding of the RETS protocol, available at the [official RETS website][].

Most of the time, you will be either searching for resources or getting objects, so begin there.

  [rets]: https://github.com/estately/rets
  [resync]: https://code.google.com/p/crt-resync/
  [librets]: https://github.com/NationalAssociationOfRealtors/libRETS
  [Archive]: http://librelist.com/browser/rets4r/
  [Contra Costa Association of Realtors®]: http://www.ccartoday.com
  [official RETS website]: http://www.rets.org
