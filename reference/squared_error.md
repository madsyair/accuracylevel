# Calculate Squared Error

Compute squared error between actual and predicted values, as defined in
Equation (1) of Agustini et al. (2026).

## Usage

``` r
squared_error(actual, predicted, na.rm = FALSE)
```

## Arguments

- actual:

  Numeric vector of actual (observed) values.

- predicted:

  Numeric vector of predicted values.

- na.rm:

  Logical. If `TRUE`, remove `NA` pairs before computing. Default is
  `FALSE`.

## Value

Numeric vector of squared errors.

## References

Agustini, M., Fithriasari, K., & Prastyo, D.D. (2026). An accuracy-level
method for robust evaluation in predictive analytics. *Decision
Analytics Journal*, 18, 100661.
[doi:10.1016/j.dajour.2025.100661](https://doi.org/10.1016/j.dajour.2025.100661)

## Examples

``` r
actual <- c(10, 20, 30, 40, 50)
predicted <- c(11, 19, 32, 38, 51)
squared_error(actual, predicted)
#> [1] 1 1 4 4 1
```
