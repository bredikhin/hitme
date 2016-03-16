# Hitme

An example of a command line application in Elixir: fetches a random reminder / quote / inspirational phrase from a number of previously saved or default phrases.

## Installation

Checkout the repository, `cd` into it and run `mix escript.build` to build the script. Run it with `./hitme`.

## Usage

* `./hitme` picks a random quote from the phrase vault (the quotes get stored in `~/.hitme`);
* `./hitme add "<A phrase>"` adds the given quote to the phrase vault;
* `./hitme seed` copies the default set of phrases to the vault (courtesy of Oscar Wilde);
* `./hitme empty` empties the vault;
* `./hitme help` shows the list of available commands / switches.

## License

[The MIT License](http://opensource.org/licenses/MIT)

Copyright (c) 2016 [Ruslan Bredikhin](http://ruslanbredikhin.com/)
