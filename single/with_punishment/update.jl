#-----------------------------------------
function init_config(n::Int64)
    return rand(0:1,n)
end
#-----------------------------------------
function neighbors(k::Int64,L::Int64)
    # returns the next-neighbors of k-th site
    # OBS: shift k  -> k - 1
    k_shifted = k -1
    kx = k_shifted % L
    ky = div(k_shifted,L)
    return [(kx+1)%L+ky*L,(kx-1+L)%L+ky*L,
            kx+((ky+1)%L)*L,kx+((ky-1+L)%L)*L]+1
end
#-----------------------------------------
function couplings(beta::Float64,N::Int,args...)
    b = args[1]
    c = args[2]
    gamma = args[3]
    ene = b - 2*c + b/N
    avg = 1.0/(1.0+exp(-beta*ene))
    coupling_1 = -ene+gamma*b*(1.0-avg*(N-1)/N)
    coupling_2 = -gamma*b/N
    return coupling_1,coupling_2
end
#-----------------------------------------
function generate(beta::Float64,k::Int64,
                  conf::Array{Int64,1},kwargs...)
    # public games with punishment
    # coupling_1     = kwargs[1]
    # coupling_2     = kwargs[2]
    old_  = conf[k]
    new_  = (old_+1)%2
    change= new_ - old_
    mag   = sum(conf)
    delta = kwargs[2]*(1+2*mag*change)+kwargs[1]*change
    trial = 1
    if delta > 0
        trial = Int(rand() < exp(-beta*delta))
    end
    return trial*new_ +(1-trial)*old_
end
#-----------------------------------------
