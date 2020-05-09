module JANAF
using CSV # used for reading in JANAF tables 


greet() = print("Hello World!")

"""
Read in function
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
		data = Array(CSV.read(path,delim='\t',ignorerepeated=true,header=2))

		# Convert "INFINITE" string and create numeric array 
		data[1,4] = "1.0e12" # create "infinity" for interpolation 
		data[:,4] = parse.(Float64,data[:,4]) # convert strings to floats for vector

		# Typecast array to float 
		data = Float64.(data)

		# Place data into dictionary 
		jdict[specie] = data

	end # end specie loop
	
end # end JanafDict()

end # module
