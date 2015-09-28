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
fs, data = wavfile.read(r"C:\Users\Vince\Documents\School\MSU\2015_Fall\CSE848\Audio\I_am_sitting_dirty.wav")
N = 512
start = 0
end = N
ham = numpy.hamming(N)
xnew = numpy.zeros(data.size)
# set up histogram
bins = 50
erosion = 0.05 #makes histogram favor new values
histogram = numpy.zeros((N, bins))
maxEnergy = 2000000 # this number is an educated guess based on a matlab experiment
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
		binnum = numpy.floor(abs(freq[f])/maxEnergy * bins)
		histogram[f][binnum] += 1
		curmax = 0
		maxbin = 0
		for curbin in range(0,bins): #search for bin index w maximum value
			if(histogram[f][curbin] > curmax):
				curmax = histogram[f][curbin]
				maxbin = curbin
		# get energy associated with most used bin
		noiseEnergy[f] = (maxbin + 0.5) * maxEnergy/bins
	# subtract estimated noise energy
	freq -= noiseEnergy
	freq[freq<0] = 0
	xnew[start:end] += irfft(freq)

	# use 50% overlap and add ifft output
	end += N/2
	start += N/2

wavfile.write(r"C:\Users\Vince\Documents\School\MSU\2015_Fall\CSE848\Audio\I_am_sitting_dirty_new.wav", fs, xnew.astype(numpy.int16))

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