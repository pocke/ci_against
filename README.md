# CI Against

A CLI tool to Bump Ruby versions in Travis CI automatically.

CI Against opens a pull request to bump Ruby version in Travis CI by one command.

## Installation

### Requirements

* Ruby 2.4 or higher

### How to install

Add this line to your application's Gemfile:

```ruby
gem 'ci_against'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ci_against

## Usage

It needs GitHub's personal access token. First, please get the token from here https://github.com/settings/tokens/new

### Dry Run

CI Against has dry-run feature, so I recommend to confirm the content of the pull request before it opens the pull request.

```bash
$ export GITHUB_ACCESS_TOKEN=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
$ ci_against --dry-run your_github_name/your_repo_name
CI against Ruby 2.5.3 and 2.6.0

## Added

* 2.5.3
* 2.6.0


## Changed

* 2.3.4 => 2.3.8
* 2.4.1 => 2.4.5
diff --git a/tmp/ci-against20181228-2141-qio4i0 b/tmp/ci-against20181228-2141-1hmqgc4
index 14298b9..5dd84a7 100644
--- a/tmp/ci-against20181228-2141-qio4i0
+++ b/tmp/ci-against20181228-2141-1hmqgc4
@@ -1,4 +1,6 @@
 language: ruby
 rvm:
-  - "2.3.4"
-  - "2.4.1"
+  - "2.3.8"
+  - "2.4.5"
+  - "2.5.3"
+  - "2.6.0"
```

If you'd like to update multiple repositories, you can specify them.

```bash
$ export GITHUB_ACCESS_TOKEN=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
$ ci_against --dry-run your_github_name/your_repo_name your_github_name/your_cool_repo_name your_github_name/your_awesome_repo_name
```

### Apply

To apply it, just remove `--dry-run` option.

```bash
$ export GITHUB_ACCESS_TOKEN=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
$ ci_against your_github_name/your_repo_name
PR created: https://github.com/your_github_name/your_repo_name/pull/42
```


## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/pocke/ci_against.
