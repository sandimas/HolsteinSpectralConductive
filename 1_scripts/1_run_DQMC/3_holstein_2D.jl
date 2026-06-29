using LinearAlgebra
using Random
using Printf
using MPI
using FileIO
using JLD2


using SmoQyDQMC
import SmoQyDQMC.LatticeUtilities  as lu
import SmoQyDQMC.JDQMCFramework    as dqmcf
import SmoQyDQMC.JDQMCMeasurements as dqmcm
import SmoQyDQMC.MuTuner           as mt

λs = [0.125, 0.25, 0.3, 0.325, 0.35, 0.375, 0.4, 0.425, 0.45, 0.475, 0.5, 0.625, 0.75]
βs = 5.0:1.0:20.0 |> collect
Ωs = 0.5:0.5:2.0 |> collect
ns = 0.05:0.05:1.0 |> collect
μs = LinRange(-1.4,0.0,20) |> collect

# top level function to run simulation
function run_simulation(ARGS)
    
    N_burnin = 5000
    # number of simulation updates
    N_updates = 2000
    # number of bins/number of time 
    # to average over
    N_bins = 100

    # bin size
    bin_size = div(N_updates, N_bins)

    runtime_limit = 24.0*60*60 # 24 hours
    checkpoint_freq = 0.5*60*60 # 0.5 hours

    start_timestamp = time() # in seconds


    # create data folder for simulations
    output_folder = "simulations_rerun/"
    mkpath(output_folder)

    #############################
    ## INITIALIZE MPI COMMUNICATOR ##
    #############################
    MPI.Init()
    comm = MPI.COMM_WORLD

    pID = MPI.Comm_rank(comm)

    

    

    n_MPI = MPI.Comm_size(comm)
    n_filling = length(ns)
    n_walkers = div(n_MPI, n_filling)

    λi = parse(Int64,ARGS[1])
    βi = parse(Int64,ARGS[2])
    Ωi = parse(Int64,ARGS[3])
    ni = div(pID, n_walkers) + 1
    walker = mod(pID, n_walkers)
    
	#############################
    ## DEFINE MODEL PARAMETERS ##
    #############################

    #####
    #
    # Arguments:
    #   L BETA DENSITY OMEGA LAMBDA 
    #
    #####

    L = 14 #parse(Int64,ARGS[1])
    β = βs[βi]
    avg_n = ns[ni]
    Ω = Ωs[Ωi]
    λ = λs[λi]
    
    # system size
    
    # nearest-neighbor hopping amplitude
    t = 1.0

    # holstein coupling constant
    α = Ω*sqrt(8*t*λ)

    # initial chemical potential
    μ = μs[ni]

    # discretization in imaginary time
    Δτ = 0.10

    # evaluate length of imaginary time axis
    Lτ = dqmcf.eval_length_imaginary_axis(β, Δτ)

    # whether to use the checkerboard approximation
    checkerboard = false

    # whether to use symmetric propagator defintion 
    symmetric = false

    # initial stabilization frequency
    n_stab = 10

    # max allowed error in green's function
    δG_max = 1e-6

    # number of thermalization/burnin updates
    
    # calculate length of imaginary time axis
    Lτ = dqmcf.eval_length_imaginary_axis(β, Δτ)

    # define kagome unit cell
    unit_cell = lu.UnitCell(lattice_vecs = [[1.0,0.0], [0.0,1.0]],
                            basis_vecs   = [[0.0,0.0]])

    # define size of lattice (only supports periodic b.c. for now)
    lattice = lu.Lattice(
        L = [L,L],
        periodic = [true, true] # must be true for now
    )

    # define model geometry
    model_geometry = ModelGeometry(unit_cell, lattice)

    # calculate number of orbitals in the lattice
    N = lu.nsites(unit_cell, lattice)

    # define first nearest-neighbor bond
    bond_x = lu.Bond(orbitals = (1,1), displacement = [1,0])
    bond_x_id = add_bond!(model_geometry, bond_x)

    # define second nearest-neighbor bond
    bond_y = lu.Bond(orbitals = (1,1), displacement = [0,1])
    bond_y_id = add_bond!(model_geometry, bond_y)


    # define non-interacting tight binding model
    tight_binding_model = TightBindingModel(
        model_geometry = model_geometry,
        t_bonds = [bond_x, bond_y],
        t_mean = [t, t],
        μ = μ,
        ϵ_mean = [0.]
    )

    # initialize null electron-phonon model
    electron_phonon_model = ElectronPhononModel(
        model_geometry = model_geometry,
        tight_binding_model = tight_binding_model
    )

    # define phonon mode for each orbital in unit cell
    phonon_1 = PhononMode(basis_vec = [0.0,0.0], Ω_mean = Ω)


    # add the three phonon modes to the model
    phonon_1_id = add_phonon_mode!(electron_phonon_model = electron_phonon_model, phonon_mode = phonon_1)

    # define holstein coupling for first orbital/phonon mode in unit cell
    holstein_coupling_1 = HolsteinCoupling(
        model_geometry = model_geometry,
        phonon_id = phonon_1_id,
        orbital_id = 1,
        displacement = [0,0],
        α_mean = α,
        ph_sym_form = true,
    )
    
    # number of fermionic time-steps in HMC trajecotry
    Nt = 10
    Δt =  π/(2*Nt)
    
    # mass regularization in fourier acceleration
    reg = 1.0
    # define simulation name
    datafolder_prefix = @sprintf "holstein_singleband_2D_w%.2f_l%.2f_n%.2f_L%d_b%.2f" Ω λ avg_n L β

    # initialize simulation info
    simulation_info = SimulationInfo(
        filepath = output_folder,                     
        datafolder_prefix = datafolder_prefix,
        sID = 1,
        pID = walker
    )


    # initialize data folder
    MPI.Barrier(comm)
    initialize_datafolder(simulation_info)
    
    if !simulation_info.resuming
        if pID == 0
            println("starting new simulation")
        end

        n_therm = 1
        n_measurements = 1

        # initialize random seed
        seed = abs(1000 + walker)

        # initialize random number generator
        rng = Xoshiro(seed)

        

        # initialize addition simulation information dictionary
        additional_info = Dict(
            "dG_max" => δG_max,
            "N_burnin" => N_burnin,
            "N_updates" => N_updates,
            "N_bins" => N_bins,
            "bin_size" => bin_size,
            "dt" => Δt,
            "Nt" => Nt,
            "reg" => reg,
            "hmc_acceptance_rate" => 0.0,
            "swap_acceptance_rate" => 0.0,
            "reflection_acceptance_rate" => 0.0,
            "n_stab_init" => n_stab,
            "symmetric" => symmetric,
            "checkerboard" => checkerboard,
            "seed" => seed,
        )

        ##################
        ## DEFINE MODEL ##
        ##################

        #
        

        # add first holstein coupling to the model
        holstein_coupling_1_id = add_holstein_coupling!(
            electron_phonon_model = electron_phonon_model,
            holstein_coupling = holstein_coupling_1,
            model_geometry = model_geometry
        )

        # write model summary to file
        model_summary(
            simulation_info = simulation_info,
            β = β, Δτ = Δτ,
            model_geometry = model_geometry,
            tight_binding_model = tight_binding_model,
            interactions = (electron_phonon_model,)
        )

        ####################################################
        ## INITIALIZE MODEL PARAMETERS FOR FINITE LATTICE ##
        ####################################################

        # define tight binding parameters for finite lattice based on tight binding model
        tight_binding_parameters = TightBindingParameters(
            tight_binding_model = tight_binding_model,
            model_geometry = model_geometry,
            rng = rng
        )

        # define electron-phonon parameters for finite model based on electron-phonon model
        electron_phonon_parameters = ElectronPhononParameters(
            β = β, Δτ = Δτ,
            electron_phonon_model = electron_phonon_model,
            tight_binding_parameters = tight_binding_parameters,
            model_geometry = model_geometry,
            rng = rng
        )
        initialize_x_fields_cdw!(electron_phonon_parameters, rng, α, Ω, avg_n, 0.1, L)

        ######################################
        ## DEFINE AND INIALIZE MEASUREMENTS ##
        ######################################

        # initialize measurement container
        measurement_container = initialize_measurement_container(model_geometry, β, Δτ)

        # initializing tight-binding model measurements
        initialize_measurements!(measurement_container, tight_binding_model)

        # initialize electron-phonon model measurements
        initialize_measurements!(measurement_container, electron_phonon_model)

        # # measure time-displaced green's function
        initialize_correlation_measurements!(
            measurement_container = measurement_container,
            model_geometry = model_geometry,
            correlation = "greens", # Gup = Gdn, so just measure Gup
            time_displaced = true,
            pairs = [(1, 1)]
        )

        # measure time-displaced phonon green's function
        initialize_correlation_measurements!(
            measurement_container = measurement_container,
            model_geometry = model_geometry,
            correlation = "density",
            time_displaced = true,
            pairs = [(phonon_1_id, phonon_1_id)]
        )

        initialize_correlation_measurements!(
            measurement_container = measurement_container,
            model_geometry = model_geometry,
            correlation = "spin_z",
            time_displaced = true,
            integrated = false,
            pairs = [(1, 1)]
        )

        initialize_correlation_measurements!(
            measurement_container = measurement_container,
            model_geometry = model_geometry,
            correlation = "current",
            time_displaced = true,
            integrated = false,
            pairs = [(1, 1)] # hopping ID pair for y-direction hopping
        )

        # initialize the density/chemical potential tuner
        chemical_potential_tuner = mt.init_mutunerlogger(
            target_density = avg_n,
            inverse_temperature = β,
            system_size = lu.nsites(unit_cell, lattice),
            initial_chemical_potential = μ,
            complex_sign_problem = false,
            memory_fraction = 0.5, # fraction of memory to use for storing measurements
            intensive_energy_scale = 1.0#α^2/Ω^2,
        )

        # Write initial checkpoint file.
        checkpoint_timestamp = write_jld2_checkpoint(
            comm,
            simulation_info;
            checkpoint_freq = checkpoint_freq,
            start_timestamp = start_timestamp,
            runtime_limit = runtime_limit,
            # Contents of checkpoint file below.
            n_therm =1, n_measurements = 1,
            tight_binding_parameters, electron_phonon_parameters, 
            measurement_container, model_geometry, additional_info, rng, chemical_potential_tuner
        )
        MPI.Barrier(comm)
    else
       
        # Load the checkpoint file.
        checkpoint, checkpoint_timestamp = read_jld2_checkpoint(simulation_info)

        # Unpack contents of checkpoint dictionary.
        tight_binding_parameters = checkpoint["tight_binding_parameters"]
        electron_phonon_parameters = checkpoint["electron_phonon_parameters"]
        measurement_container = checkpoint["measurement_container"]
        model_geometry = checkpoint["model_geometry"]
        additional_info = checkpoint["additional_info"]
        rng = checkpoint["rng"]
        n_therm = checkpoint["n_therm"]
        n_measurements = checkpoint["n_measurements"]
        chemical_potential_tuner = checkpoint["chemical_potential_tuner"]
        if pID == 0
            println("resuming simulation n_therm: $(n_therm), n_measurements: $(n_measurements)")
        end
    end
    
    ##################################
    ## DEFINE SIMULATION PARAMETERS ##
    ##################################

    

    ###################################################
    ## SET-UP & INITIALIZE DQMC SIMULATION FRAMEWORK ##
    ###################################################

    # initialize a fermion path integral according non-interacting tight-binding model
    fermion_path_integral = FermionPathIntegral(tight_binding_parameters = tight_binding_parameters, β = β, Δτ = Δτ)

    # initialize fermion path integral to electron-phonon interaction contribution
    initialize!(fermion_path_integral, electron_phonon_parameters)

    # allocate and initialize propagators for each imaginary time slice
    B = initialize_propagators(fermion_path_integral, symmetric=symmetric, checkerboard=checkerboard)

    # initialize fermion greens calculator
    fermion_greens_calculator = dqmcf.FermionGreensCalculator(B, β, Δτ, n_stab)

    # initialize alternate fermion greens calculator required for performing various global updates
    fermion_greens_calculator_alt = dqmcf.FermionGreensCalculator(fermion_greens_calculator)

    # calculate/initialize equal-time green's function matrix
    G = zeros(eltype(B[1]), size(B[1]))
    logdetG, sgndetG = dqmcf.calculate_equaltime_greens!(G, fermion_greens_calculator)

    # initialize G(τ,τ), G(τ,0) and G(0,τ) Green's function matrices for both spin species
    G_ττ = similar(G)
    G_τ0 = similar(G)
    G_0τ = similar(G)

    # initialize the density/chemical potential tuner
    chemical_potential_tuner = mt.init_mutunerlogger(
            target_density = avg_n,
            inverse_temperature = β,
            system_size = lu.nsites(unit_cell, lattice),
            initial_chemical_potential = μ,
            complex_sign_problem = false,
            memory_fraction = 0.5, # fraction of memory to use for storing measurements
            intensive_energy_scale = 1.0#α^2/Ω^2,
        )

    # initialize hamitlonian/hybrid monte carlo (HMC) updater
    hmc_updater = EFAHMCUpdater(
        electron_phonon_parameters = electron_phonon_parameters,
        G = G, Nt = Nt, Δt = Δt,
    )

    ############################
    ## PERFORM BURNIN UPDATES ##
    ############################

    # intialize errors corrected by numerical stabilization to zero
    δG = zero(typeof(logdetG))
    δθ = zero(typeof(sgndetG))

    # perform thermalization/burnin updates
    for n in n_therm:N_burnin

        # perform hmc update
        (accepted, logdetG, sgndetG, δG, δθ) = hmc_update!(
            G, logdetG, sgndetG, electron_phonon_parameters, hmc_updater,
            fermion_path_integral = fermion_path_integral,
            fermion_greens_calculator = fermion_greens_calculator,
            fermion_greens_calculator_alt = fermion_greens_calculator_alt,
            B = B, δG_max = δG_max, δG = δG, δθ = δθ, rng = rng,
        )

        # record accept/reject outcome
        additional_info["hmc_acceptance_rate"] += accepted

        # # perform swap update
        (accepted, logdetG, sgndetG) = swap_update!(
            G, logdetG, sgndetG, electron_phonon_parameters,
            fermion_path_integral = fermion_path_integral,
            fermion_greens_calculator = fermion_greens_calculator,
            fermion_greens_calculator_alt = fermion_greens_calculator_alt,
            B = B, rng = rng
        )

        # record accept/reject outcome
        additional_info["swap_acceptance_rate"] += accepted

        # perform reflection update
        (accepted, logdetG, sgndetG) = reflection_update!(
            G, logdetG, sgndetG, electron_phonon_parameters,
            fermion_path_integral = fermion_path_integral,
            fermion_greens_calculator = fermion_greens_calculator,
            fermion_greens_calculator_alt = fermion_greens_calculator_alt,
            B = B, rng = rng, phonon_types = (phonon_1_id,)
        )

        # record accept/reject outcome
        additional_info["reflection_acceptance_rate"] += accepted

        # update the chemical potential
        logdetG, sgndetG = update_chemical_potential!(
            G, logdetG, sgndetG,
            chemical_potential_tuner = chemical_potential_tuner,
            tight_binding_parameters = tight_binding_parameters,
            fermion_path_integral = fermion_path_integral,
            fermion_greens_calculator = fermion_greens_calculator,
            B = B
        )
        if pID == 0 && n % 100 == 0
            println("warm $(n)/$(N_burnin)")
        end
        checkpoint_timestamp = write_jld2_checkpoint(
            comm,
            simulation_info;
            checkpoint_freq = checkpoint_freq,
            start_timestamp = start_timestamp,
            runtime_limit = runtime_limit,
            # Contents of checkpoint file below.
            n_therm = n + 1, 
            n_measurements = 1,
            tight_binding_parameters = tight_binding_parameters, 
            electron_phonon_parameters = electron_phonon_parameters, 
            measurement_container = measurement_container, 
            model_geometry = model_geometry, 
            additional_info = additional_info, 
            rng = rng,
            chemical_potential_tuner = chemical_potential_tuner
        )
        
    end

    ##################################################################
    ## PERFORM SIMULATION/MEASUREMENT UPDATES AND MAKE MEASUREMENTS ##
    ##################################################################
    
    # intialize errors associated with numerical instability to zero
    δG = zero(typeof(logdetG))
    δθ = zero(typeof(sgndetG))
    # MPI.Barrier(comm)
    bin = 1
    # iterate of measurement bins
    for n in n_measurements:N_updates

     

        # perform hmc update
        (accepted, logdetG, sgndetG, δG, δθ) = hmc_update!(
            G, logdetG, sgndetG, electron_phonon_parameters, hmc_updater,
            fermion_path_integral = fermion_path_integral,
            fermion_greens_calculator = fermion_greens_calculator,
            fermion_greens_calculator_alt = fermion_greens_calculator_alt,
            B = B, δG_max = δG_max, δG = δG, δθ = δθ, rng = rng
        )

        # record accept/reject outcome
        additional_info["hmc_acceptance_rate"] += accepted

        # # perform swap update
        (accepted, logdetG, sgndetG) = swap_update!(
            G, logdetG, sgndetG, electron_phonon_parameters,
            fermion_path_integral = fermion_path_integral,
            fermion_greens_calculator = fermion_greens_calculator,
            fermion_greens_calculator_alt = fermion_greens_calculator_alt,
            B = B, rng = rng
        )

        # record accept/reject outcome
        additional_info["swap_acceptance_rate"] += accepted

        # perform reflection update
        (accepted, logdetG, sgndetG) = reflection_update!(
            G, logdetG, sgndetG, electron_phonon_parameters,
            fermion_path_integral = fermion_path_integral,
            fermion_greens_calculator = fermion_greens_calculator,
            fermion_greens_calculator_alt = fermion_greens_calculator_alt,
            B = B, rng = rng, phonon_types = (phonon_1_id,)
        )

        # record accept/reject outcome
        additional_info["reflection_acceptance_rate"] += accepted

        # update the chemical potential
        logdetG, sgndetG = update_chemical_potential!(
            G, logdetG, sgndetG,
            chemical_potential_tuner = chemical_potential_tuner,
            tight_binding_parameters = tight_binding_parameters,
            fermion_path_integral = fermion_path_integral,
            fermion_greens_calculator = fermion_greens_calculator,
            B = B
        )

        # make measurements
        (logdetG, sgndetG, δG, δθ) = make_measurements!(
            measurement_container,
            logdetG, sgndetG, G, G_ττ, G_τ0, G_0τ,
            fermion_path_integral = fermion_path_integral,
            fermion_greens_calculator = fermion_greens_calculator,
            B = B, δG_max = δG_max, δG = δG, δθ = δθ,
            model_geometry = model_geometry, tight_binding_parameters = tight_binding_parameters,
            coupling_parameters = (electron_phonon_parameters,)
        )
    

        # write measurements to file
        bin = div(n-1, bin_size) + 1
        if pID == 0 && n % bin_size == 0
            println("bin $(n÷bin_size)/$(N_bins)")
            
        end
        write_measurements!(
            measurement_container = measurement_container,
            simulation_info = simulation_info,
            model_geometry = model_geometry,
            bin_size = bin_size,
            measurement = n,
            # bin = bin,
            Δτ = Δτ
        )
        
        checkpoint_timestamp = write_jld2_checkpoint(
            comm,
            simulation_info;
            checkpoint_freq = checkpoint_freq,
            start_timestamp = start_timestamp,
            runtime_limit = runtime_limit,
            # Contents of checkpoint file below.
            n_therm = N_burnin + 1, 
            n_measurements = n + 1,
            tight_binding_parameters = tight_binding_parameters, 
            electron_phonon_parameters = electron_phonon_parameters, 
            measurement_container = measurement_container, 
            model_geometry = model_geometry, 
            additional_info = additional_info, 
            rng = rng,
            chemical_potential_tuner = chemical_potential_tuner
        )
        

    end
    

    
    # normalize acceptance rate measurements
    additional_info["hmc_acceptance_rate"] /= (N_updates + N_burnin)
    additional_info["swap_acceptance_rate"] /= (N_updates + N_burnin)
    additional_info["reflection_acceptance_rate"] /= (N_updates + N_burnin)

    # record final max stabilization error that was correct and frequency of stabilization
    additional_info["n_stab_final"] = fermion_greens_calculator.n_stab
    additional_info["dG"] = δG

    # write simulation information to file
    save_simulation_info(simulation_info, additional_info)

    # save density/chemical potential tuning profile
    save_density_tuning_profile(simulation_info, chemical_potential_tuner)

    
    
    # MPI.Barrier(comm)
    datafolder = simulation_info.datafolder
    if pID == 0
        println("merging bins")
    end
    merge_bins(simulation_info)
    MPI.Barrier(comm)
    if pID == 0
        println("processing measurements")
    end
    if walker == 0
        process_measurements(datafolder=simulation_info.datafolder, pIDs=collect(0:n_walkers-1))
        
    end
    MPI.Barrier(comm)
    if walker == 0
        simulation_info = rename_complete_simulation(
            simulation_info,
            delete_jld2_checkpoints = false
        )
    end
    MPI.Finalize()
    return nothing
end


function initialize_x_fields_cdw!(electron_phonon_parameters, rng, α, Ω, n, σ, L)
    coef = (α/Ω^2)
    # set to 2 or 0 e
    for i in 1:L
        for j in 1:L
            electron_phonon_parameters.x[L*(i - 1) + j,:] .=  coef *   ((i+j) % 2 == 0 ? -1 : 1)
        end
    end

    # remove electrons
    target_n =  ceil(Int, n * size(electron_phonon_parameters.x, 1) )
    
    current_n = size(electron_phonon_parameters.x, 1)  

    while current_n > target_n
        randpos = rand(rng, 1:size(electron_phonon_parameters.x, 1))
        
        if electron_phonon_parameters.x[randpos,1] <= 0.0
            electron_phonon_parameters.x[randpos,:] .+= coef
            current_n -= 1
        end
        
    end
    # jiggle
    for i in 1:size(electron_phonon_parameters.x, 1) 
        for j in 1:size(electron_phonon_parameters.x, 2)
            electron_phonon_parameters.x[i,j] += coef *σ * randn(rng)
        end
    end
    
    return current_n
end



# run the simulation
run_simulation(ARGS)
