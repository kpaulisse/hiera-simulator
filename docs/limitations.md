Hiera Simulator Limitations
===========================

I am aware of these limitations, which exist because I do not have an appropriate setup for testing, and/or there was not a need to address them in my use case. I welcome contributions compatible with the Apache 2.0 license to improve any or all of the following:

- Limited backend support for Hiera. Only these Hiera backends are supported:
  - JSON
  - YAML

  If you're using something else (CouchDB, MySQL, Postgres, DynamoDB, PuppetDB, or anything else you might think of to use as a Hiera backend) this Hiera simulator currently does not support you.

- Hiera version. By default it will pull the latest version of Hiera. If you need hiera version 1, you may wish to run this with:

  ```
  BUNDLE_GEMFILE=Gemfile.hiera1 bundle exec bin/hiera-simulator ...
  ```

  Currently it should work correctly with Hiera 1.3.4 and the latest version of Hiera (3.1.1 as of the time of this writing). Please file an issue if it does not.
