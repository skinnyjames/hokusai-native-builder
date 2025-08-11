# hokusai-native-builder

Builder for the [Hokusai Native](https://github.com/skinnyjames/hokusai-native) project.

Currently very BETA, and proof of concept.

The program downloads dependencies ands produces `package.tar.gz` in the build folder.

The dependencies are:

* GraalVM
* Gradle
* TruffleRuby
* Hokusai Native
* Raylib

The resulting package contains:

* TruffleRuby and GraalVM libs
* libhokusai-native
* A raylib backend (hokusai-backend)
* a test ruby app to run

This program depends on crystal for building.

## Installation

1. Download repo
2. `shards build`

## Usage

1. `bin/hokusai-native-builder setup`
2. `bin/hokusai-native-builder gem -- "install hokusai-zero"`
3. `bin/hokusai-native-builder native-image`

### To run an app

The environment variable `HOKUSAI_RUBY_HOME` needs to be set to the truffle ruby installation included in the build

`HOKUSAI_RUBY_HOME=./truffle ./hokusai-backend <some-app.rb>`

## Gotchas

### What about windows?

While a standard Hokusai installation is cross-platform, Hokuasi Native can only support platforms that GraalVM and TruffleRuby support.

https://github.com/oracle/truffleruby?tab=readme-ov-file#system-compatibility

### What about android?

Android has provisions that make it unfeasible to use the native image in an application, and Oracle (GraalVM) removed the provisions that made this sort of thing possible.  In particular Android stopped allowing text relocations in native libraries, and Oracle stopped supporting not adding these relocations.  

https://github.com/oracle/graal/issues/9037

### Missing Hokusai callbacks?

Hokusai defines callbacks for performing commands and expects those callbacks to be provided by a backend at runtime.
The Hokusai Native project currently supports a subset of these render callbacks, and more work is needed to support them all.

So commands like text/rect/circle/etc work, but shader and transform commands will not work.

## Contributing

1. Fork it (<https://github.com/skinnyjames/hokusai-native-builder/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Zero Stars](https://github.com/skinnyjames) - creator and maintainer
