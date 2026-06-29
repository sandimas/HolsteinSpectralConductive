using FileIO
using JLD2
using Printf

function DOS_N0()
    ls = [0.125, 0.25, 0.3, 0.325, 0.35, 0.375, 0.4, 0.425, 0.45, 0.475, 0.5, 0.625, 0.75]
    bs = 5.0:1.0:20.0 |> collect
    os = 0.5:0.5:2.0 |> collect
    ns = 0.05:0.05:1.0 |> collect
    	explain_dos = "This dictionary contains the DEAC-derived densities of states of our simulations. 
The keys are as follows:
\t\"DOS\":\t\t\tThe DOS data in shape (λ,n,Ω,β,ω)
\t\"ws\":\t\t\tThe ωs for each point given by LinRange(-15.0,15.0,601)
\t\"lambdas\":\t\tThe λ value for each λ index
\t\"ns\":\t\t\tThe ⟨n⟩ value for each ⟨n⟩ index
\t\"omegas\":\t\tThe Ω value for each Ω index
\t\"betas\":\t\tThe β value for each β index
\t\"description\":\tThis text
		"
    
    nw = 601
    ws = collect(LinRange(-15.0,15.0,601))
    
    

    for (li, l) in enumerate(ls)
        for (oi, o) in enumerate(os)
            for (bi, b) in enumerate(bs)
                Threads.@threads for ni in 1:length(ns)
                    n = ns[ni]
                    
                    datafile = @sprintf "../3_run_AC/DOS/complete_holstein_singleband_2D_w%.2f_l%.2f_n%.2f_L%d_b%.2f-1.jld2" o l n 14 b  
                    
                    if isfile(datafile)
                        DOS[li,ni,oi,bi,:] = load(datafile)["A"][:,end]
                        
                    end
                    
                end
                
                save("../../2_data/DOS.jld2",Dict{String,Any}("DOS" => DOS, "ws" => ws, "lambdas" => ls, "ns" => ns, "omegas" => os, "betas" => bs, "description" => explain_dos))
            end
        end
    end
    
    
    
end

DOS_N0()