# Striker
Bad-ass, greasy-fast, cached calculated collections

## The five-minute setup.
Check your system for local requirements (run until it passes!):

    script/bootstrap

Run tests to ensure that all pass:

    npm test

Run the project locally:

    npm start

Then navigate to the [showcase](http://localhost:5000).

## Contributing
Please (please please please) read the following sections on our wiki:

* [Welcome to Activecell](https://github.com/activecell/activecell/wiki)
* [Activecell "flow"](https://github.com/activecell/activecell/wiki/flow)
* [Our approach to agile](https://github.com/activecell/activecell/wiki/agile)
* [Our toolset](https://github.com/activecell/activecell/wiki/tools)
* [Quality](https://github.com/activecell/activecell/wiki/Quality)
* [Style Guide](https://launchpad.activecell.com/admin/styleguide)

There's so much good information in there! You'll learn so much! :-)

### Hacking on the source
* Source for the library is in src/coffee/
* Tests for the library are in test/
* Showcase files are in examples/coffee/ and examples/public/*

All source code should be documented with [TomDoc](http://tomdoc.org/).

For the showcase, you can either update the existing examples, or create a new example. To create a new example, just create a file in examples/public/js/ that demonstrates the functionality, and add the reference in examples/coffee/index.coffee.

#### Seriously. For all new source functionality, make sure you have:
1. A pull request that can be merged into master (shows green merge button)
1. Test coverage
1. TomDoc that shows nicely in docco
1. Everything passing using `npm test` (including lint!)
1. Updated showcase for your functionality

### Hacking on design
* Source for our stylesheet is in src/scss/
* Templates for the styleguide sections are in [jade](http://jade-lang.com/) format in examples/views/sections/

All design should be documented with [kss](https://github.com/kneath/kss) and showcased in our style guide. Simply ensure that you have a valid section commented in the source and a corresponding template available.
