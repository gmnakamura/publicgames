#Pkg.add("ArgParse") #uncomment to install
using ArgParse
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
#-----------------------------------------
function parse()
    s = ArgParseSettings()
    @add_arg_table s begin
        "-n"
        help = "number of agents. default = 100"
        default = 100
        arg_type = Int
        "--steps","-s"
        default = 10000
        arg_type = Int
        help = "number of monte carlo steps. default = 100000"
        "-c","--cost"
        default = 0.30
        arg_type = Float64
        help = "base cost per game. default = 0.3"
        "--punishment","-p"
        default = 0.0
        arg_type = Float64
        help = "punishment rate. default = 0.0"
        "--beta-min"
        default = 0.0
        arg_type = Float64
        help = "minumum value of beta. default = 0.0 "
        "--beta-max"
        default = 5.0
        arg_type = Float64
        help = "maximum value of beta. default = 5.0 "
        "--beta-delta"
        default = 0.1
        arg_type = Float64
        help = "increment value of beta. default = 0.1 "
        "--folder","-f"
        default = "."
        help = "path to store data. default = ."
    end
    return parse_args(s)
end
