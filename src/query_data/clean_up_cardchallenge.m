% Author: Kelley Paskov
% Some of the Cardiology Challenge data includes not only the waveforms for the 5 minutes
% leading up to the alarm sounding, but also 30 seconds of waveform after the alarm has already sounded.
% We wanted to predict using only the data leading up to the alarm, so the trailing 30 seconds of data
% needed to be removed from some of our records.
%
% This script cleans up the Cardiology Challenge data by checking whether the record contains extra
% trailing data, and removing it.

old_directory = '/Users/kelley/Data/Waveform/CardiologyChallenge';
new_directory = '/Users/kelley/Data/Waveform/CardiologyChallenge_5min';
records = readtable(strcat(old_directory, '/RECORDS'),'Delimiter',',','Format','%s');

copyfile(strcat(old_directory, '/ALARMS'),strcat(new_directory, '/ALARMS'));
copyfile(strcat(old_directory, '/RECORDS'),strcat(new_directory, '/RECORDS'));

for i=1:size(records, 1)
    record_id = strcat('/', records{i, 1}{1});
    % Reads signal data from mat file
    % Copy signal data to new directory.
    [tm, signal, Fs, siginfo] = rdmat(strcat(old_directory, record_id));
    copyfile(strcat(old_directory, record_id, '.hea'),strcat(new_directory, record_id, '.hea'));
    copyfile(strcat(old_directory, record_id, '.mat'),strcat(new_directory, record_id, '.mat'));

    if(size(signal, 1)/Fs == 330)
        % If signal is 5:30 minutes long, save only the first five minutes.
        m = load(strcat(new_directory, record_id, '.mat'));
        val = m.val(:, 1:(Fs*300));
        save(strcat(new_directory, record_id, '.mat'), 'val')
    elseif(size(signal, 1)/Fs ~= 300)
        % If signal of unexpected length - alert.
        display(strcat('Strange length: ', num2str(size(signal, 1)/Fs)));
    end
end