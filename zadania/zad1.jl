# Zadanie 1
using Plots 

function MRG32k3a(
    size, 
    seedx = (1822406609, 1153072917, 1254937013), 
    seedy = (2311980605, 7239483046, 2394024690)
    )

    result = Vector{Float64}(undef, size)

    m1 = 2^32 - 209
    m2 = 2^32 - 22853

    prevX :: Vector{Int64} = [seedx...]
    prevY :: Vector{Int64} = [seedy...]

    for i in 1:size

        x = mod((1403580prevX[2] - 810728prevX[3]), m1)
        y = mod((527612prevY[1] - 1370589prevY[3]), m2)

        # result[i] = x <= y ? (x - y + m1) / (m1 + 1) : (x - y) / (m1 + 1)
        result[i] = mod((x - y), m1) / m1

        pop!(prevX); pop!(prevY)
        pushfirst!(prevX, x); pushfirst!(prevY, y)

    end

    return result

end

samples = MRG32k3a(10000)
distances = [abs(samples[i + 1] - samples[i]) for i in 1:length(samples)-1]

scatter(1:length(samples), samples)
scatter(1:length(samples)-1, distances)

histogram(samples, normalize=:pdf)