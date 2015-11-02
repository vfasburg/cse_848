% "data" must be read in with: "wavread(<<filename>>) and
% listened to with "soundsc(result, 16000)". Otherwise scale will be wrong

function xnew = spectralSubtraction(data, fs, alpha)
    %this function needs to process data as integers, not floats
    data = data * (1/max(abs(data))); %scale to use full range
    data = floor(data * 32768); % conversion to 16-bit int
    
    %get test file data
    persistent binMinimums
    if(isempty(binMinimums))
        binMinimums = [0, 1.93069772888325, 2.68269579527973, 3.72759372031494, 5.17947467923121, 7.19685673001152, 10, 13.8949549437314, 19.3069772888325, 26.8269579527973, 37.2759372031494, 51.7947467923121, 71.9685673001152, 100, 138.949549437314, 193.069772888325, 268.269579527972, 372.759372031494, 517.947467923121, 719.685673001152, 1000, 1389.49549437314, 1930.69772888325, 2682.69579527972, 3727.59372031494, 5179.47467923121, 7196.85673001152, 10000, 13894.9549437314, 19306.9772888325, 26826.9579527973, 37275.9372031494, 51794.7467923121, 71968.5673001151, 100000, 138949.549437314, 193069.772888325, 268269.579527973, 372759.372031494, 517947.467923121, 719685.673001151, 1000000, 1389495.49437314, 1930697.72888325, 2682695.79527973, 3727593.72031494, 5179474.67923121, 7196856.73001151];
    end
    
    function result = getBin(energy)
        i = 1;
        while(i <= length(binMinimums) && energy >= binMinimums(i))
            i = i + 1;
        end
        result = i - 1;
    end

    N = 512;
    start = 1;
    finish = N;
    y_old = zeros([N 1]);
    ham = hanning(N);
    xnew = zeros(size(data));
    % set up histogram
    bins = 50;
    erosion = 0.95; % makes histogram favor new values
    histo = zeros([N, bins]);
    noiseEnergy = zeros([N, 1]);
    while(finish < length(data))
        % window time domain data & get fft
        x = cast(data(start:finish),'double') .* ham;
        y = fft(x);

        freq = alpha * abs(y_old) + (1 - alpha) * abs(y); % using abs values seems to work better
        y_old = freq;

        % update the histogram
        histo = histo .* erosion;

        for f = 2:N-1 % first & last freqs in freq aren't real
            binnum = getBin(abs(freq(f)));
            histo(f, binnum) = histo(f, binnum) + 1;
            curmax = 0;
            maxbin = 0;
            for curbin = 1:bins %search for bin index w maximum value
                if(histo(f, curbin) > curmax)
                    curmax = histo(f, curbin);
                    maxbin = curbin;
                end
            end
            % get energy associated with most used bin
            noiseEnergy(f) = binMinimums(maxbin);
        end	
        % subtract estimated noise energy
        y = y .* (abs(freq) - noiseEnergy)./abs(freq);
        temp = real(ifft(y));
        xnew(start:finish) = xnew(start:finish) + temp;

        % use 50% overlap and add ifft output.
        finish = finish + N/2;
        start = start + N/2;
    end
    xnew = xnew * (1/32768); %convert back to floats
    xnew = xnew * (1/max(abs(xnew))); %scale to use full range
end