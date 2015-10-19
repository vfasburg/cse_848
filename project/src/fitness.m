function result = fitness(clean, dirty, params)
    fs = 16000;
    alpha_wiener = params(1);
    alpha_specsub = params(2);
    percent_wiener = params(3);
    threshold = params(4);
    attack = params(5);
    release = params(6);
    
    % processed = percent_wiener * WienerNoiseReduction(dirty, fs, alpha_wiener) + (1 - percent_wiener) * spectral_subtraction(dirty, fs, alpha_specsub);
    processed = noise_gate(percent_wiener * WienerNoiseReduction(dirty, fs, alpha_wiener) + (1 - percent_wiener) * spectral_subtraction(dirty, fs, alpha_specsub), threshold, attack, release);
    len = min(length(clean), length(processed));
    result = 0;
    for i = 1:len
        result = result + abs(clean(i) - processed(i));
    end
    result = result/len;
    fprintf('alpha_wiener: %f  alpha_specsub: %f  percent_wiener: %f \nthreshold: %f attack: %f release: %f fitness: %f\n', ... 
             alpha_wiener, alpha_specsub, percent_wiener, threshold, attack, release, result);
end