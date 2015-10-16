function result = fitness(params)
    [clean, fs] = wavread('C:\Users\Vince\Documents\School\MSU\2015_Fall\CSE848\Audio\I_am_sitting_clean.wav');
    [dirty, fs] = wavread('C:\Users\Vince\Documents\School\MSU\2015_Fall\CSE848\Audio\I_am_sitting_dirty.wav');
    alpha_wiener = params(1);
    alpha_specsub = params(2);
    percent_wiener = params(3);
    
    processed = percent_wiener * WienerNoiseReduction(dirty, fs, alpha_wiener) + (1 - percent_wiener) * spectral_subtraction(dirty, fs, alpha_specsub);
    len = min(length(clean), length(processed));
    result = 0;
    for i = 1:len
        result = result + abs(clean(i) - processed(i));
    end
    fprintf('alpha_wiener: %f  alpha_specsub: %f  percent_wiener: %f  fitness: %f\n', ... 
             alpha_wiener, alpha_specsub, percent_wiener, result);
end