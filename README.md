# JANAF.jl
*A Julia interface for NIST-JANAF Thermochemical Tables*

JANAF.jl is a Julia package to assist with thermochemical property lookup. It loads downloaded JANAF tables into memory for easy access and provides functions for interpolating these tables. JANAF.jl requires:
* user-downloaded JANAF tables as outlined in the installation section
* **gaseous tables only**, as mixed-phase tables have artifacts I have not attempted to tackle yet

I welcome pull requests and assistance from people who may actually use this, as this primarily came out of a need during a homework assignment. It is not polished. 

## Installation 
* Install JANAF.jl with:
```julia
using Pkg
Pkg.clone("https://github.com/duncanam/JANAF.jl.git")
```
* Next, go to [https://janaf.nist.gov/](https://janaf.nist.gov/) and find the desired gas(es) you'd like to work with, such as [gaseous water](https://janaf.nist.gov/tables/H-064.html). 
* Scroll to the bottom of the page and right click the "Download table" button, and select "Save Link As..." and save the table to the desired JANAF folder that will contain all the tables. This is only needed once per new specie. 
* Now, rename the table for your liking for easy access (e.g. "H-064.txt" to "H2O.txt"). 

## Usage

### Importing JANAF Tables
This package provides several functions. The first and foremost being a function to return a dictionary containing all the specie properties:
```julia
jd = JanafDict(path,specie_list)
```
where 
* `path` is the path to the user-defined directory containing all the downloaded JANAF tables 
* `specie_list` is a `String` array containing the names of the files that will be loaded 

### Operating on the Imported JANAF Tables
JANAF.jl also provides interpolation functions to return values at a desired temperature in K units. These functions include:
* `Cp(jd,specie,T)` : Specific heat of `specie` at constant pressure at `T` temperature in kelvin. Interpolates JanafDict given as `jd`. Returns specific heat in J/K/mol.
* `S(jd,specie,T)` : Entropy of `specie` at `T` temperature in kelvin. Interpolates JanafDict given as `jd`. Returns entropy in J/K/mol.
* `Hs(jd,specie,T)` : Sensible enthalpy of `specie` at `T` temperature in kelvin. Interpolates JanafDict given as `jd`. Returns sensible enthalpy in kJ/mol. In JANAF table as H-H0(Tr). 
* `Hf(jd,specie,T)` : Standard enthalpy of formation of `specie` at `T` temperature in kelvin. Interpolates  JanafDict given as `jd`. Returns formation enthalpy in kJ/mol. In JANAF table as ΔfH0.
* `Gf(jd,specie,T)` : Standard Gibbs free energy of formation of `specie` at `T` temperature in kelvin. Interpolates JanafDict given as `jd`. Returns formation enthalpy in kJ/mol. In JANAF table as ΔfG0.
* `Kf(jd,specie,T)` : Equilibrium constant of `specie` at `T` temperature in kelvin. Interpolates JanafDict given as `jd`. Returns equilibrium constant in kJ/mol. In JANAF table as log(Kf), and this function returns Kf. 

### Example
Here is an example of usage:
```julia
# Define path to directory of JANAF tables
path = "/home/user/janaf/"

# Define desired species in path, named as:
#   N2.txt
#   H2O.txt
species_list = ["N2","H2O"]

# Define JANAF dictionary 
jd = JanafDictionary(path,species_list)

# Grab specific heat of water at a desired
#   temperature, T = 457.2 K
result = Cp(jd,"H2O",457.2)
```

## Things To Improve and Add
* Create an interface to automatically retrieve JANAF tables from online and download them into a user-defined location
* Add the capability to parse more than just gaseous tables

## References 
This package references NIST's JANAF thermochemical tables provided at [https://janaf.nist.gov/](https://janaf.nist.gov/). Table rights belong to them, and credits can be found [HERE](https://janaf.nist.gov/janbanr.html).
