function output=spec_sub_rmr(signal,fs, NoiseLength, NoiseMargin, Hangover)
    % Spectral Subtraction based on Boll 79. Amplitude spectral subtraction 
    % Includes Magnitude Averaging and Residual noise Reduction
    % S is the noisy signal, FS is the sampling frequency and IS is the initial
    % silence (noise only) length in seconds (default value is .25 sec)
    %
    % April-05
    % Esfandiar Zavarehei
    NoiseCounter = 0;
    IS=.25; %seconds
    W=fix(.025*fs); %Window length is 25 ms
    nfft=W;
    SP=.4; %Shift percentage is 40% (10ms) %Overlap-Add method works good with this value(.4)
    win=hamming(W);

    init_silence=fix((IS*fs-W)/(SP*W) +1);%number of initial silence segments
    Gamma=1;%Magnitude Power (1 for magnitude spectral subtraction 2 for power spectrum subtraction)

    y=segment(signal,W,SP,win);
    Y=fft(y,nfft);
    YPhase=angle(Y(1:fix(end/2)+1,:)); %Noisy Speech Phase
    Y=abs(Y(1:fix(end/2)+1,:)).^Gamma;%Specrogram
    numberOfFrames=size(Y,2);

    N= mean(Y(:,1:init_silence)')'; %initial Noise Power Spectrum mean
    NRM=zeros(size(N));% Noise Residual Maximum (Initialization)
    % NoiseLength=9;%This is a smoothing factor for the noise updating
    X = zeros(size(Y));
    YS=Y; %Y Magnitude Averaged
    for i=2:(numberOfFrames-1)
        YS(:,i)=(Y(:,i-1)+Y(:,i)+Y(:,i+1))/3;
    end

    for i=1:numberOfFrames
        SpeechFlag = voice_detector(Y(:,i).^(1/Gamma),N.^(1/Gamma), NoiseMargin, Hangover, NoiseCounter); %Magnitude Spectrum Distance VAD
        if SpeechFlag==0
            N=(NoiseLength*N+Y(:,i))/(NoiseLength+1); %Update and smooth noise
            NRM=max(NRM,YS(:,i)-N);%Update Maximum Noise Residue
            X(:,i)=0.01*Y(:,i); %gives about 40db of rejection
        else
            D=Y(:,i)-N; % Specral Subtraction (previously used YS)
            if i>1 && i<numberOfFrames %Residual Noise Reduction            
                for j=1:length(D)
                    if D(j)<NRM(j)
                        D(j)=min([D(j) YS(j,i-1)-N(j) YS(j,i+1)-N(j)]);
                    end
                end
            end
            X(:,i)=max(D,0);
        end
    end

    output=OverlapAdd2(X.^(1/Gamma),YPhase,W,SP*W);
end


function ReconstructedSignal=OverlapAdd2(XNEW,yphase,windowLen,ShiftLen)
    %Y=OverlapAdd(X,A,W,S);
    %Y is the signal reconstructed signal from its spectrogram. X is a matrix
    %with each column being the fft of a segment of signal. A is the phase
    %angle of the spectrum which should have the same dimension as X. if it is
    %not given the phase angle of X is used which in the case of real values is
    %zero (assuming that its the magnitude). W is the window length of time
    %domain segments if not given the length is assumed to be twice as long as
    %fft window length. S is the shift length of the segmentation process ( for
    %example in the case of non overlapping signals it is equal to W and in the
    %case of %50 overlap is equal to W/2. if not givven W/2 is used. Y is the
    %reconstructed time domain signal.
    %Sep-04
    %Esfandiar Zavarehei

    if fix(ShiftLen)~=ShiftLen
        ShiftLen=fix(ShiftLen);
        disp('The shift length have to be an integer as it is the number of samples.')
        disp(['shift length is fixed to ' num2str(ShiftLen)])
    end

    [~, FrameNum]=size(XNEW);

    Spec=XNEW.*exp(1i*yphase);

    if mod(windowLen,2) %if FreqResol is odd
        Spec=[Spec;flipud(conj(Spec(2:end,:)))];
    else
        Spec=[Spec;flipud(conj(Spec(2:end-1,:)))];
    end
    sig=zeros((FrameNum-1)*ShiftLen+windowLen,1);

    for i=1:FrameNum
        start=(i-1)*ShiftLen+1;
        spec=Spec(:,i);
        sig(start:start+windowLen-1)=sig(start:start+windowLen-1)+real(ifft(spec,windowLen));
    end
    ReconstructedSignal=sig;
end

function SpeechFlag = voice_detector(signal,noise,NoiseMargin,Hangover, NoiseCounter)

    %[NOISEFLAG, SPEECHFLAG, NOISECOUNTER, DIST]=voice_detector(SIGNAL,NOISE,NOISECOUNTER,NOISEMARGIN,HANGOVER)
    %Spectral Distance Voice Activity Detector
    %SIGNAL is the the current frames magnitude spectrum which is to labeld as
    %noise or speech, NOISE is noise magnitude spectrum template (estimation),
    %NOISECOUNTER is the number of imediate previous noise frames, NOISEMARGIN
    %(default 3)is the spectral distance threshold. HANGOVER ( default 8 )is
    %the number of noise segments after which the SPEECHFLAG is reset (goes to
    %zero). NOISEFLAG is set to one if the the segment is labeld as noise
    %NOISECOUNTER returns the number of previous noise segments, this value is
    %reset (to zero) whenever a speech segment is detected. DIST is the
    %spectral distance. 
    %Saeed Vaseghi
    %edited by Esfandiar Zavarehei
    %Sep-04

    SpectralDist= 20*(log10(signal)-log10(noise));
    SpectralDist(SpectralDist<0)=0;

    Dist=mean(SpectralDist); 
    if (Dist < NoiseMargin) 
        NoiseCounter=NoiseCounter+1;
    else
        NoiseCounter=0;
    end

    % Detect noise only periods and attenuate the signal     
    if (NoiseCounter > Hangover) 
        SpeechFlag=0;    
    else 
        SpeechFlag=1; 
    end 
end

function Seg=segment(signal,WinLen,ShiftPercent,hamWin)

    % SEGMENT chops a signal to overlapping windowed segments
    % A= SEGMENT(X,W,SP,WIN) returns a matrix which its columns are segmented
    % and windowed frames of the input one dimentional signal, X. W is the
    % number of samples per window, default value W=256. SP is the shift
    % percentage, default value SP=0.4. WIN is the window that is multiplied by
    % each segment and its length should be W. the default window is hamming
    % window.
    % 06-Sep-04
    % Esfandiar Zavarehei

    if nargin<3
        ShiftPercent=.4;
    end
    if nargin<2
        WinLen=256;
    end
    if nargin<4
        hamWin=hamming(WinLen);
    end
    hamWin=hamWin(:); %make it a column vector

    sigLen=length(signal);
    ShiftPercent=fix(WinLen.*ShiftPercent);
    NumSegments=fix((sigLen-WinLen)/ShiftPercent +1); %number of segments

    Index=(repmat(1:WinLen,NumSegments,1)+repmat((0:(NumSegments-1))'*ShiftPercent,1,WinLen))';
    hw=repmat(hamWin,1,NumSegments);
    Seg=signal(Index).*hw;
end

