#!/usr/bin/julia

# public goods without punishment
# single game (N by N)

include("update.jl")
include("data_analysis.jl")
include("helper.jl")

function main(betas::Array{Float64,1},N::Int,
              montecarlo_steps::Int,args...)
    # args[1] = b   # b =  profit
    # args[2] = c   # c =  costs
    # mu = cooperation risk

    # b, c, mu 
    couplings=(args[1],args[2],args[2]-args[1]/N)
    avg=zeros(length(betas))
    err=zeros(length(betas))

    conf = init_config(N)
    for enum_beta in enumerate(betas)
        beta_step = enum_beta[1]
        beta      = enum_beta[2]
        stat=zeros(montecarlo_steps)
        for step in 1:montecarlo_steps
            k          = rand(1:N)
            conf[k]    = generate(beta,conf[k],couplings...)
            stat[step] = mean(conf)
        end
        data,tau = discard_correlated_data(stat)
        avg[beta_step],err[beta_step] = sampling(data)
    end
    return avg,err
end
#------------------------------------------
# N=100 # read from cmd line
# montecarlo_steps = 10*N*N # read from cmd line
# b = 1.0  # read from cmd line
# c = 0.35 # read from cmd line
# folder ="data" # read from cmd line
# betas = collect(0:0.1:5)

args = parse()
N                = args["n"]
b                = 1.0
c                = args["cost"]
montecarlo_steps = args["steps"]
beta_min         = args["beta-min"]
beta_max         = args["beta-max"]
beta_delta       = args["beta-delta"]
folder           = args["folder"]
betas = collect(beta_min:beta_delta:beta_max)


f = open("log_performance.dat","a")
#for c in float([0.0,0.1,0.2,0.5,1.0,2.0,4.0,8.0])
t = @elapsed data,err=main(betas,N,montecarlo_steps,b,c)
write(f,"$N $montecarlo_steps $c $t \n")
path=joinpath(folder,"publicgames-singlegame-N$N-MC$montecarlo_steps-c$c.dat")
write_data(path,betas,data,err)
#end

close(f)

