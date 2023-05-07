# Zadanie 5 
using Plots
using LinearAlgebra
using HypothesisTests
using Statistics
using Distributions

function multivariate_normal(size :: Int, dim :: Int, covariance_matrix :: Matrix, means_vector :: Vector)

    result = Matrix{Float64}(undef, size, dim)

    A = cholesky(covariance_matrix).L
    
    for i = 1:size
        result[i, :] = A * randn(dim) + means_vector
    end

    return result

end

not_corelated_matrix = [1 0; 0 1]

not_corelated_sample = multivariate_normal(100_000, 2, not_corelated_matrix, [0, 0])

X = not_corelated_sample[:, 1]
Y = not_corelated_sample[:, 2]

histogram(X, normalize=:pdf, alpha=0.5)
histogram!(Y, normalize=:pdf, alpha=0.5)

histogram(X .+ Y, normalize=:pdf, alpha=0.5)
histogram!(X, normalize=:pdf, alpha=0.5)
histogram!(Y, normalize=:pdf, alpha=0.5)

#std(X + Y) = sqrt(std^2(x) + std^2(y))
#mean(X + Y) = mean(X) + mean(Y)
# Rozkład nadal pozostaje normalny
ExactOneSampleKSTest(X .+ Y, Normal(0, sqrt(2)))

histogram(X .- Y, normalize=:pdf, alpha=0.5)
histogram!(X, normalize=:pdf, alpha=0.5)
histogram!(Y, normalize=:pdf, alpha=0.5)

#std(X - Y) jak wyżej 
#mean(X - Y) mean(X) - mean(Y)
# Rozkład nadal pozostaje normalny 

histogram(X.^2 .+ Y.^2, normalize=:pdf, alpha=0.5)
histogram!(X, normalize=:pdf, alpha=0.5)
histogram!(Y, normalize=:pdf, alpha=0.5)

# Dla rozkładów standardowych X^2 + Y^2 ma rozkład chi kwadrat o średniej 2 i std 2

ExactOneSampleKSTest(X.^2 .+ Y.^2, Chisq(2))
