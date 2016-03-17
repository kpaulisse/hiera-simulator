Hiera Simulator Configuration
=============================

#### Facts in PuppetDB

The best way to configure this is to create a file named `.hiera-simulator.yaml` in your home directory. (If you want to specify system-wide settings, you can create `/etc/hiera-simulator.yaml` instead.)

```
puppetdb_url: http://your.puppetdb.host.name:8080
puppetdb_api_version: 3
hiera_yaml_path: /path_to_puppet_checkout/hiera.yaml
yaml_datadir: /path_to_puppet_checkout/hieradata
```

Be sure to adjust the parameters according to your installation.

- **puppetdb_url** is the "base" URL to your installation of PuppetDB.

- **puppetdb_api_version** is the API version your PuppetDB uses. Currently only v3 is supported.

- **hiera_yaml_path** is the path to `hiera.yaml` configuration file that your Puppet Master uses. (If this file is not present on your machine and is not part of your Puppet code checkout, you'll have to copy this from your Puppet master -- probably found in `/etc/puppetlabs/hiera.yaml` or `/etc/puppet/hiera.yaml`.)

- **yaml_datadir** is the directory that contains your hiera data files in YAML format.

If you are using the JSON backend instead of the YAML backend, use the parameter **json_datadir** instead of **yaml_datadir** and it should all work.

#### Facts in Directory on Puppet Master

If you aren't using PuppetDB, you can still use the Hiera simulator on your Puppet Master, with the facts it stores when the agents report in.

The best way to configure this is to create a file named `.hiera-simulator.yaml` in your home directory. (If you want to specify system-wide settings, you can create `/etc/hiera-simulator.yaml` instead.)

```
fact_dir: /var/lib/puppet/yaml/facts
hiera_yaml_path: /path_to_puppet_checkout/hiera.yaml
yaml_datadir: /path_to_puppet_checkout/hieradata
```

Be sure to adjust the parameters according to your installation.

- **fact_dir** is directory into which `<fqdn>.yaml` fact files are saved on your Puppet Master.

- **hiera_yaml_path**, **yaml_datadir**, and **json_datadir** are as in the previous section.

#### Fact file specified on the command line

If you'd like to provide facts via a file specified on the command line (in the same format as Puppet's YAML facts, or as a JSON hash), you only need to specify these settings:

```
hiera_yaml_path: /path_to_puppet_checkout/hiera.yaml
yaml_datadir: /path_to_puppet_checkout/hieradata
```

Note that a `--fact-file` on the command line will *always* override your PuppetDB or directory facts, so you can specify some or all of the other parameters mentioned above, and `--fact-file` will still work.
