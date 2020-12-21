# Digital Marketplace Functional Tests
BDD tests for the Digital Marketplace suite of applications.

A Ruby project using:
- [Cucumber](http://cukes.info/)
- [Capybara](https://github.com/jnicklas/capybara)
- [Bundler](http://bundler.io/)

## Bootstrapping the project on Mac

This installation assumes you're using [rbenv](https://github.com/rbenv/rbenv) to 
manage your Ruby versions. If you're on macOS you can use [Homebrew](brew.sh).

```bash
brew install rbenv
echo 'eval "$(rbenv init -)"' >> ~/.bash_profile
```

Once you have `rbenv` in your environment you can install Ruby 2.6, [bundler](http://bundler.io/),
and then you're good to go :smile:.

```bash
rbenv install
gem install bundler
make install
```

You will have to install `phantomjs` separately:

```bash
brew cask install phantomjs
```

## Running tests

If you have an environment set up then tests can be run with `bundle exec cucumber`

Alternatively, you can load the environment config and run tests at the same time with

`make run`

To run only the smoke test suite

`make smoke-tests`

To run only the smoulder test suite

`make smoulder-tests`

To run tests for a specific environment file

Create a `config/<environment>.sh` file and run `DM_ENVIRONMENT=<environment> make smoke-tests`

To run a specific feature run with

`make ARGS='-n ...' run`

To run features with a specific tag run

`make ARGS='--tags ...' run`

To include or exclude tags see [the cucumber documentation](https://docs.cucumber.io/cucumber/api/#running-a-subset-of-scenarios)

If using one of the targets in its `-parallel` mode, a `build-report` follow-up job is required to generate a final
html report out of the intermediate json files generated by `parallel_cucumber`. e.g.

`make run-parallel ; make build-report`

## Tags
Tags are used to include/exclude given tests on certain environments. The following tags are currently supported:

| Tag Name                    | Description                                           |
|-----------------------------|-------------------------------------------------------|
| notify                      | Tests whether an email was sent.                      |
| mailchimp                   | Tests updating a mailing list.                        |
| file-upload                 | Tests uploading files.                                |
| file-download               | Tests downloading files                               |
| requires-credentials        | All tests which require API tokens.                   |
| requires-aws-credentials    | All tests which require AWS credentials.              |
| smoke-tests                 |                                                       |
| smoulder-tests              |                                                       |
| antivirus                   |                                                       |
| opportunities               |                                                       |
| requirements                |                                                       |
| direct-award                |                                                       |
| brief-response              |                                                       |
| with-_type_-user            |                                                       |
| skip                        | Skip this test everywhere (e.g. temporarily disabled) |
| skip-local                  | Will not run on the local environment.                |
| skip-preview                | Will not run on the preview environment.              |
| skip-staging                | Will not run on the staging environment.              |
| skip-production             | Will not run on the production environment.           |


## Run tests against local services


First you need to create a file to set up your local environment variables - this must be in
the `config/` directory. There is an example file `config/local.example.sh`.  Copy this to
`config/local.sh` - this should hopefully work out of the box, but you might have a
different experience depending on your setup.

In order to run the functional tests against local apps you will need a reverse proxy
that serves the application through the same host / port (if you are using 
[dmrunner](https://github.com/alphagov/digitalmarketplace-runner) to run
your local environment, then this will be done for you). There is an Nginx config provided
with a bootstrap script at `nginx/bootstrap.sh`. Once this has been run and all the
applications are running the functional tests can be run with

`make run`

(or you can substitute `local` with the name of whatever `config/*.sh` environment file you're using.

#### Using Notify in functional tests

If your scenario includes sending a Notify email, you can temporarily set a sandbox `DM_NOTIFY_API_KEY` in the app
config for that scenario.

For example, in the `config.py` for the scenario's frontend app:

```
class Development(Config):
    ...

    # DM_NOTIFY_API_KEY = "not_a_real_key-00000000-fake-uuid-0000-000000000000"
    DM_NOTIFY_API_KEY = "my-sandbox-api-key-that-I-set-up-in-the-Notify-dashboard"

```

This should match the setting in your `local.sh` config file.

This will allow the functional tests to assert that an email has arrived in the Notify sandbox.

Remember not to commit the change to `config.py`!

#### AWS credentials in functional tests

Tests with the tag `@requires-aws-credentials` require the environment to be set up with an AWS key that has permission
to `PUT` to the bucket named in `DM_DOCUMENTS_BUCKET_NAME`. These can be specified in the normal ways for AWS
credentials - in `~/.aws/credentials` or directly in environment variables. If this permission requires you to change
roles, remember to also set the corrent `AWS_PROFILE`.

## Linting

`make lint` runs the Rubocop linter on any Ruby files within the features directory before running the tests.

Rubocop is also run by Travis CI as a check on a GitHub Pull Request before merging.

To automagically correct any changes the linter suggests run `bundle exec rubocop features -a`.

Further info about the linter can be found [here](https://docs.rubocop.org/en/stable/).


## Running functional tests locally with dmrunner

Setting up your local environment and database to run the functional tests against can be a pain. Wouldn't it be nice if you could get all the apps up and running, backed by a database in the correct state with just one command?

[dmrunner](https://github.com/alphagov/digitalmarketplace-runner) is an experimental utility to run all the apps and services locally (see the README for setup details).

## Principles to follow when writing functional tests

### Email addresses

When using "dummy" email addresses in functional tests, stick to emails using one of the following domains:

| Email domain            | Useful properties                                                                       |
|-------------------------|-----------------------------------------------------------------------------------------|
| `example.com`           | Buyer-account-invalid                                                                   |
| `example.gov.uk`        | Buyer-account-valid                                                                     |
| `user.marketplace.team` | Admin-account-valid, can run tests against existing users with existing services/briefs in the database, doesn't look immediately "fake" to external services |

These domains have been added to the frontends' `DM_NOTIFY_REDIRECT_DOMAINS_TO_ADDRESS` config setting and should have
any Notify emails destined for them redirected to a "safe" dummy address lest Notify lose karma with their downstream
provider from all the nonexistent-address bounces. If a different domain *is* required, it should probably be added here
and synchronized across all the frontends' settings.

Even if the test being written isn't expected to result in a Notify message (e.g. maybe an address only expected to be
used against Mailchimp or just stored in a declaration) it's still best to stick to this vetted list of email domains -
you never know when someone's going to quietly add a new notification of an event, and it's quite useful to have a
handle on what email addresses we're throwing about in general in case we get any other complaints from other services.

### Debugging slow-running functional tests
Capybara is a web testing framework designed to allow assertions against sites that dynamically load/display content. To do this, some of their selector/finder methods will look for elements/content, and retry over a given period if it's not visible immediately. This can cause test steps to pause for a second or two when we're not using the most appropriate selector (like a selector which looks for content _not_ being present if we don't expect it to be there, as opposed to using a selector that looks for content _being_ present, and then asserting the result is false).

IF you run functional tests with the DM_DEBUG_SLOW_TESTS environment variable set, Capybara's synchronisation method will be monkeypatched to raise a SlowFinderError which will help debug where we might not be using the correct Capybara method for our 'happy' case so that we can easily find and change it to something more suitable.

## Updating Ruby dependencies

Update the dependency in the `Gemfile` and run

```bash
bundle install
```

Commit the changes to `Gemfile` and `Gemfile.lock`.

To update the `Gemfile.lock` only (for example, to fix vulnerability warnings), run:

```bash
bundle update
```

Commit the changes to `Gemfile.lock`.

## Licence

Unless stated otherwise, the codebase is released under [the MIT License][mit].
This covers both the codebase and any sample code in the documentation.

The documentation is [&copy; Crown copyright][copyright] and available under the terms
of the [Open Government 3.0][ogl] licence.

[mit]: LICENCE
[copyright]: http://www.nationalarchives.gov.uk/information-management/re-using-public-sector-information/uk-government-licensing-framework/crown-copyright/
[ogl]: http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3/
