# Zadanie 2
using Distributions
using Plots
using HypothesisTests
using BenchmarkTools

p = 1/2
l = 2

# Podczas generowania próbek o dużej długości od pewnego momentu dochodziło do zwracania 
# nadzwyczajnie dużych liczb (na przykład ciąg  1667017767313, 110544 ,1667017767345, 110544). Po konwersji 
# zwracanej wartości przez funkcję poisson z Float64 na BigFloat problem zniknął. Nie doszło jednakże do 
# spadku wydajności generowania zmiennych.
poisson(x, l)   = BigFloat(ℯ^-l * l^x / factorial(big(x)))

geometric(x, p) = (1 - p)^(x - 1) * p 

c = maximum([poisson(x, l) / geometric(x, p) for x in 1:2l])

# TODO: Wektoryzacja 
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

    prev_filled_count = 0
    filled_count      = 0
    N                 = size

    while filled_count < N

        x = rand(Geometric(p), N)
        
        # Filtr wskazujący na wartości do zaakceptowania w aktualnej iteracji
        mask = c .* rand(N) .* geometric.(x, p) .<= poisson.(x, l)

        filled_now    = sum(mask)
        filled_count += filled_now
        N            -= filled_now

        result[1+prev_filled_count:filled_count] = x[mask][1:filled_count-prev_filled_count]
        prev_filled_count = filled_count
    
    end

    return result

end

@btime [accept_reject(p, l) for _ in 1:100_000]
@btime accept_reject_vectorized(p, l, 100_000)


histogram(samples, normalize=:pdf)

pvalue(ExactOneSampleKSTest(samples, Poisson(l)), tail=:right)