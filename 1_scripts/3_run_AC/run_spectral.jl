using FileIO
using SmoQyDEAC
using Printf

function spectral()

    ls = [0.125, 0.25, 0.3, 0.325, 0.35, 0.375, 0.4, 0.425, 0.45, 0.475, 0.5, 0.625, 0.75]
    bs = 5.0:1.0:20.0 |> collect
    os = 0.5:0.5:2.0 |> collect
    ns = 0.05:0.05:1.0 |> collect
    
    ws = collect(LinRange(-15.0, 15.0, 601))
    
    output_dir = "../AC_output/spec"
    mkpath(output_dir)
    
    n_bins = 100
    n_runs = 100
    
    nk = 21
    
    li = parse(Int64,ARGS[1])
    bi = parse(Int64,ARGS[2])
    oi = parse(Int64,ARGS[3])
    
    l = ls[li]
    b = bs[bi]
    o = os[oi]
    
    ntau = 41 + 10 * bi
    taus = collect(LinRange(0.0, b, ntau))
    
    
    
    for (ni, n) in enumerate(ns)
        data_out = zeros(Float64,(21,601))
        datafile2 = @sprintf "complete_holstein_singleband_2D_w%.2f_l%.2f_n%.2f_L%d_b%.2f_spec-1.jld2" o l n 14 b
        output_file = joinpath(output_dir, datafile2)
        datafile = @sprintf "../simulations_rerun/complete_holstein_singleband_2D_w%.2f_l%.2f_n%.2f_L%d_b%.2f-1/AC_data.jld2" o l n 14 b  
        input_file = datafile
                
        if !isfile(output_file) && isfile(input_file)   
            G_k = load(input_file)["G_k"]
            for k in 1:nk
                
                println("starting spectral $(datafile2) k$(k)") 
                
               
                dict = DEAC_Binned(
                    G_k[:,:,k],
                    b,
                    taus,
                    ws,
                    "time_fermionic",
                    n_bins,
                    n_runs,
                    output_file,
                    "chk_$(li)_$(bi)_$(oi).jld2",
                    find_fitness_floor = false,
                    number_of_generations = 10_000,
                    keep_bin_data = false,
                    verbose = false,
                    fitness = 1e-5,
                    
                )
                data_out[k,:] = dict["A"][:,end]
                
            end # ks
            save(output_file,"A",data_out)
        end # if !isfile(output_file) && isfile(input_file)  
    end # ns

end


spectral()