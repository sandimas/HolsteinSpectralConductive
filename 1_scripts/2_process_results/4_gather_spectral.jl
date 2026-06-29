using FileIO
using JLD2
using Printf

function spectral()
    ls = [0.125, 0.25, 0.3, 0.325, 0.35, 0.375, 0.4, 0.425, 0.45, 0.475, 0.5, 0.625, 0.75]
    bs = 5.0:1.0:20.0 |> collect
    os = 0.5:0.5:2.0 |> collect
    ns = 0.05:0.05:1.0 |> collect
    explain = "This dictionary contains the DEAC-derived spectral functions of our simulations along high symmetry cuts. Γ→X→M→Γ for respective k points (1,8,15,22). 
The keys are as follows:
\t\"A\":\t\t\tThe spectral data in shape (λ,n,Ω,β,k,ω)
\t\"ws\":\t\t\tThe ωs for each point given by LinRange(-15.0,15.0,601)
\t\"lambdas\":\t\tThe λ value for each λ index
\t\"ns\":\t\t\tThe ⟨n⟩ value for each ⟨n⟩ index
\t\"omegas\":\t\tThe Ω value for each Ω index
\t\"betas\":\t\tThe β value for each β index
\t\"description\":\tThis text
		"
    
    nk = 21
    ws = collect(LinRange(-15.0,15.0,601))
    nw = 601

    spec = zeros(Float64,(length(ls),length(ns),length(os),length(bs),nk+1,nw))
    
    for (li, l) in enumerate(ls)
        for (oi, o) in enumerate(os)
            for (bi, b) in enumerate(bs)
                Threads.@threads for ni in 1:length(ns)
                    n = ns[ni]
                    datafile = @sprintf "../AC_output/spec/complete_holstein_singleband_2D_w%.2f_l%.2f_n%.2f_L%d_b%.2f_spec-1.jld2" o l n 14 b
                    
                    if isfile(datafile)
                        dict = load(datafile)
                        if !haskey(dict,"fitness")
                            spec[li,ni,oi,bi,1:21,:] = dict["A"]
                            spec[li,ni,oi,bi,end,:] = spec[li,ni,oi,bi,1,:]
                            println(datafile)
                        end
                    end
                    
                    
                    
                    
                end
            end
        end
    end
    
    save("../../2_data/spectral_functions.jld2",Dict{String,Any}("A" => spec, "lambdas" => ls, "omegas" => os, "betas" => bs, "ns" => ns, "ws" => ws))
    
end

spectral()
