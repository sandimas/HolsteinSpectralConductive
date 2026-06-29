using FileIO
using JLD2
using CSV
using DataFrames
using Printf

function proxies()
    ##############################
    ## Change this to wherever you have the simulations stored
    #############################
    simulation_folder = "../simulations_rerun"


    ls = [0.125, 0.25, 0.3, 0.325, 0.35, 0.375, 0.4, 0.425, 0.45, 0.475, 0.5, 0.625, 0.75]
    bs = 5.0:1.0:20.0 |> collect
    os = 0.5:0.5:2.0 |> collect
    ns = 0.05:0.05:1.0 |> collect
    explain_meas = 
"This dictionary contains the directly measured quantities from our simulations. The keys are as follows:
\t\"mu\":\t\t\tThe measured chemical potential in shape (λ,n,Ω,β)
\t\"mu_err\":\t\tThe measured chemical potential error in shape (λ,n,Ω,β)
\t\"n\":\t\t\tThe measured ⟨n⟩ in shape (λ,n,Ω,β)
\t\"n_err\":\t\tThe measured ⟨n⟩ error in shape (λ,n,Ω,β)
\t\"spin_z\":\t\tThe measured S_s(0) in shape (λ,n,Ω,β)
\t\"spin_z_err\":\tThe measured S_s(0) error in shape (λ,n,Ω,β)
\t\"scdw\":\t\t\tThe measured S_c(Q_cdw) in shape (λ,n,Ω,β)
\t\"scdw_err\":\t\tThe measured S_c(Q_cdw) in shape (λ,n,Ω,β)
\t\"N0\":\t\t\tThe measured proxy for N(0), β/π*G(r=0,β/2) in shape (λ,n,Ω,β)
\t\"N0_err\":\t\tThe measured proxy for N(0), β/π*G(r=0,β/2) error in shape (λ,n,Ω,β)
\t\"sigma\":\t\tThe measured proxy for σ_dc, β^2/π*Λ(q=0,β/2) in shape (λ,n,Ω,β)
\t\"sigma_err\":\tThe measured proxy for σ_dc, β^2/π*Λ(q=0,β/2) error in shape (λ,n,Ω,β)
\t\"lambdas\":\t\tThe λ value for each λ index
\t\"ns\":\t\t\tThe ⟨n⟩ value for each ⟨n⟩ index
\t\"omegas\":\t\tThe Ω value for each Ω index
\t\"betas\":\t\tThe β value for each β index
\t\"description\":\tThis text
"
    
    if !isfile("../2_data/direct_measurements.jld2")
        println("new")
        proxy_sigma = zeros(Float64,(length(ls),length(ns),length(os),length(bs),))
        proxy_sigma_err = zeros(Float64,(length(ls),length(ns),length(os),length(bs),))
        
        proxy_N0 = zeros(Float64,(length(ls),length(ns),length(os),length(bs),))
        proxy_N0_err = zeros(Float64,(length(ls),length(ns),length(os),length(bs),))
        avg_n =  zeros(Float64,(length(ls),length(ns),length(os),length(bs),))
        avg_n_err =  zeros(Float64,(length(ls),length(ns),length(os),length(bs),))
        mu =  zeros(Float64,(length(ls),length(ns),length(os),length(bs),))
        mu_err =  zeros(Float64,(length(ls),length(ns),length(os),length(bs),))
        spin_z =  zeros(Float64,(length(ls),length(ns),length(os),length(bs),))
        spin_z_err =  zeros(Float64,(length(ls),length(ns),length(os),length(bs),))
        scdw =  zeros(Float64,(length(ls),length(ns),length(os),length(bs),))
        scdw_err =  zeros(Float64,(length(ls),length(ns),length(os),length(bs),))
        spin_z_pos =  zeros(Float64,(length(ls),length(ns),length(os),length(bs),))
        spin_z_pos_err =  zeros(Float64,(length(ls),length(ns),length(os),length(bs),))
        
        dict_out = Dict{String,Any}(
            "sigma" => proxy_sigma,
            "sigma_err" => proxy_sigma_err,
            "N0" => proxy_N0,
            "N0_err" => proxy_N0_err,
            "spin_z" => spin_z,
            "spin_z_err" => spin_z_err,
            "scdw" => scdw,
            "scdw_err" => scdw_err,
            "spin_z_pos" => spin_z_pos,
            "spin_z_pos_err" => spin_z_pos_err,
            "mu" => mu,
            "mu_err" => mu_err,
            "n" => avg_n,
            "n_err" => avg_n_err,
            "lambdas" => ls,
            "ns" => ns,
            "omegas" => os,
            "betas" => bs,
            "description" => explain_meas
            
        )
        save("../2_data/direct_measurements.jld2", dict_out)
        
        
    else
        
        dict = load("../2_data/direct_measurements.jld2")
        proxy_sigma = dict["sigma"]
        proxy_sigma_err = dict["sigma_err"]
        proxy_N0 = dict["N0"]
        proxy_N0_err = dict["N0_err"]
        avg_n = dict["n"]
        avg_n_err = dict["n_err"]
        spin_z = dict["spin_z"]
        spin_z_err = dict["spin_z_err"]
        spin_z_pos = dict["spin_z_pos"]
        spin_z_pos_err = dict["spin_z_pos_err"]
        scdw = dict["scdw"]
        scdw_err = dict["scdw_err"]
        mu = dict["mu"]
        mu_err = dict["mu_err"]
    end
    
    for (li, l) in enumerate(ls)
        for (oi, o) in enumerate(os)
            for (bi, b) in enumerate(bs)
                ntau = 41 + 10 * bi
                midtau = 21 + 5 * bi
                midpos = midtau * 14 * 14 + 1
                midpos_pi_pi = midpos + 105
                
                Threads.@threads for ni in 1:length(ns)
                    n = ns[ni]
                    datafolder = @sprintf "complete_holstein_singleband_2D_w%.2f_l%.2f_n%.2f_L%d_b%.2f-1" o l n 14 b  
                    if isdir(joinpath(simulation_folder,datafolder)) && avg_n[li,ni,oi,bi] == 0.0
                        println(datafolder)
                        file = joinpath(simulation_folder,datafolder,"global_stats.csv")
                        df = CSV.read(file, DataFrame)
                        avg_n[li,ni,oi,bi] = df[7,:]["MEAN_REAL"]
                        avg_n_err[li,ni,oi,bi] = df[7,:]["STD"]
                        mu[li,ni,oi,bi] = df[5,:]["MEAN_REAL"]
                        mu_err[li,ni,oi,bi] = df[5,:]["STD"]

                        file = joinpath(simulation_folder,datafolder,"time-displaced/current/current_momentum_time-displaced_stats.csv")
                        df = CSV.read(file, DataFrame)
                        proxy_sigma[li,ni,oi,bi] = df[midpos,:]["MEAN_REAL"] * b * b / pi
                        proxy_sigma_err[li,ni,oi,bi] = df[midpos,:]["STD"] * b * b / pi

                        file = joinpath(simulation_folder,datafolder,"time-displaced/density/density_momentum_time-displaced_stats.csv")
                        df = CSV.read(file, DataFrame)
                        scdw[li,ni,oi,bi] = df[106,:]["MEAN_REAL"] 
                        scdw_err[li,ni,oi,bi] = df[106,:]["STD"]

                        file = joinpath(simulation_folder,datafolder,"time-displaced/greens/greens_position_time-displaced_stats.csv")
                        df = CSV.read(file, DataFrame)
                        proxy_N0[li,ni,oi,bi] = df[midpos,:]["MEAN_REAL"] * b / pi
                        proxy_N0_err[li,ni,oi,bi] = df[midpos,:]["STD"] * b / pi

                        file = joinpath(simulation_folder,datafolder,"time-displaced/spin_z/spin_z_momentum_time-displaced_stats.csv")
                        df = CSV.read(file, DataFrame)
                        spin_z[li,ni,oi,bi] = df[1,:]["MEAN_REAL"] 
                        spin_z_err[li,ni,oi,bi] = df[1,:]["STD"]
                        
                        file = joinpath(simulation_folder,datafolder,"time-displaced/spin_z/spin_z_position_time-displaced_stats.csv")
                        df = CSV.read(file, DataFrame)
                        spin_z_pos[li,ni,oi,bi] = df[1,:]["MEAN_REAL"] 
                        spin_z_pos_err[li,ni,oi,bi] = df[1,:]["STD"]
                        
                        
                    else
                        println("skip $(datafolder)")
                    end # if isdir
                end # ns
                dict_out = Dict{String,Any}(
                    "sigma" => proxy_sigma,
                    "sigma_err" => proxy_sigma_err,
                    "N0" => proxy_N0,
                    "N0_err" => proxy_N0_err,
                    "avg_n" => avg_n,
                    "avg_n_err" => avg_n_err,
                    "spin_z" => spin_z,
                    "spin_z_err" => spin_z_err,
                    "spin_z_pos" => spin_z_pos,
                    "spin_z_pos_err" => spin_z_pos_err,
                    "scdw" => scdw,
                    "scdw_err" => scdw_err,
                    "mu" => mu,
                    "mu_err" => mu_err,
                )
                save("../2_data/direct_measurements.jld2", dict_out)
            end # bs
            
    
        end # os
        
    end # ls
                
end
proxies()

    
