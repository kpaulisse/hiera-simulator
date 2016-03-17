Hiera Simulator Installation
============================

Here's one way to install, using the 'specific_install' gem:

```
gem install specific_install
gem specific_install https://github.com/kpaulisse/hiera-simulator.git
```

If you have a Puppet installation with a Gemfile, you can add this to it:

```
gem 'hiera-simulator', :git => 'https://github.com/kpaulisse/hiera-simulator'
```
