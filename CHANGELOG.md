
# Change Log
All notable changes to this project will be documented in this file.
 
The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).
 
## [Unreleased] - yyyy-mm-dd
 
### Added
 
### Changed
 
### Fixed
 
## [0.3.0] - 2022-05-15
  
- All plots start at 0
- Added beta: MFI plots
- MFI plots now start from 0 or lowest negative value * 1.1
- Added package requirement: "ggcyto" for biexp scale plotting.

## [0.2.2] - 2022-04-25

- Read all sheets at once
- Automatically merge all sheets
- Now deletes `.../flow_jotter_plots/` and recreates folder each run
- Added info about script progress
- Check for colname duplications
- Check for colnames containing forward slashes (/)
- Check for correct use of Plots line
- Number plots start from zero
