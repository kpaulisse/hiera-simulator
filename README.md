# Hiera Simulator

Pull facts about a node, and then preview Hiera changes there, without touching the node.

# Why?

[Hiera](https://github.com/puppetlabs/hiera) is a critical part of a Puppet implementation, and it is amazingly helpful to separate data from code.

The Hiera Simulator simplifies the development process by allowing someone to "preview" Hiera changes without committing to source control, awaiting results from CI tests, or touching any real hosts in the environment. While it's possible to do all this with stock Hiera, that involves copying facts and using less common command line options. Hiera Simulator handles all that for you, and then calls the *actual Hiera code* to do your lookup.

I have read that Puppet's new `lookup` function will have the same sort of functionality, so it's quite possible that the Hiera Simulator's usefulness will be subsumed by tools that ship with Puppet. If this does come to pass, :+1:!

# Setup

This code is meant to run on a developer's workstation -- perhaps in some cases it's also suitable for your Puppet Master, but it's definitely not intended to be installed everywhere in your environment. Once you've installed the code, you'll have to do a bit of configuration so it knows where to find everything.

- [Installation](./docs/installation.md)
- [Configuration](./docs/configuration.md)

# Usage

Type `hiera-simulator --help` for a list of command line options.

Here are the important ones:

- `-n FQDN`: The FQDN of the host whose facts you want to use. This option is **required** unless you use `--fact-file FILENAME` to provide the facts for you.

- `-d`: Turn on Hiera debug mode, which will show you what files were tried until it ultimately came up with your fact.

- `--fact-file FILENAME`: Instead of providing a node name and letting Hiera Simulator find the facts for you, load the facts directly from the file you specify. The fact file may be in YAML or JSON format (parsing method depends on file extension).

# Troubleshooting

- [Troubleshooting](./docs/troubleshooting.md)

# Limitations

- [Limitations](./docs/limitations.md)
