function data = fitness(clean, noisy, params,  runNum, gen, individual)
    fs = 16000;
    %apply proper ranges to parameters
    alpha_wiener = params(1) * 2;
    percent_wiener = params(2) * 4 - 2;
    percent_specsub = params(3) * 4 - 2;
    threshold = params(4) * 0.25;
    attack = params(5) * 10;
    noise_length = params(6) * 20;
    noise_margin = params(7) * 20;
    hangover = params(8) * 20;
    
    % processed = percent_wiener * WienerNoiseReduction(noisy, fs, alpha_wiener) + (1 - percent_wiener) * spectral_subtraction(noisy, fs, alpha_specsub);
    specsub = percent_specsub * spec_sub_rmr(noisy, fs, noise_length, noise_margin, hangover);
    weiner = percent_wiener * WienerNoiseReduction(noisy, fs, alpha_wiener);
    len = min([length(clean) length(specsub) length(weiner)]);
    specsub = specsub(1:len);
    weiner = weiner(1:len);
    clean = clean(1:len);
    
    processed = noise_gate(weiner + specsub, threshold, attack, attack);
    result = sum(abs(clean - processed))/len;
    data = [runNum, gen, individual, alpha_wiener, percent_wiener, percent_specsub, threshold, attack, noise_length, noise_margin, hangover, result];
end