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
function generate(beta::Float64,conf::Int64,kwargs...)
    # public games without punishment
    #b  = kwargs[1]
    #c  = kwargs[2]
    #mu = kwargs[3]
    new_conf = (conf+1)%2
    coupling = -(kwargs[1]-kwargs[2]-kwargs[3])
    delta    = coupling*( new_conf - conf )
    trial    = 1
    if delta > 0
        trial = Int(rand() < exp(-beta*delta))
    end
    return new_conf*trial +(1-trial)*conf
end
#-----------------------------------------
