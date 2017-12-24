# Fast exponent approximation

A very fast, compact, and accurate approximation to the exponent function.

This is based on the following articles:

\[1]: https://schraudolph.org/pubs/Schraudolph99.pdf

\[2]: http://dx.doi.org/10.1162/089976600300015033

## Testing for accuracy

### Requirements:

* gnuplot
* ImageMagick

### Building:

`make`

### Plotting:

`./compare.sh`

(Default range: [-5, 0]. You can edit **compare.sh** to change it.)

#### Expected result:

![Compare](https://raw.githubusercontent.com/blochl/Tools/images/fast_exp/compare.png)

### Cleaning:

`make clean`

## Testing for speed

Use the function in your own application to benchmark the performance.

## License

This code is released under the standard 3-clause BSD license. Please see the
[LICENSE](https://github.com/blochl/Tools/blob/master/fast_exp/LICENSE) file
for the full license text.
