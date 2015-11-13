function result = fitness_manual(clean, noisy, params)
    fs = 16000;
    %apply proper ranges to parameters
    alpha_wiener = params(1);
    percent_wiener = params(2);
    percent_specsub = params(3);
    threshold = params(4);
    attack = params(5);
    noise_length = params(6);
    noise_margin = params(7);
    hangover = params(8);
    
    % processed = percent_wiener * WienerNoiseReduction(noisy, fs, alpha_wiener) + (1 - percent_wiener) * spectral_subtraction(noisy, fs, alpha_specsub);
    specsub = percent_specsub * spec_sub_rmr(noisy, fs, noise_length, noise_margin, hangover);
    weiner = percent_wiener * WienerNoiseReduction(noisy, fs, alpha_wiener);
    len = min([length(clean) length(specsub) length(weiner)]);
    specsub = specsub(1:len);
    weiner = weiner(1:len);
    clean = clean(1:len);

    processed = noise_gate(weiner + specsub, threshold, attack, attack);
    
    result = sum(abs(clean - processed))/len;
end