using FileIO
using HDF5
using JLD2
using CSV
using DataFrames
using Printf

ls = [0.125, 0.25, 0.3, 0.325, 0.35, 0.375, 0.4, 0.425, 0.45, 0.475, 0.5, 0.625, 0.75]
bs = 5.0:1.0:20.0 |> collect
os = 0.5:0.5:2.0 |> collect
ns = 0.05:0.05:1.0 |> collect

ks = [
        (1,1),
        (2,1),
        (3,1),
        (4,1),
        (5,1),
        (6,1),
        (7,1),
        (8,1), # 8
        (8,2),
        (8,3),
        (8,4),
        (8,5),
        (8,6),
        (8,7),
        (8,8), # 15
        (7,7),
        (6,6),
        (5,5),
        (4,4),
        (3,3),
        (2,2), # 21
    ]

nwalkers = 4
nbins = 100
total_bins = nwalkers * nbins

function clean()
    for (li, l) in enumerate(ls)
        for (oi, o) in enumerate(os)
            for (bi, b) in enumerate(bs)
                ntau = 41 + 10*bi
                Threads.@threads for ni in 1:length(ns)
                    n = ns[ni]
                    datafolder = @sprintf "complete_holstein_singleband_2D_w%.2f_l%.2f_n%.2f_L%d_b%.2f-1" o l n 14 b  
                    # println(datafolder)
                    if isdir(joinpath("simulations_rerun",datafolder)) && !isfile(joinpath("simulations_rerun",datafolder,"AC_data.jld2"))
                        G_k = zeros(Float64,(total_bins,ntau,length(ks)))
                        G_r = zeros(Float64,(total_bins,ntau))
                        curr = zeros(Float64,(total_bins,ntau))
                        
                        for walker in 0:nwalkers -1
                            fid = h5open(joinpath("simulations_rerun/",datafolder,"bins", "bins_pID-$(walker).h5"))
                            offset = walker * 100
                            for (ki,k) in enumerate(ks)
                                G_k[1+offset:100+offset,:,ki] = real.(fid["CORRELATIONS"]["STANDARD"]["TIME-DISPLACED"]["greens"]["MOMENTUM"][:,k[1],k[2],:,1])
                            end
                            G_r[1+offset:100+offset,:] = real.(fid["CORRELATIONS"]["STANDARD"]["TIME-DISPLACED"]["greens"]["POSITION"][:,1,1,:,1])
                            curr[1+offset:100+offset,:] = real.(fid["CORRELATIONS"]["STANDARD"]["TIME-DISPLACED"]["current"]["MOMENTUM"][:,1,1,:,1])
                            close(fid) 
                        end
                        
                        dict = Dict{String,Any}("G_k"=>G_k, "G_r" => G_r, "curr" => curr)
                        save(joinpath("simulations_rerun",datafolder,"AC_data.jld2"),dict)
                        for walker in 0:nwalkers -1
                            rm(joinpath("simulations_rerun/",datafolder,"bins", "bins_pID-$(walker).h5"))
                            rm(joinpath("simulations_rerun/",datafolder,"checkpoint_pID-$(walker).jld2"))
                        end
                        println(datafolder)
                        # exit()
                    end
                    
                end # ns
            end # bs
        end # os
    end # ls
                        

end # clean()

clean()