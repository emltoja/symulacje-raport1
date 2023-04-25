# Zadanie 3 

# TODO: ZLICZANIE WYWOŁAŃ PDF(NORMAL). 
# ZIGGURAT 107 MS VS 140 MS DLA KLASYCZNEGO (1_000_000 PRÓB)


using Distributions
using Plots
using HypothesisTests
using BenchmarkTools


function findindex(x, interval)
    i = 1
    while x > interval[i] && i < length(interval)
        i += 1
    end
    i
end

function steps_2(resolution :: Int)

    # Ze względu na to, że gęstość |N(0, 1)| jest ściśle malejąca na swojej dziedzinie, to maksimum będzie się znajdować 
    # na początku przedziału a minimum na końcu przedziału 

    # Minimum z przedziału [xᵢ, xᵢ₊₁] jest maksimum z przedziału [xᵢ₊₁, xᵢ₊₂]

    xs = LinRange(0, 5, resolution)

    ys = 2 .* pdf.(Normal(0, 1), xs)
    push!(ys, 0)

    return (xs, ys)

end

function ziggurat(N, intervals, extr)

    samples = Vector{Float64}(undef, N)

    for i = 1:N
        x = 0.
        
        while true 
         
            x = rand(Exponential(1))
            y = sqrt(2ℯ/π) * rand() * pdf(Exponential(1), x)
            idx = findindex(x, intervals)
            
            if y > extr[idx]
                continue
            end
            if y < extr[idx + 1]
                break
            end

            if y <= 2 * pdf(Normal(0, 1), x)
                break
            end

        end

        samples[i] = x
    end

    return samples

end

function accept_reject(N)
    
    result = Vector{Float64}(undef, N)

    for i in 1:N
        x = 0 
        y = 10
        while y > 2 * pdf(Normal(0, 1), x)
            x = rand(Exponential(1))
            y = sqrt(2ℯ/π) * rand() * pdf(Exponential(1), x)
        end
        result[i] = x
    end

    return result
end


intervals, extr = steps_2(30)

@btime ziggurat(1_000_000, intervals, extr)
@btime accept_reject(1_000_000)

# times = Vector{Float64}(undef, 99)
# res   = 2:100

# for i in res
#     intervals, extr = steps_2(i)
#     meant = 0
#     for _ in 1:10
#         t = time_ns()
#         ziggurat(1_000, intervals, extr) 
#         meant += time_ns() - t
#     end
#     times[i - 1] = meant/10
# end

# scatter(res, times[2:end])









abs_norm_samples = ziggurat(10000, intervals, extr)
samples = vcat(abs_norm_samples, -1 .* abs_norm_samples)

histogram(samples, normalize = :pdf, legend=false)

ExactOneSampleKSTest(samples, Normal(0, 1))