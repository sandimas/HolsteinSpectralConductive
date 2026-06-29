using FileIO
using SmoQyDEAC
using Printf

function dos()


  


    ls = [0.125, 0.25, 0.3, 0.325, 0.35, 0.375, 0.4, 0.425, 0.45, 0.475, 0.5, 0.625, 0.75]
    bs = 5.0:1.0:20.0 |> collect
    os = 0.5:0.5:2.0 |> collect
    ns = 0.05:0.05:1.0 |> collect
    
    ws = collect(LinRange(-15.0, 15.0, 601))
    
    output_dir = "../AC_output/DOS"
    mkpath(output_dir)
    
    n_bins = 100
    n_runs = 100
    
    combined_data = load("../data_jld2s/DOS.jld2")["DOS"]
    
    nthreads = Threads.nthreads()
    
    println("threads: $(nthreads)")
    
    for (li, l) in enumerate(ls)
        println("begin l$(l)")
        for (oi, o) in enumerate(os)
            for (bi, b) in enumerate(bs)
                ntau = 41 + 10 * bi
                taus = collect(LinRange(0.0, b, ntau))
                for (ni, n) in enumerate(ns)
                    input_file = @sprintf "../simulations_rerun/complete_holstein_singleband_2D_w%.2f_l%.2f_n%.2f_L%d_b%.2f-1/AC_data.jld2" o l n 14 b  
                    datafile = @sprintf "complete_holstein_singleband_2D_w%.2f_l%.2f_n%.2f_L%d_b%.2f-1.jld2" o l n 14 b  
                    output_file = joinpath(output_dir, datafile)
                    
                    if isfile(input_file) && (!isfile(output_file) && !any(x -> x > 0.0, combined_data[li,ni,oi,bi,:]))
                        println("starting DOS $(datafile)") 
                        G_r = load(input_file)["G_r"]
                       
                        _ = DEAC_Binned(
                            G_r,
                            b,
                            taus,
                            ws,
                            "time_fermionic",
                            n_bins,
                            n_runs,
                            output_file,
                            "chk.jld2",
                            find_fitness_floor = false,
                            number_of_generations = 5_000,
                            keep_bin_data = false,
                            verbose = false,
                            fitness = 1e-5,
                            
                        )
                       
                    end
                
                end # ns
            end # bs
        end # os
    end # ls

end


dos()