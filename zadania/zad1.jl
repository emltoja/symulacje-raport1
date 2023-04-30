# Zadanie 1
using Plots 
using BenchmarkTools

# Generator liczb pseudolosowych o rozkładzie U(0, 1)
function MRG32k3a(
    size, 
    seedx = [1822406609, 1153072917, 1254937013], 
    seedy = [2311980605, 7239483046, 2394024690]
    )

    result = Vector{Float64}(undef, size)

    m1 = 2^32 - 209
    m2 = 2^32 - 22853

    for i in 1:size

        x = mod((1403580seedx[2] - 810728seedx[3]), m1)
        y = mod((527612seedy[1] - 1370589seedy[3]), m2)

        result[i] = mod((x - y), m1) / m1

        pop!(seedx); pop!(seedy)
        pushfirst!(seedx, x); pushfirst!(seedy, y)

    end

    return result

end

@btime MRG32k3a(10_000)

samples = MRG32k3a(100_000)
# Rozkład odległości między realizacjami
distances = [abs(samples[i + 1] - samples[i]) for i in 1:length(samples)-1]

scatter(1:length(samples), samples, markersize=1)
scatter(1:length(samples)-1, distances, markersize=1)

histogram(samples, normalize=:pdf)
histogram(distances, normalize=:pdf)