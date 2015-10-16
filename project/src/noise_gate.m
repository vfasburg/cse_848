function [y, rms] = noise_gate(x, threshold, attackTime, releaseTime, ratio)
    % threshold between 0 and 1, attack/release times in ms
    y = zeros(size(x));
    attackSamples = round(attackTime * 160); %convert ms to samples
    releaseSamples = round(releaseTime * 160);
    increment = 1/attackSamples;
    decrement = 1/releaseSamples;
    
    % calculate RMS in 32 sample chunks
    rms_len = 2048;
    rms = zeros(size(x));
    rms_samples = ones(rms_len, 1); %holds past x^2 values used in rms
    cur_gain = 0;
    target_attenuation = 0.1;
    for i = 1:length(x)
        %update rms

        rms_samples(mod(i, rms_len)+1) = x(i).^2;
        rms(i) = sqrt(mean(rms_samples));

        if(i== 16050)
            asdf = 1;
        end
        if(rms(i) < threshold)
            cur_gain = min(cur_gain + increment, 1);
            target_attenuation = ratio * ((threshold - rms)/threshold)
        else
            cur_gain = max(cur_gain - decrement, 0);
        end

        y(i) = (1 - cur_gain) * x(i);
    end
    
end