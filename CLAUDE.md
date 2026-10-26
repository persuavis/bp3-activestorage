# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

bp3-activestorage adapts `activestorage` for BP3 (persuavis/black_phoebe_3), a multi-site multi-tenant
Rails application. It makes ActiveStorage's records and controllers BP3-aware. There is nothing to
configure: adding the gem is enough.

## Commands

The gems run on Ruby 3.4.6 (`.ruby-version`). Prefix commands with `~/.rvm/bin/rvm 3.4.6 do` when the
shell is not already on it; a missing `rspec` means the wrong Ruby, not a missing bundle.

- `bundle exec rake` - specs and RuboCop (the default task)
- `bundle exec rspec spec/path/to/file_spec.rb[:LINE]` - one file or example
- `bundle exec rubocop` / `bundle exec rubocop -a`
- `bin/setup`, `bin/console`, `rake install`

## Architecture

`lib/bp3/activestorage/railtie.rb` reopens five classes in an `after_initialize` block. The Railtie is
only defined when `Rails.env` is.

**Models**: `ActiveStorage::Attachment`, `Blob` and `VariantRecord`
- include `Bp3::Core::Rqid`, `Sqnr` and `Ransackable` (Blob also `Displayable`), call
  `use_sqnr_for_ordering` and `has_paper_trail`
- declare optional `belongs_to :sites_site` (aliased `site`) and `belongs_to :tenant` by hand
- define `table_name_basis`, the table name without its `public.` schema prefix
- **Do not include `Bp3::Core::Tenantable`.** Its callbacks set site and tenant behind the scenes and its
  default scope then hides blobs that a later lookup needs to find
- Blob's `version_filter_mask` is `'[FILTERED][AB]'`

**Controllers**: `ActiveStorage::BaseController` and `ActiveStorage::Representations::ProxyController`
include `Bp3::Core::Actions`, `Settings`, `FeatureFlags` and `Cookies`, so file requests get the same site,
tenant and request tracking as the rest of the application. They do not authenticate;
`authenticate_root!` breaks the proxy controller.

## Testing

The spec only checks the version; the Railtie needs a Rails application with a database to exercise. Try a
change against the application (black_phoebe_3) by putting this repo's `lib` ahead of the bundled gem.

## Code Style

- RuboCop (`.rubocop.yml`): target Ruby 3.2.2, NewCops, rubocop-rake and rubocop-rspec; AbcSize 26,
  MethodLength 15, BlockLength 66, ModuleLength 150; `Lint/ConstantDefinitionInBlock` and `Lint/Void`
  are off for `lib/bp3/**/railtie.rb`, where classes are reopened inside a block
- Every file starts with `# frozen_string_literal: true`
- American English; no trailing whitespace on any added or modified line

## Release

Bump `lib/bp3/activestorage/version.rb` and add a `CHANGELOG.md` entry. `rake release` tags, pushes and
publishes to rubygems.org; leave releasing and committing to the user.
