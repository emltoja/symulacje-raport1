# Zadanie 4

using Plots 
using Distributions
using BenchmarkTools
using HypothesisTests
using SpecialFunctions
using BenchmarkPlots
SAMPLESIZE = 100

###############################
# Generowanie wbudowaną funkcją
###############################

@btime randn(SAMPLESIZE)

builtin_sample = randn(SAMPLESIZE)
ExactOneSampleKSTest(builtin_sample, Normal(0, 1))


# Dystrybuanta empiryczna
builtin_sorted = sort(builtin_sample)
plot(builtin_sorted, LinRange(0, 1, SAMPLESIZE), linetype=:steppre)

#################################
# Generowanae metodą Boxa-Mullera
#################################

function boxmuller(size)

    θ = 2π .* rand(size)
    R = sqrt.(-2 .* log.(rand(size)))

    return R .* sin.(θ)
end

@btime boxmuller(SAMPLESIZE)

boxmuller_sample = boxmuller(SAMPLESIZE)
ExactOneSampleKSTest(boxmuller_sample, Normal(0, 1))

boxmuller_sorted = sort(boxmuller_sample)
plot(boxmuller_sorted, LinRange(0, 1, SAMPLESIZE), linetype=:steppre)


##############################
# Generowanie metodą Marsaglii
##############################

function marsaglia(size)

    result = Vector{Float64}(undef, size)

    for i in 1:size
        x = 2 * rand() - 1
        y = 2 * rand() - 1

        while x^2 + y^2 > 1
            x = 2 * rand() - 1
            y = 2 * rand() - 1
        end

        s = x^2 + y^2

        result[i] = x * sqrt(-2log(s) / s)
    end

    return result
end

@btime marsaglia(SAMPLESIZE)

marsaglia_samples = marsaglia(SAMPLESIZE)
ExactOneSampleKSTest(marsaglia_samples, Normal(0, 1))

marsaglia_sorted = sort(marsaglia_samples)
plot(marsaglia_sorted, LinRange(0, 1, SAMPLESIZE), linetype=:steppre)

###########################################
# Generowanie metodą odwrotnej dystrybuanty
###########################################


inversecdf(x) = -sqrt(2) * erfcinv(2x)

function inv(size)
    return inversecdf.(rand(size))
end

@btime inv(SAMPLESIZE)


inversecdf_samples = invΦ(SAMPLESIZE)
ExactOneSampleKSTest(inversecdf_samples, Normal(0, 1))


function benchmark(size)
    
    suite = BenchmarkGroup()
    for f in (boxmuller, marsaglia, randn, inv)
        suite[string(f)] = @benchmarkable $(f)($size)
    end
    tune!(suite)
    run(suite, verbose=true, samples=50)

end

bench_results = benchmark(100_000)
plot(bench_results)