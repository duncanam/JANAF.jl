module JANAF
using CSV # used for reading in JANAF tables 

# Export useful functions
export JanafDict

"""
    JanafDict(path,specie_array)

Read in each specie in `specie_array` located in
JANAF table folder `path`, and place tables into 
a dictionary in memory. 

Tables are in `.txt` format, downloaded each from:
https://janaf.nist.gov/ 

# Examples
Read in N2 and O2 JANAF JANAF tables:
```julia-repl
julia> path = "/my/absolute/path/";
julia> specie_array = ["N2","O2"];
julia> jd = JanafDict(path,specie_array);
```
"""
function JanafDict(path::String,specie_array)
	# Initialize dictionary 
	jdict = Dict()

	# TODO 
	# Need to find a way to convert user-written inputs to 
	# the odd JANAF format, i.e. N-023 vs N2. 

	# Loop through each specie 
	for specie in specie_array
		# Read in data, convert to array
		data = Array(CSV.read(path*specie*".txt",delim='\t',ignorerepeated=true,header=2))

		# Convert "INFINITE" string and create numeric array 
		data[1,4] = "1.0e12" # create "infinity" for interpolation 
		data[:,4] = parse.(Float64,data[:,4]) # convert strings to floats for vector

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

end 


end # module
