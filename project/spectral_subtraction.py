import array, random, numpy, wave
from scipy.fftpack import fft, ifft, rfft, irfft
from scipy.io import wavfile # get the api
numpy.set_printoptions(threshold='nan')
#get test file data
binMinimums = [0, 1.93069772888325, 2.68269579527973, 3.72759372031494, 5.17947467923121, 7.19685673001152, 10, 13.8949549437314, 19.3069772888325, 26.8269579527973, 37.2759372031494, 51.7947467923121, 71.9685673001152, 100, 138.949549437314, 193.069772888325, 268.269579527972, 372.759372031494, 517.947467923121, 719.685673001152, 1000, 1389.49549437314, 1930.69772888325, 2682.69579527972, 3727.59372031494, 5179.47467923121, 7196.85673001152, 10000, 13894.9549437314, 19306.9772888325, 26826.9579527973, 37275.9372031494, 51794.7467923121, 71968.5673001151, 100000, 138949.549437314, 193069.772888325, 268269.579527973, 372759.372031494, 517947.467923121, 719685.673001151, 1000000, 1389495.49437314, 1930697.72888325, 2682695.79527973, 3727593.72031494, 5179474.67923121, 7196856.73001151]
def getBin(energy):
	i = 0
	# print energy
	while i < len(binMinimums) and energy > binMinimums[i]:
		i += 1
	# print i - 1
	return i - 1
fs, data = wavfile.read(r".\audio\I_am_sitting_dirty.wav")

N = 512
start = 0
end = N
y_old = numpy.zeros(N)
ham = numpy.hamming(N)
xnew = numpy.zeros(data.size)
# set up histogram
bins = 50
erosion = 0.95 #makes histogram favor new values
histogram = numpy.zeros((N, bins))
noiseEnergy = numpy.zeros(N)
while(end < data.size):
	#window time domain data & get fft
	x = data[start:end] * ham
	y = fft(x)
	alpha = 0.8
	freq = alpha * abs(y_old) + (1 - alpha) * abs(y) # using abs values seems to work better
	y_old = freq

	if(end == 20*N):
		print 'x: '
		print x
		print 'y:' 
		print y
		print 'freq:'
		print freq
	# update the histogram
	histogram = histogram * erosion
	
	# if(end == 20*N):
		# for i in range(0, histogram.size):
			# print max(histogram[i])
	
	for f in range(1, N-1): # first & last freqs in freq aren't real
		binnum = getBin(abs(freq[f]))
		histogram[f][binnum] += 1
		curmax = 0
		maxbin = 0
		for curbin in range(0,bins): #search for bin index w maximum value
			if(histogram[f][curbin] > curmax):
				curmax = histogram[f][curbin]
				maxbin = curbin
		# get energy associated with most used bin
		noiseEnergy[f] = binMinimums[maxbin]
		
		if(end == 20*N and f == 50):
			# print 'histo[50] bins 1 through 8 = %s %s %s %s %s %s %s %s' % (histogram[50][0], histogram[50][5], histogram[50][10], histogram[50][15], histogram[50][20], histogram[50][25], histogram[50][30], histogram[50][35])
			print 'hist[50] is:'
			print histogram[50]
			print 'noise energy is:'
			print noiseEnergy
	# subtract estimated noise energy
	y = y * (abs(freq) - noiseEnergy)/abs(freq)
	xnew[start:end] += numpy.real(ifft(y))

	# use 50% overlap and add ifft output.
	end += N/2
	start += N/2

wavfile.write(r".\audio\I_am_sitting_processed.wav", fs, xnew.astype(numpy.int16))
