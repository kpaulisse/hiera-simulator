Hiera Simulator Troubleshooting
===============================

## No local or global hiera-simulator config files contain config data.

```
No local or global hiera-simulator config files contain config data.
Perhaps you have not yet configured hiera-simulator on this system?
Please see https://github.com/kpaulisse/hiera-simulator/blob/master/doc/troubleshooting.rb for more
```

Make sure you created the `.hiera-simulator.yaml` file in your home directory, and named it correctly.

Please see: [Configuration](./configuration.md)

## ERROR!!! A required parameter (`parameter_name`) was missing.

The name of the missing parameter is given in the error message.

The missing parameter was supposed to have been defined either in one of the [configuration files](./configuration.md), or otherwise via a command line argument. The parameters required for a query depend on your configuration (e.g., if you're using YAML or JSON data files).

Here are some common parameters you might need to define:

| Parameter | Command Line Flag | Description |
| --------- | ----------------- | ----------- |
| `hiera_yaml_path` | `--hiera-yaml-path` | (**Always Required**) Path to the `hiera.yaml` configuration file |
| `yaml_datadir` | `--yaml-datadir` | (Required if your `hiera.yaml` defines a YAML datadir) Path to the Hiera data directory which contains YAML files |
| `json_datadir` | `--json-datadir` | (Required if your `hiera.yaml` defines a JSON datadir) Path to the Hiera data directory which contains JSON files |

## Returns 'nil'

This means that the key you requested wasn't found in *any* of the Hiera datafiles.
