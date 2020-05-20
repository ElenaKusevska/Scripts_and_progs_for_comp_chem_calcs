# Script to fit dissociation data to Morse curve

import numpy
import scipy
import matplotlib
import matplotlib.pyplot
from scipy import optimize

# Function to fit:
def morse_curve(Rf, kf, Def, Ref):
    E = Def * ( numpy.exp(-2.0*numpy.sqrt(kf/Def)*(Rf-Ref)) - 2.0*numpy.exp(-numpy.sqrt(kf/Def)*(Rf-Ref)) )
    return E

# Get dissociation data points:
datafile = open('example_input.dat', 'r')
lines_in_datafile = datafile.readlines()
r_data = numpy.array([])
E_data = numpy.array([])
for i in range(0,len(lines_in_datafile)):
    words_in_line = lines_in_datafile[i].split()
    print(words_in_line)
    r = float(words_in_line[0]) # Angstrom
    E = float(words_in_line[1])*627.5 # kcal/mol
    r_data = numpy.append(r_data,r) # Angstrom
    E_data = numpy.append(E_data,E)

# Shift dissociation data so that energy is 0 at last term
for i in range(0, E_data.size):
    E_data[i] = E_data[i] - E_data[-1]

# Print test:
print(r_data)
print(E_data)

# Determine equilibrium radius and dissociation energy
Re = r_data[numpy.argmin(E_data)]
De = E_data[-1] - numpy.amin(E_data)
print("Re: ", Re, "De: ", De)

# Use lambda function to fix known parameters (Re and De):
morse_curve_fit_k = lambda Rl, kl: morse_curve(Rl, kl, De, Re)

# Fit for k, using known values of Re and De:
popta, pcoca = scipy.optimize.curve_fit(morse_curve_fit_k, r_data, E_data)
print("popta: ", popta)

# Fit for k, Re, and De, using values from previous calculation
# as initial guess:
poptb, pcocb = scipy.optimize.curve_fit(morse_curve, r_data, E_data, p0=[popta[0], De, Re])
print("poptb: ", poptb)

# Plot the result:
matplotlib.pyplot.scatter(r_data, E_data, facecolors='none', edgecolors='k')
matplotlib.pyplot.plot(r_data, morse_curve(r_data, popta[0], De, Re), 'b')
matplotlib.pyplot.plot(r_data, morse_curve(r_data, poptb[0], poptb[1], poptb[2]), 'r')
matplotlib.pyplot.show()
