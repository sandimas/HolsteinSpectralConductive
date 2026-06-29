using FileIO
using PyCall
using JLD2
using Printf
using Statistics


function gauss(x, x0, σ)
    return @. 2.0*exp(-(x - x0)^2 / (2 * σ^2)) / (sqrt(2 * π) * σ)
end

function do_AC()
    
    outdir = "../data_jld2s"
    filename = "cond.jld2"
    cfile = joinpath(outdir,filename)
    cfile_bak = joinpath(outdir,"cond_bak.jld2")
    mkpath(outdir)
    
    ls = [0.125, 0.25, 0.3, 0.325, 0.35, 0.375, 0.4, 0.425, 0.45, 0.475, 0.5, 0.625, 0.75]
    bs = 5.0:1.0:20.0 |> collect
    os = 0.5:0.5:2.0 |> collect
    ns = 0.05:0.05:1.0 |> collect
    
    np = pyimport("numpy")
    cont = pyimport("ana_cont.continuation")
    solvers = pyimport("ana_cont.solvers")

    
    if isfile(cfile)
        dict = load(cfile)
        ws = dict["ws"]   
        cond = dict["cond"]    
        
    else
        ws = collect(LinRange(0.0,20.0,1001))
        cond = zeros(Float64,(length(ls),length(ns),length(os),length(bs),1001))
        cond .= -1.0
        save(cfile, Dict{String,Any}("ws"=>ws,"cond"=>cond))
        
    end
    
    for (li, l) in enumerate(ls)
        for (oi, o) in enumerate(os) 
            for (bi, b) in enumerate(bs)
                ntau = 41 + 10 * bi
                ntau_2 =(ntau +1) >> 1
                taus = collect(LinRange(0.0,b,ntau))
                Threads.@threads for ni in 1:length(ns)
                    n = ns[ni]
                    folder = @sprintf "complete_holstein_singleband_2D_w%.2f_l%.2f_n%.2f_L%d_b%.2f-1"  o l n 14 b  
                    input_file = "../simulations_rerun/$(folder)/AC_data.jld2"
                    if cond[li,ni,oi,bi,1] == -1.0 && isfile(input_file)
                    
                        println(folder)
                        try
                            curr = load(input_file)["curr"][:,1:ntau_2]
                            taus_2 = taus[1:ntau_2]
                            covar = Statistics.cov(curr)
                            curr_avg = mean(curr, dims=1)[1,:]
                            
                            println(input_file)
                            probl = cont.AnalyticContinuationProblem( im_axis = taus_2, re_axis = ws, im_data = curr_avg, kernel_mode="time_bosonic", beta = b)
                            
                            try
                                sol, _ = probl.solve(method="maxent_svd", alpha_determination="chi2kink", cov=covar, model=gauss(ws, 0.0, 3.0),alpha_start=1e12,alpha_end=1e1)#, optimizer="scipy_lm")
                            
                                cond[li,ni,oi,bi,:] = sol.A_opt
                            catch e
                                try
                                    sol, _ = probl.solve(method="maxent_svd", alpha_determination="chi2kink", cov=covar, model=gauss(ws, 0.0, 3.0),alpha_start=1e12,alpha_end=1e-2, optimizer="scipy_lm")
                            
                                cond[li,ni,oi,bi,:] = sol.A_opt
                                catch e
                                    println(e)
                                end
                                
                            end
                        catch
                        end
                        mv(cfile,cfile_bak,force=true)
                        save(cfile, Dict{String,Any}("ws"=>ws,"cond"=>cond))        
                    end # if
                    
                end # ns
                
            end # bs  
            
        end # os
    end # ls
            

end

do_AC()