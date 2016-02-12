import math
import algorithm  # needed for `sort`

const
  NAN = 0.0/0.0 # floating point not a number (NaN)

proc cIsNaN(x: float): int {.importc: "isnan", header: "<math.h>".}
  ## returns non-zero if x is not a number

proc isNaN*(x: float): bool =
  ## converts the integer result from cIsNaN to a boolean
  if cIsNaN(x) != 0: true
  else: false

proc median*(x: openArray[float]): float =
  ## computes the median of the elements in `x`.
  ## If `x` is empty, NaN is returned.

  var sx = @x # convert to a sequence since sort() won't take an openArray
  sx.sort(system.cmp[float])

  try:
    if sx.len mod 2 == 0:
      var n1 = sx[(sx.len - 1) div 2]
      var n2 = sx[sx.len div 2]
      result = (n1 + n2) / 2.0
    else:
      result = sx[(sx.len - 1) div 2]
  except IndexError:
    result = NAN
## Some additional functions from math.h are needed
## that aren't included in the math module

proc erf(x: float): float {.importc: "erf", header: "<math.h>".}
## computes the error function (also called the Gauss error function)

type
  GaussDist* = object
    mu, sigma: float

proc NormDist*(): GaussDist =
  ## A Normal Distribution is a special form of the Gaussian Distribution with
  ## mean 0.0 and standard deviation 1.0
  result.mu = 0.0
  result.sigma = 1.0

proc mean*(g: GaussDist): float =
  result = g.mu

proc standardDeviation*(g: GaussDist): float =
  result = g.sigma

proc variance*(g: GaussDist): float =
  result = math.pow(g.sigma, 2)

## The distribution functions are from
## http://en.wikipedia.org/wiki/Normal_distribution
proc pdf*(g: GaussDist, x: float): float =
  var numer, denom: float

  numer = math.exp(-(math.pow((x - g.mu), 2)/(2 * math.pow(g.sigma, 2))))
  denom = g.sigma * math.sqrt(2 * math.PI)
  result = numer / denom

proc cdf*(g: GaussDist, x: float): float =
  var z: float

  z = (x - g.mu) / (g.sigma * math.sqrt(2))
  result = 0.5 * (1 + erf(z))

when isMainModule:
  var n = NormDist()
  var gnorm = GaussDist(mu: 0.0, sigma: 2.0)

  try:
    assert(n.mean == gnorm.mean)
    assert(n.standardDeviation == gnorm.standardDeviation)
    assert(n.variance == gnorm.variance)
    assert(n.pdf(0.5) == 0.3520653267642995)
    assert(n.cdf(0.5) == 0.6914624612740131)

    # Setup some test data
    var data1: array[0..6, float]
    var data2: array[0..7, float]
    var data3 = newSeq[float]()
    var data4: array[1, float]
    var data5: array[2, float]
    data1 = [1.4, 3.6, 6.5, 9.3, 10.2, 15.1, 2.2]
    data2 = [1.4, 3.6, 6.5, 9.3, 10.2, 15.1, 2.2, 0.5]
    data4 = [2.3]
    data5 = [2.2, 2.5]

    # Test median()
    assert(abs(median(data1) - 6.5) < 1e-8)
    assert(abs(median(data2) - 5.05) < 1e-8)
    assert(isNaN(median(data3)))  # test an empty sequence
    assert(abs(median(data4) - 2.3) < 1e-8)
    assert(abs(median(data5) - 2.35) < 1e-8)

    echo "SUCCESS: Tests passed!"
  except:
    echo "FAILED"
