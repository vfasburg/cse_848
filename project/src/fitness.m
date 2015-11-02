function result = fitness(clean, noisy, params)
    fs = 16000;
    alpha_wiener = params(1);
    alpha_specsub = params(2);
    percent_wiener = params(3);
    percent_specsub = params(4);
    threshold = params(5);
    attack = params(6);
    release = params(7);
    
    % processed = percent_wiener * WienerNoiseReduction(noisy, fs, alpha_wiener) + (1 - percent_wiener) * spectral_subtraction(noisy, fs, alpha_specsub);
    processed = noise_gate(percent_wiener * WienerNoiseReduction(noisy, fs, alpha_wiener) + percent_specsub * spectral_subtraction(noisy, fs, alpha_specsub), threshold, attack, release);
    len = min(length(clean), length(processed));
    result = 0;
    for i = 1:len
        result = result + abs(clean(i) - processed(i));
    end
    result = result/len;
    fprintf('alpha_wiener: %f  alpha_specsub: %f \npercent_wiener: %f percent_specsub: %f \nthreshold: %f attack: %f release: %f fitness: %f\n', ... 
             alpha_wiener, alpha_specsub, percent_wiener,percent_specsub, threshold, attack, release, result);
end