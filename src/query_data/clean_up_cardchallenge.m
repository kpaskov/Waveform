old_directory = '/Users/kelley/Data/Waveform/CardiologyChallenge';
new_directory = '/Users/kelley/Data/Waveform/CardiologyChallenge_5min';
records = readtable(strcat(old_directory, '/RECORDS'),'Delimiter',',','Format','%s');

copyfile(strcat(old_directory, '/ALARMS'),strcat(new_directory, '/ALARMS'));
copyfile(strcat(old_directory, '/RECORDS'),strcat(new_directory, '/RECORDS'));

for i=1:size(records, 1)
    record_id = strcat('/', records{i, 1}{1});
    [tm, signal, Fs, siginfo] = rdmat(strcat(old_directory, record_id));
    copyfile(strcat(old_directory, record_id, '.hea'),strcat(new_directory, record_id, '.hea'));
    copyfile(strcat(old_directory, record_id, '.mat'),strcat(new_directory, record_id, '.mat'));

    if(size(signal, 1)/Fs == 330)
        m = load(strcat(new_directory, record_id, '.mat'));
        val = m.val(:, 1:(Fs*300));
        save(strcat(new_directory, record_id, '.mat'), 'val')
    elseif(size(signal, 1)/Fs ~= 300)
        display(strcat('Strange length: ', num2str(size(signal, 1)/Fs)));
    end
end