## R CMD check results

0 errors | 0 warnings | 1 note

* This is a new submission.

* The incoming check reports possibly misspelled words in DESCRIPTION:
  "Agustini", "Fithriasari", "Prastyo" are author surnames; "CSE", "CAE",
  "CAPE" (read as SCAPE), "MAPE" are method/metric acronyms that are defined
  on first use in the Description text. These are intentional and correct.

## Test environments

* local Ubuntu 24.04, R 4.3.3
* win-builder (R-release)
* GitHub Actions: ubuntu-latest (devel, release, oldrel-1),
  macOS-latest (release), windows-latest (release)

## Notes

* The package ships no data. Datasets used in the source article are
  referenced by link only; firm-level microdata from BPS-Statistics Indonesia
  are confidential and not redistributable.
