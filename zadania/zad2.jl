# Zadanie 2
using Distributions
using Plots
using HypothesisTests
using BenchmarkTools

p = 1/2
l = 2


poisson(x, l)   = ℯ^-l * l^x / factorial(big(x))

geometric(x, p) = (1 - p)^(x - 1) * p 

c = maximum([poisson(x, l) / geometric(x, p) for x in 1:2l])

function accept_reject(p, l)


    X = rand(Geometric(p))

    if c * rand() * geometric(X, p) <= poisson(X, l)
        return X
    else 
        accept_reject(p, l)
    end
end


function accept_reject_vectorized(p, l, size)

    result = Vector{Int64}(undef, size)

    for i in 1:size

        x = rand(Geometric(p))
        
        while c * rand() * geometric(x, p) > poisson(x, l)
            x = rand(Geometric(p))
        end

        result[i] = x

    end

    return result

end


# Porównanie wydajności obu metod
@benchmark [accept_reject(p, l) for _ in 1:10_000]
@benchmark accept_reject_vectorized(p, l, 10_000)


samples =  accept_reject_vectorized(p, l, 100_000)


histogram(samples, normalize=:probability)
scatter!(0:10, pdf.(Poisson(l), 0:10))

# Testy statystyczne
pvalue(ExactOneSampleKSTest(samples, Poisson(l)), tail=:right)
