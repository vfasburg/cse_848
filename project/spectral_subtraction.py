import array, random, numpy, wave
from scipy.fftpack import rfft, irfft
from scipy.io import wavfile # get the api
# from deap import creator, base, tools, algorithms

# creator.create("FitnessMax", base.Fitness, weights=(1.0,))
# creator.create("Individual", array.array, typecode='b', fitness=creator.FitnessMax)

# toolbox = base.Toolbox()

# toolbox.register("attr_bool", random.randint, 0, 1)
# toolbox.register("individual", tools.initRepeat, creator.Individual, toolbox.attr_bool, 100)
# toolbox.register("population", tools.initRepeat, list, toolbox.individual)

# def evalOneMax(individual):
    # return sum(individual),

# toolbox.register("evaluate", evalOneMax)
# toolbox.register("mate", tools.cxTwoPoint)
# toolbox.register("mutate", tools.mutFlipBit, indpb=0.05)
# toolbox.register("select", tools.selTournament, tournsize=3)

#get test file data
binMinimums = [0, 1.93069772888325, 2.68269579527973, 3.72759372031494, 5.17947467923121, 7.19685673001152, 10, 13.8949549437314, 19.3069772888325, 26.8269579527973, 37.2759372031494, 51.7947467923121, 71.9685673001152, 100, 138.949549437314, 193.069772888325, 268.269579527972, 372.759372031494, 517.947467923121, 719.685673001152, 1000, 1389.49549437314, 1930.69772888325, 2682.69579527972, 3727.59372031494, 5179.47467923121, 7196.85673001152, 10000, 13894.9549437314, 19306.9772888325, 26826.9579527973, 37275.9372031494, 51794.7467923121, 71968.5673001151, 100000, 138949.549437314, 193069.772888325, 268269.579527973, 372759.372031494, 517947.467923121, 719685.673001151, 1000000, 1389495.49437314, 1930697.72888325, 2682695.79527973, 3727593.72031494, 5179474.67923121, 7196856.73001151]
def getBin(energy):
	i = 0
	# print energy
	while energy > binMinimums[i]:
		i += 1
	# print i - 1
	return i - 1
fs, data = wavfile.read(r".\audio\I_am_sitting_dirty.wav")

N = 512
start = 0
end = N
ham = numpy.hamming(N)
xnew = numpy.zeros(data.size)
# set up histogram
bins = 50
erosion = 0.05 #makes histogram favor new values
histogram = numpy.zeros((N, bins))
noiseEnergy = numpy.zeros(N)
while(end < data.size):
	#window time domain data & get fft
	x = data[start:end] * ham
	freq = rfft(x)
	# print max(freq)
	# update the histogram
	histogram = histogram * erosion
	# first & last freqs in freq aren't real
	for f in range(1, N-1):
		binnum = getBin(abs(freq[f]))
		histogram[f][binnum] += 1
		curmax = 0
		maxbin = 0
		for curbin in range(0,bins): #search for bin index w maximum value
			if(histogram[f][curbin] > curmax):
				curmax = histogram[f][curbin]
				maxbin = curbin
		# get energy associated with most used bin
		# if f % 50 == 0:
			# print "maxbin %i freq %i", maxbin, f
		noiseEnergy[f] = binMinimums[maxbin]
	# subtract estimated noise energy
	freq = freq * (abs(freq) - noiseEnergy)/abs(freq)
	freq[abs(freq)<0] = 0
	xnew[start:end] += irfft(freq)

	# use 50% overlap and add ifft output
	end += N/2
	start += N/2

wavfile.write(r".\audio\I_am_sitting_processed.wav", fs, xnew.astype(numpy.int16))

#dirty = wave.open(r"C:\Users\Vince\Documents\School\MSU\2015_Fall\CSE848\Audio\I_am_sitting_dirty.wav")
#print(dirty.getframerate())
#print(dirty.readframes(4))

# population = toolbox.population(n=300)

# NGEN=40
# for gen in range(NGEN):
    # offspring = algorithms.varAnd(population, toolbox, cxpb=0.5, mutpb=0.1)
    # fits = toolbox.map(toolbox.evaluate, offspring)
    # for fit, ind in zip(fits, offspring):
        # ind.fitness.values = fit
        # #print("fit is: %s", fit)
    # population = offspring