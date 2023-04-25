# Zadanie 3 

# TODO: OPTYMALIZACJA! DZIŁA W MAŁEJ ILOŚCI SCHODKÓW 2 RAZY 
# TODO: WOLNIEJ NIŻ METODA KLASYCZNA. 


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

    xs = LinRange(0, 3, resolution)

    ys = 2 .* pdf.(Normal(0, 1), xs)
    push!(ys, 0)

    return (xs, ys)

end

function ziggurat(N)

    samples = Vector{Float64}(undef, N)

    prev_filled_count = 0
    filled_count      = 0
    size              = N

    intervals, extr = steps_2(10)

    while filled_count < N

        x = rand(Exponential(1), size)
        
        Y = sqrt(2ℯ/π) .* rand(size) .* pdf.(Exponential(1), x)

        mask = BitArray(undef, size)
        for i in 1:size
            idx = findindex(x[i], intervals)
            if Y[i] > extr[idx]
                mask[i] = 0
            elseif Y[i] < extr[idx + 1]
                mask[i] = 1
            else
                mask[i] = Y[i] <= 2 * pdf(Normal(0, 1), x[i])
            end
        end
        
        filled_now    = sum(mask)
        filled_count += filled_now
        size         -= filled_now

        samples[1+prev_filled_count:filled_count] = x[mask][1:filled_count-prev_filled_count]
        prev_filled_count = filled_count

    end
    samples
end

@btime ziggurat(1_000_000) 
abs_norm_samples = ziggurat(10000)
samples = vcat(abs_norm_samples, -1 .* abs_norm_samples)

histogram(samples, normalize = :pdf, legend=false)

ExactOneSampleKSTest(samples, Normal(0, 1))