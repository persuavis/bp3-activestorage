## [Unreleased]

### Fixed

- Reopen the Active Storage classes in `to_prepare`, so a development reload keeps what this gem adds

## [0.2.0] - 2026-10-30

### Security

- Refuse `ActiveStorage::Blob#key` to explore, as it locates the file in storage
- Require bp3-core 0.4.0, for `unexplorable_columns`

## [0.1.5] - 2026-01-12

- Update gems

## [0.1.4] - 2024-11-18

- Use ruby 3.3.5 and relax gem constraints

## [0.1.3] - 2024-11-08

- Update activestorage dependency to support Rails 7.2

## [0.1.2] - 2024-11-08

- Make classes Ransackable
- Add .table_name_basis

## [0.1.1] - 2024-05-31

- Tweaks and documentation

## [0.1.0] - 2024-01-08

- Initial release
