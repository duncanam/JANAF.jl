module JANAF
using CSV # used for reading in JANAF tables 

# Export useful functions
export JanafDict, Cp, S, Hs, Hf, Gf, Kf

"""
    JanafDict(path,specie_array)

Read in each specie in `specie_array` located in
JANAF table folder `path`, and place tables into 
a dictionary in memory. 

Tables are in `.txt` format, downloaded each from:
https://janaf.nist.gov/ 

Standard reference states are at 298.15K and 0.1MPa. 

# Examples
Read in N2 and O2 JANAF JANAF tables:
```julia-repl
julia> path = "/my/absolute/path/";
julia> specie_array = ["N2","O2"];
julia> jd = JanafDict(path,specie_array);
```
"""
function JanafDict(path::String,specie_array::Array{String,1})
	# Initialize dictionary 
	jdict = Dict()

	# TODO 
	# Need to find a way to convert user-written inputs to 
	# the odd JANAF title format, i.e. N-023 vs N2. 

	# Loop through each specie 
	for specie in specie_array
		# Read in data, convert to array
		data = Array(CSV.read(path*specie*".txt",delim='\t',ignorerepeated=true,header=2))

		# Loop through thermo quantities
		for i=2:8
			# Convert "INFINITE" string and create numeric array 
			if data[1,i] == "INFINITE"
				data[1,i] = "1.0e12" # create "infinity" for interpolation 
				data[:,i] = parse.(Float64,data[:,i]) # convert strings to floats for vector
				
			end # end comparison if 
		end # end loop through thermo quantities

		# Typecast array to float 
		data = Float64.(data)

		# Place data into dictionary 
		jdict[specie] = data

	end # end specie loop

	# Return back parsed dictionary 
	return jdict
	
end # end JanafDict()

"""
	interp(table,T)

If `table` is a n x 2 table with `table[:,1]` containing 
temperatures and `table[:,2]` containing the property of 
interest, `interp(table,T)` will interpolate `table[:,2]` 
using the input `T` via a binary search and linear 
interpolation between the nearest bins in the table. 
"""
function interp(table::Array{Float64,2}, T::Number)
    low::Int64 = 1 # initialize low index
    high::Int64 = size(table,1) # initialize high index
    binlow::Int64 = low # Initialize low bin 
    binhigh::Int64 = high # Initilize high bin

    # Perform binary search:
    while low <= high
        mid = low + div((high-low),2) # find mid, integer divide

        # Check if T is at mid, then return exact value:
        if table[mid,1] == T
            return table[mid,2] 
        # Else if T>midpoint T, shift up low bound:
        elseif table[mid,1] < T 
            low = mid + 1
        # Else if T<midpoint T, shift down the upper bound:
        elseif table[mid,1] > T
            high = mid - 1
        end

        # Test for out of bounds
        if table[end,1] < T
            println("WARNING: Temperature $T is larger than bound $(table[end,1])!")
            return table[end,2]
        end

        # Test for negative temperatures
        T < 0 && error("Temperature error: cannot input negative temperatures!")

        # For last iteration where location is found, the
        #   high and low bounds cross and stop the loop.
        binlow = high # set high bound to the lower bin 
        binhigh = low # set low bound to the higher bin
    end 

	# Return linear interpolation between bins at desired temperature
    return table[binlow,2] + (table[binhigh,2] - table[binlow,2])/(table[binhigh,1] - table[binlow,1])*(T - table[binlow,1])

end # end interp()

"""
    Cp(jd,specie,T)

Specific heat of `specie` at constant pressure 
at `T` temperature in kelvin. Interpolates JanafDict
given as `jd`. Returns specific heat in J/K/mol.

# Example 
```julia-repl
julia> Cp(jd,"N2",405)
29.2628
```
"""
function Cp(jd,specie::String,T::Number)
	return interp(jd[specie][:,1:2],T)
end # end Cp()

"""
   S(jd,specie,T)

Entropy of `specie` at `T` temperature in kelvin. 
Interpolates JanafDict given as `jd`. Returns entropy 
in J/K/mol.

# Example 
```julia-repl
julia> S(jd,"N2",802)
221.0918
```
"""
function S(jd,specie::String,T::Number)
	return interp(jd[specie][:,1:2:3],T)
end # end S()

"""
   Hs(jd,specie,T)

Sensible enthalpy of `specie` at `T` temperature 
in kelvin. Interpolates JanafDict given as `jd`. 
Returns sensible enthalpy in kJ/mol. In JANAF 
table as H-H0(Tr). 

# Example 
```julia-repl
julia> Hs(jd,"N2",506)
6.08998
```
"""
function Hs(jd,specie::String,T::Number)
	return interp(jd[specie][:,1:4:5],T)
end # end Hs()

"""
   Hf(jd,specie,T)

Standard enthalpy of formation of `specie` at 
`T` temperature in kelvin. Interpolates 
JanafDict given as `jd`. Returns formation 
enthalpy in kJ/mol. In JANAF table as ΔfH0.

# Example 
```julia-repl
julia> Hf(jd,"H2O",802)
-245.9564
```
"""
function Hf(jd,specie::String,T::Number)
	return interp(jd[specie][:,1:5:6],T)
end # end Hf()

"""
   Gf(jd,specie,T)

Standard Gibbs free energy of formation of 
`specie` at `T` temperature in kelvin. 
Interpolates JanafDict given as `jd`. Returns 
formation enthalpy in kJ/mol. In JANAF table 
as ΔfG0.

# Example 
```julia-repl
julia> Gf(jd,"H2O",370)
-225.2807
```
"""
function Gf(jd,specie::String,T::Number)
	return interp(jd[specie][:,1:6:7],T)
end # end Gf()

"""
   Kf(jd,specie,T)

Equilibrium constant of `specie` at `T` 
temperature in kelvin. Interpolates JanafDict 
given as `jd`. Returns equilibrium constant in 
kJ/mol. In JANAF table as log(Kf), and this 
function returns Kf. 

# Example 
```julia-repl
julia> Kf(jd,"H2O",623)
8.506090518593942e17
```
"""
function Kf(jd,specie::String,T::Number)
	tmp = interp(jd[specie][:,1:7:8],T)
	return 10^tmp
end # end Kf()


end # module
