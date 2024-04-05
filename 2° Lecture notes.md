# Lecture 05/04/2024
## OPTIMIZATION
### Univariate case
We usually work with function $f(x): R^k -> R$.
For humans it's easy to optimize, but for computer we need to code the process.
Computers can easiliy evaluate the value of $f(x_0)$, i.e. in a casual point $x_0$.
If the first derivative of $f(x_0)$ is positive, then we have to decrease the value of $x_0$ to get closer to the actual minimum point.
We decrease by a rate $α$ which is called the "step-length": $x^k = x^(k-1) -αf'(x^(k-1))$.
We do that until we converge to the actual minimum $x*$.
When we decrease, we could either take big or small steps, but both have a cost:
* small steps requires a lot of steps to converge
* large steps present the risk to go beyond the optimal point (i.e. won't find it)
Global optimizer algorithms exist too, but they are very expensive.
### Multivariate case
Now we have k directions because we have k variables, therefore the term after the step-length will be the gradient of dimension $(k x 1)$.
### Optimizer algorithm
In the neighbourhood $x_0$ we can aproximate the function with a Taylor expansion of 2° order, i.e. a quadratic approximation.
Remember that the step is: $x^k = x^(k-1) -αf'(x^(k-1))$.
Therefore we can substitue $x^k$ into the quadratic approximation, then derive it with respect to $α$ and set it equal to $0$.
It turns out that alfa is equal to 1 over the second derivative of $f(x^(k-1))$. This is the **steepest descent direction** (or "Newton's step").
Thus, due to the presence of second derivative, we will need to compute the Hessian matrix.
Computers, however cannot do calculus, so we need to use one of the following algorithms (clearly we could also do math with pen and paper, but it would be impossible with several equations).
#### Finite differences algorithm
We use the asymptotic definition of derivatives. We choose a very small ε and
#### Automatic differentiation algorithm
This method does not use approximation, but the fact that there is a clever way to make a computer computes derivatives without knowing.
This method is present in *C++* (therefore also in *Python*) and *Julia*, but not in *R*:
* In Python there is *autograd* or *pytorch*, which is a Python package used for deep learning.
* In Julia there is *forwarddiff.jl*
Note that these are the same algorithms used for solving non-linear equations (for example in *DSGE* macroeconomic models).
### Constrained optimization
There is a famous package called *Ipopt*, whose implementation in Julia called *Ipopt.jl*.











