# OPTIMIZATION
The easiest kind of optimization is the unconstrained one. \
Clearly, it's more realistic to have equality/inequality constraints to be satisfied. \
Note that maximizing $f(x)$ is equivalent to minimizing $-f(x)$. 

We could minimize without derivations, just by evaluating (with a _loop_) several points and observe the minimum value of $f(x)$. The problem of this method is that it's very
computational expensive. Some algorithms ("_Genetic algorithms_") start by a large interval of possible optimal points and then restrict the interval and repeat until they're confident of the optimum. \
There are situations in which these algorithms are used, for example when the function is not differentiable.

The other method is based on the gradient (hence the function must be differentiable), called "_gradient descent_". The idea is to start with a generic gradient in a point $x_0$
that we arbitrarily choose. A generic pseudo-code is to set $x=x_0$ and $convergence=0$, then do a _while loop_ which iterates the derivative (computed with $x=x-a*df$, as we've seen
in the previous lecture) while $convergence=0$. Lastly, we have to do a test to stop the while loop; we can proceed with 2 tests:
* if $df==0$, then set $convergence=1$ (which will stop the while loop). This has some problems with non-smooth functions, since computers compute with errors, so the condition has to admit _tolerance_, e.g. if $abs(df)<0.000001$
* another test imply the _relative tolerance_, i.e. $abs{[f(x^1)-f(x^0)]/f(x^0)} < 0.000001$ 

Now we have to compute $a$, which will be done with different methods of _Scipy_. \
Lastly, we have to be able to compute derivatives; we can do that with the method of _finite differences_. The error of this method, and the computational time, grow with the dimension of the functions. \
The alternative is to use _automatic differentiation_ with the Python package _autograd_, which computes the actual derivative, so the error is zero, and the computational time is constant (i.e. does not increase with time).
This is what has permitted the existence of things like chatGPT. 
In order to work with these things in Python, we have to use a special version of _Numpy_ called _autograd.numpy_ (_anp_).

## ASSIGNMENT 2
In an $AR(1)$ process such as $y_t=a+rho*y_t-1+u_t$, we have to estimate rho.
Firstly, we have to cut the first observations because the matrix $X$ will have an _NA_ in the first row (due to $t-1$).
We can estimate rho with the following two methods.
#### MLE
If we set the conditional distribution $y_t|y_t-1$, then y_t-1 is treated as a constant, so y_t will have only u_t as random variable. \
If we assume that u_t is distributed as a white noise, then y_t will be distributed as a normal with mean=a+rho*y_t-1 and variance equal to the variance of u_t (i.e. sigma squared). \
Now we write the _likelihood function_ (i.e. the probability of observing the data), knowing that the joint distribution of several random variables is equal to the product between the conditional distributions and the marginal distributions. \
We can expand the density until it's equal to the conditional distributions, so we'll have a _produttoria_. \
Then we have also the unconditional distribution ... \

Note that we have to make sure that sigma squared is positive, rho is between -1 and 1, and alfa can be anything. These are actually constraints. \
The minimizer in Julia/Python has _bounds_, i.e. the range of value of the estimators. 
A more clever (but harder) way is to define a new parameter _sigma squared tilda_ equal to exp(sigma squared), and eventually remember to take log of optimal value to get back to sigma squared





