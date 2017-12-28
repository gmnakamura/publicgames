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
    # args[3] = gamma # =  punishment

    #
    # number of statistical moments
    #
    num_statistical_moments = 4
    
    num_betas        = length(betas)
    correlation_time = zeros(num_betas)
    moments          = zeros(num_betas,2*num_statistical_moments)
    #
    # even columns in 'moments' are the statistical moments
    # odd  columns in 'moments' are the std deviation
    # EX:
    #    moments[:,k  ] = k-th moment
    #    moments[:,k+1] = stddev of moment[:,k]
    #
    conf = init_config(N)
    for enum_beta in enumerate(betas)
        beta_step = enum_beta[1]
        beta      = enum_beta[2]
        coups= couplings(beta,N,args...)        
        stat=zeros(montecarlo_steps)
        for step in 1:montecarlo_steps
            k          = rand(1:N)
            conf[k]    = generate(beta,k,conf,coups...)
            stat[step] = mean(conf)
        end
        data,tau = discard_correlated_data(stat)
        correlation_time[beta_step] = tau
        for k_ in 1:2:2*num_statistical_moments
            #
            # line below wont work in v.0.4.7 julia
            #
            # moments[beta_step,k_], moments[beta_step,k_ +1] = sampling(data)

            #
            # workaround... 
            #
            avg,err = sampling(data)
            moments[beta_step,k_]  = avg
            moments[beta_step,k_+1]= err
            #
            # proceed to next moment, update data
            #
            data = data .* data
        end        
    end
    return correlation_time,moments
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
punishment       = args["punishment"]
montecarlo_steps = args["steps"]
beta_min         = args["beta-min"]
beta_max         = args["beta-max"]
beta_delta       = args["beta-delta"]
folder           = args["folder"]
betas = collect(beta_min:beta_delta:beta_max)


f = open("log_performance.dat","a")
#for c in float([0.0,0.1,0.2,0.5,1.0,2.0,4.0,8.0])
t = @elapsed tau,data=main(betas,N,montecarlo_steps,b,c,punishment)
write(f,"$N $montecarlo_steps $c $t \n")
path=joinpath(folder,"publicgames-singlegame-N$N-MC$montecarlo_steps-c$c-p$punishment.dat")
write_data(path,[betas data tau])
#end

close(f)

