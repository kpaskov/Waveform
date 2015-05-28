directory = '/Users/kelley/Data/Waveform/MIMICII_Sampled/';
records = readtable(strcat(directory, 'RECORDS'),'Delimiter',',','Format','%s');

previous_record_id = NaN;
previous_alarm_sample_indices = NaN;
previous_alarm_comments = NaN;
previous_expert_sample_indices = NaN;
previous_siginfo = NaN;

for i=1:size(records, 1)
    record = records{i, 1}{1};
    disp(record);
    try
        split_record_id = strsplit(record, '_');
        alarm_index = str2double(split_record_id{2});
        record_id = split_record_id{1}(1:end-1);
        
        if record_id == previous_record_id
            alarm_sample_indices = previous_alarm_sample_indices;
            alarm_comments = previous_alarm_comments;
            expert_sample_indices = previous_expert_sample_indices;
            siginfo = previous_siginfo;
        else
            disp('Getting Data');
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
            
            previous_record_id = record_id;
            previous_alarm_sample_indices = alarm_sample_indices;
            previous_alarm_comments = alarm_comments;
            previous_expert_sample_indices = expert_sample_indices;
            previous_siginfo = siginfo;
        end
        
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
    catch Exception
    end
end