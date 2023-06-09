# Zadanie 3 
 
# ZIGGURAT 100 MS VS 90 MS DLA KLASYCZNEGO (1_000_000 PRÓB)
# 12 WYWOŁAŃ PDF NA 100 LOSOWAŃ


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
    counts = 0

    for i = 1:N
        x = 0.
        counter = 0
        num_of_runs = 0
        
        while true 
         
            x = rand(Exponential(1))
            y = sqrt(2ℯ/π) * rand() * pdf(Exponential(1), x)
            idx = findindex(x, intervals)
            num_of_runs += 1
            
            if y > extr[idx]
                continue
            end
            if y < extr[idx + 1]
                break
            end

            if y <= 2 * pdf(Normal(0, 1), x)
                counter += 1
                break
            end

        end

        samples[i] = x
        counts += counter / num_of_runs
    end

    return (samples, counts/N)

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


abs_norm_samples, mean_pdf_calls_rate = ziggurat(10000, intervals, extr)
print(mean_pdf_calls_rate)
samples = vcat(abs_norm_samples, -abs_norm_samples)

histogram(samples, normalize = :pdf, legend=false)

ExactOneSampleKSTest(samples, Normal(0, 1))