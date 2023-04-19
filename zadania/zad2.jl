# Zadanie 2
using Distributions
using Plots
using HypothesisTests

p = 1/2
l = 5

poisson(x, l)   = ℯ^-l * l^x / factorial(x)
geometric(x, p) = (1 - p)^(x - 1) * p 


# TODO: Wektoryzacja 
function accept_reject(p, l)

    c = maximum([poisson(x, l) / geometric(x, p) for x in 1:2l])

    X = rand(Geometric(p))

    if c * rand() * geometric(X, p) <= poisson(X, l)
        return X
    else 
        accept_reject(p, l)
    end
end


samples = [accept_reject(p, l) for _ in 1:1000]

histogram(samples, normalize=:pdf)

pvalue(ExactOneSampleKSTest(samples, Poisson(l)), tail=:right)