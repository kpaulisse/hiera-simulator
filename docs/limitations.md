Hiera Simulator Limitations
===========================

I am aware of these limitations, which exist because I do not have an appropriate setup for testing, and/or there was not a need to address them in my use case. I welcome contributions compatible with the Apache 2.0 license to improve any or all of the following:

- Limited backend support for Hiera. Only these Hiera backends are supported:
  - JSON
  - YAML

  If you're using something else (CouchDB, MySQL, Postgres, DynamoDB, or anything else you might think of to use as a Hiera backend) this Hiera simulator currently does not support you.

- Hiera version. The Hiera simulator currently only supports the older version of Hiera (1.3.4).

  It has not been tested with newer versions of Hiera -- it may or may not work. You would have to modify the gemspec manually.
