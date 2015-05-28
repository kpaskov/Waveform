directory = '/Users/kelley/Data/Waveform/MIMICII_Sampled';
records = readtable(strcat(directory, '/RECORDS'), 'Delimiter',',','Format','%s');
alarms = readtable(strcat(directory, '/ALARMS'), 'Delimiter',',','Format','%s%s%s');
train = readtable(strcat(directory, '/TRAIN'), 'Delimiter',',','Format','%s%s');

X = zeros(size(records, 1), 75000);
for i=1:size(records, 1)
    record_id = strcat('/', records{i, 1}{1});
    [tm, signal, Fs, siginfo] = rdmat(strcat(directory, record_id));
    for s=1:size(siginfo, 1)
        if strcmp(siginfo(1).Description, 'II')
            try
                X(i,:) = resample(signal(:,s), 250, Fs);
            catch
            end    
        end
    end
    disp(i);
end

save('raw_data_M_all.mat', 'X', '-v7.3');

nan_rows = any(isnan(X),2);
X1 = X(~nan_rows,:);
records1 = records(~nan_rows,:);
alarms1 = alarms(~nan_rows,:);
train1 = train(~nan_rows,:);

zero_rows = sum(X1, 2) == 0;
X2 = X1(~zero_rows,:);
records2 = records1(~zero_rows,:);
alarms2 = alarms1(~zero_rows,:);
train2 = train1(~zero_rows,:);

train_rows = cellfun(@(x) x == '1', train2.Train);
XTrain = X2(train_rows,:);
XTest = X2(~train_rows,:);
alarms3 = alarms2(train_rows,:);
yTrain = cellfun(@(x) x == '1', alarms3.TrueFalse);
yTest = cellfun(@(x) x ~= '1', alarms3.TrueFalse);

m = size(XTrain, 2);          % Window length
n = pow2(nextpow2(m));  % Transform length
XTrain_Fourier = fft(XTrain, n, 2);           % DFT
f = (0:n-1)*(250/n);     % Frequency range
power = XTrain_Fourier(:,1).*conj(XTrain_Fourier(:,1))/n;   % Power of the DFT
plot(XTrain_Fourier(:,1), power);
