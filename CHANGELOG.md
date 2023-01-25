# Changelog

# v0.2.2

- Bump HTTPoison to v2.0.0
- Fixes for nightly version.

## Breaking Changes

- Count query builder now returns `total` instead of `count`.
- Query builder operators changed. Check README

# v0.2.1

- Add query builder for delete operation.
- Fix dialyzer errors.

# v0.2.0

- Fix message queue bug for multiple database client.
- Accept raw data for `signin` and `signup` functions.
- Add simple query builder for:
  - Select
  - Update
  - Create
  - Count
- Add timeout option.
- Fix known bugs.

# v0.1.0

Initial release.
