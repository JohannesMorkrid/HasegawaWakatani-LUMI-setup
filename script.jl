## Run all (alt+enter)
using HasegawaWakatani
using AMDGPU

domain = Domain(256, 256; Lx=48, Ly=48, MemoryType=ROCArray, precision=Float64)
ic = initial_condition(random_crossphased, domain; value=1e-3)

# Linear operator
function Linear(du, u, operators, p, t)
    @unpack laplacian, diff_x = operators
    η, Ω = eachslice(u; dims=3)
    dη, dΩ = eachslice(du; dims=3)
    @unpack ν, μ, κ = p
    dη .= ν * laplacian(η) - 2 * ν * κ * diff_x(η)
    dΩ .= μ * laplacian(Ω)
end

# Non-linear operator, fully non-linear
function NonLinear(du, u, operators, p, t)
    @unpack solve_phi, poisson_bracket, diff_x, diff_y = operators
    @unpack quadratic_term, spectral_exp, spectral_expm1 = operators
    η, Ω = eachslice(u; dims=3)
    dη, dΩ = eachslice(du; dims=3)
    @unpack κ, ζ, σ, ν = p
    ϕ = solve_phi(Ω)

    dη .= poisson_bracket(η, ϕ) - (κ - ζ) * diff_y(ϕ) - ζ * diff_y(η) +
    #-2 * ν * κ * diff_x(η) +
    ν * quadratic_term(diff_x(η), diff_x(η)) +
    ν * quadratic_term(diff_y(η), diff_y(η)) - σ * spectral_expm1(-ϕ)
    dΩ .= poisson_bracket(Ω, ϕ) - ζ * diff_y(η) - σ * spectral_expm1(-ϕ)
end

# Parameters
κ = 1e-2
parameters = (κ=κ, ζ=1e-3, σ=1e-3, ν=1e-4, μ=1e-4)

# Time intervalparameters
tspan = [0.0, 50000.0]

# Diagnostics
diagnostics = @diagnostics [
    progress(; stride=1000),
    probe_all(; positions=[(x, 0) for x in LinRange(-10, 10, 10)], stride=100),
    #get_log_modes(; stride=50, axis=:diag),
    kinetic_energy_integral(; stride=500),
    potential_energy_integral(; stride=500),
    cfl(; stride=5000, silent=true),
    sample_density(; storage_limit="1.5 GB"),
    sample_vorticity(; storage_limit="1.5 GB"),
]

# Collection of specifications defining the problem to be solved
prob = SpectralODEProblem(Linear, NonLinear, ic, domain, tspan; p=parameters, dt=1e-2,
    operators=:all, diagnostics=diagnostics)

# Inverse transform
inverse_transformation!(u) = @. u[:, :, 1] = exp(κ * u[:, :, 1]) - 1

# Output
output_file_name = joinpath("/scratch/project_465002229/HW/paper-1", "output", "sheath-interchange no approx small dt.h5")
output = Output(prob; filename=output_file_name, simulation_name=:parameters,
    physical_transform=inverse_transformation!,
    storage_limit="5 GB",
    store_locally=false)

## Solve and plot
sol = spectral_solve(prob, MSS3(), output; resume=true)

close(output)
