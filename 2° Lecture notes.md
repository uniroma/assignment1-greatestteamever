# OPTIMIZATION
###### We usually work with function f(x): R^k --> R.
For humans it's easy to optimize, but for computer we need to code the process.
Computers can easiliy evaluate the value of f(x0), i.e. in a casual point x0.
If the first derivative of f(x0) is positive, then we have to decrease the value of x0 to get closer to the actual minimum point.
We decrease by a rate α which is called the "step-lenght": x^k = x^(k-1) -αf'(x^(k-1)).
We do that until we converge to the actual minimum x*.
When we decrease, we could either take big or small steps, but both have a cost:
* small steps requires a lot of steps to converge
* large steps present the risk to go beyond the optimal point

