# Changelog project: Active Directory Group Tool 
---

## Features Heading
- `Added` for new features.
- `Changed` for changes in existing functionality.
- `Fixed` for any bug fixes.
- `Removed` for now removed features.
- `Security` in case of vulnerabilities.
- `Deprecated` for soon-to-be removed features.

---

### Version 2.0.0 (2019-11-06)
#### Added
- DISM instllation for RSAT if needed.
- Error handling for advanced search requirements
- Running as administrator checking

#### Changed
- Improved dependency checking
- Input prompt
- Write to log happens first, than console output.
- formatting
- DC check now happens with PING

#### Fixed
- Advanced search not working with custom parameters


---

### Version 1.8.0 (2019-10-29)
#### Added
- Ability to search multiple groups with well formated log output
- Inline help
- Error catching for no groups found.

#### Changed
- Color on some menu's
- Preferences to Settings
- RSAT URL

#### Fixed
- Trailing line in log file


### Version 1.7.1 (2019-10-23)
#### Added
- user upn to output

#### Removed
- Build from title



### Version 1.7.0 (2019-10-01)

#### Added
- user display name return with a query
- Build number for development/troubleshooting
- suppress error output
#### Changed
- default window size
- default color is now bright white text