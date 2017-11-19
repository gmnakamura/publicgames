#!/usr/bin/julia

# public goods without punishment
# single game (N by N)

include("update.jl")
include("data_analysis.jl")

function main(N::Int,montecarlo_steps::Int,betas::Array{Float64,1},
              args...)
    # args[1] = b
    # args[2] = c

    # b, c, mu
    couplings=(args[1],args[2],args[2]-args[1]/N)
    #betas=[beta_min:beta_delta:beta_max]
    avg=zeros(length(betas))
    err=zeros(length(betas))

    conf = init_config(N)
    for enum_beta in enumerate(betas)
        beta_step = enum_beta[1]
        beta      = enum_beta[2]
        stat=zeros(montecarlo_steps)
        for step in 1:montecarlo_steps
            k = rand(1:N)
            conf[k]    = generate(beta,conf[k],couplings...)
            stat[step] = mean(conf)
        end
        data,tau = discard_correlated_data(stat)
        avg[beta_step],err[beta_step] = sampling(data)
    end
    return avg,err
end
#------------------------------------------
N=100 # read from cmd line
montecarlo_steps = 10*N*N # read from cmd line
b = 1.0  # read from cmd line
c = 0.35 # read from cmd line
folder ="data" # read from cmd line


betas = collect(0:0.1:5)
#for c in float([0.0,0.1,0.2,0.5,1.0,2.0,4.0,8.0])
data,err=main(N,montecarlo_steps,betas,b,c)
path=joinpath(folder,"publicgames-singlegame-N$N-MC$montecarlo_steps-c$c.dat")
write_data(path,betas,data,err)
#end
