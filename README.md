# publicgames
 Monte carlo simulation with/without punishment for (single,multiple) public goods game with N players. The MC simulation uses Metropolis algorithm and errors are estimated using integrated correlation time.
  

## Usage
```julia
 julia main.jl -n number_of_players -b profit -c costs -p punishment -mc montecarlo_steps --path path
 ```
- data is stored under path/publicgames-...-.dat
- a gnufile is also provided to display the data


