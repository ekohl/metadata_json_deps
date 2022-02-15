# metadata-json-deps

The metadata-json-deps tool validates dependencies in `metadata.json` files in Puppet modules against the latest published versions on the [Puppet Forge](https://forge.puppet.com/).

## Compatibility

metadata-json-deps is compatible with Ruby versions 2.4.0 and newer.

## Installation

via `gem` command:
``` shell
gem install metadata_json_deps
```

via Gemfile:
``` ruby
gem 'metadata_json_deps'
```

## Usage

### Testing with metadata-json-deps

On the command line, run `metadata-json-deps` with the path(s) of your `metadata.json` file(s):

```shell
metadata-json-deps /path/to/metadata.json
```

Example output:

```console
$ metadata-json-deps modules/*/*/metadata.json
Checking modules/theforeman/puppet-candlepin/metadata.json
  puppetlabs/stdlib (>= 4.2.0 < 8.0.0) doesn't match 8.1.0
  puppet/extlib (>= 3.0.0 < 6.0.0) doesn't match 6.0.0
Checking modules/theforeman/puppet-certs/metadata.json
  puppetlabs-stdlib (>= 4.25.0 < 8.0.0) doesn't match 8.1.0
  puppet-extlib (>= 3.0.0 < 6.0.0) doesn't match 6.0.0
Checking modules/theforeman/puppet-dhcp/metadata.json
Checking modules/theforeman/puppet-dns/metadata.json
```

It can also be run verbosely to show valid dependencies:

```shell
metadata-json-deps -v modules/*/metadata.json
```

### Testing with metadata-json-deps as a Rake task

You can also integrate `metadata-json-deps` checks into your tests using a Rake task:

```ruby
require 'metadata_json_deps'

desc 'Run metadata-json-deps'
task :metadata_deps do
  files = FileList['modules/*/metadata.json']
  MetadataJsonDeps::run(files)
end
```

### Bumping dependency upper bounds

After detecting outdated dependencies, it's important to do something about this. Taking the earlier example, you can see some modules should allow newer dependencies (candlepin and certs) while others are up to date (dhcp and dns).

The next step is to look into the newer dependencies. In this case stdlib and extlib had a major version bump. It is then important to look at the changes and see if it does affect modules. Sometimes it doesn't, like when a module drops support for Puppet 5 but our modules already dropped Puppet 5. In that case, it's safe to raise the upper version bound.

To update the upper bounds, [bump-dependency-upper-bound](https://github.com/voxpupuli/modulesync_config/blob/master/bin/bump-dependency-upper-bound) can be used. For example, to allow puppetlabs/stdlib 8.x, the new upper bound is 9.0.0:

```console
$ bump-dependency-upper-bound puppetlabs/stdlib 9.0.0 modules/*/*/metadata.json
Updated modules/theforeman/puppet-candlepin/metadata.json: '>= 4.2.0 < 8.0.0' to '>= 4.2.0 < 9.0.0'
Updated modules/theforeman/puppet-certs/metadata.json: '>= 4.25.0 < 8.0.0' to '>= 4.25.0 < 9.0.0'
modules/theforeman/puppet-dhcp/metadata.json already matches 9.0.0
modules/theforeman/puppet-dns/metadata.json already matches 9.0.0
```
