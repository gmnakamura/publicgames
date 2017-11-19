
#module data_analysis
# Pkg.add("Polynomials")
using Polynomials
#-----------------------------------------
function autocorrelation(data)
    # returns the autocorrelation of the data
    n = div(length(data),2)
    y = fft(data)
    z = real((ifft(y.*conj(y)))[1:n])/length(y)
    return (z -mean(data)^2)/(var(data)+1e-12)
end
#-----------------------------------------
function autocorrelation_time(data; size=20)
    # c(t) ~ exp(t/tau)
    value  = 1
    y      = log(autocorrelation(data)[1:size])
    #y      = log(abs(autocorrelation(data)[1:size]))
    coeffs = Polynomials.coeffs( Polynomials.polyfit(1:size,y,1))
    if abs(coeffs[end]) > 0
        value = -round(Int64,1.0/coeffs[end])
    end
    return value
end
#-----------------------------------------
function autocorrelation_time_integrated(data)
    # tau_int = (1/2) + sum_{i=1}^{\infty} corr[i]
    y = autocorrelation(data)
    # y[0] is always 1
    return max(0.5 + (sum(y) - 1.0),1)
end
#-----------------------------------------
function discard_correlated_data(data; multiplier=3)
    tau = autocorrelation_time(data)
    return data[multiplier*tau:end],tau
end
#-----------------------------------------
function sampling(data; mode="correlated")
    # sampling with correlated data using
    # integrated_autocorrelation_time
    if mode == "correlated"
        integrated_time = autocorrelation_time_integrated(data)
        error = sqrt(var(data)*(1.0+2.0*integrated_time))
        avg   = mean(data)
    else
        # sampling with uncorrelated data
        tau = autocorrelation_time(data)
        uncorr_data = data[1:tau:end]
        avg   = mean(uncorr_data)
        error = sqrt(var(uncorr_data))
    end
    return avg,error # *1.96
end
#-----------------------------------------
function write_data(path, betas, data , error)
    # write data and error...
    writedlm(path,zip(betas,data,error))
    # write gnuplot file
    gnufilename=string(path[1:end-3],"gnu")
    f0,f1 = splitdir(path)
    #texfilename=string(f1[1:end-3],"tex")
    #texfiles are pick concering dots...
    texfilename=string(replace(f1,".",""),".tex")
    open(gnufilename,"w") do f
        write(f,"#!/usr/bin/gnuplot \n")
        write(f,"set terminal epslatex standalone color 12\n")
        write(f,"set output '$texfilename'\n")
        write(f,"set style fill transparent solid 0.25 \n")
        write(f,"set xlabel '\$\\beta\$'\n")
        write(f,"set ylabel '\$n\$' \n")
        write(f,"plot '$f1' u 1:(\$2-\$3):(\$2+\$3) w filledcurves lc 1 notitle, '' u 1:2 w linespoints pt 7 lc 1 notitle  \n")
    end
end
#end #end module
