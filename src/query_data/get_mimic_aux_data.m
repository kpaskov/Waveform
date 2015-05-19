directory = '/Users/kelley/Data/Waveform/MIMICII_Sampled/';
records = readtable(strcat(directory, 'RECORDS'),'Delimiter',',','Format','%s');

for i=1:size(records, 1)
    record = records{i, 1}{1};
    disp(record);
    split_record_id = strsplit(record, '_');
    alarm_index = str2double(split_record_id{2});
    record_id = split_record_id{1}(1:end-1);
    %Record url for physionet
    record_location = strcat('mimic2db/', record_id, '/', record_id);

    %Get alarm annotations
    [alarm_sample_indices, ~, ~, ~, ~, alarm_comments]=rdann(record_location,'alarms');
    try
        [expert_sample_indices]=rdann(record_location,'alM');
    catch
        expert_sample_indices = [];
    end

    %Get signal information
    [siginfo] = wfdbdesc(record_location);
    time_between_samples = 1./double(siginfo(1).SamplingFrequency);

    num_previous_alarms = alarm_index - 1;
    fraction_previous_true = 1.0*sum(expert_sample_indices < alarm_sample_indices(alarm_index))/(1.0*num_previous_alarms);
    length_waveform = alarm_sample_indices(alarm_index)*time_between_samples;
    time_last_alarm = (alarm_sample_indices(alarm_index) - alarm_sample_indices(alarm_index-1))*time_between_samples;
    alarms_in_last_hour = alarm_sample_indices(alarm_sample_indices(1:alarm_index-1) > alarm_sample_indices(alarm_index)-(60./time_between_samples));
    num_alarms_last_hour = size(alarms_in_last_hour, 1);
  
    fid = fopen(strcat(directory, 'WAVEFORM'), 'a+');
    fprintf(fid, '%s,%i,%1.3f,%3.2f,%3.2f,%i\n', record, num_previous_alarms, fraction_previous_true, length_waveform, time_last_alarm, num_alarms_last_hour);
    fclose(fid);
   
end