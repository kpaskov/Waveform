% Author: Kelley Paskov
% This script collects auxilliary waveform data for the MIMICII waveforms. This includes:
% Number of previous alarms
% Fraction of previous alarms that are true alarms
% Waveform length
% Time since last alarm
% Number of alarms in the hour leading up this alarm
% Whether this alarm is a true alarm or a false alarm
% Number of previous alarms that are true alarms
% Number of previous alarms that are false alarms
% Whether or not this record has any expert annotations

directory = '/Users/kelley/Data/Waveform/MIMICII_Sampled/';
records = readtable(strcat(directory, 'RECORDS'),'Delimiter',',','Format','%s');

previous_record_id = NaN;
previous_alarm_sample_indices = NaN;
previous_alarm_comments = NaN;
previous_expert_sample_indices = NaN;
previous_expert_comments = NaN;
previous_siginfo = NaN;

for i=1:size(records, 1)
    record = records{i, 1}{1};
    disp(record);
    disp(i);
    
    split_record_id = strsplit(record, '_');
    alarm_index = str2double(split_record_id{2});
    record_id = split_record_id{1}(1:end-1);
        
    if record_id == previous_record_id
        alarm_sample_indices = previous_alarm_sample_indices;
        alarm_comments = previous_alarm_comments;
        expert_sample_indices = previous_expert_sample_indices;
        expert_comments = previous_expert_comments;
        siginfo = previous_siginfo;
    else
        disp('Getting Data');
        %Record url for physionet
        record_location = strcat('mimic2db/', record_id, '/', record_id);

        %Get alarm annotations
        [alarm_sample_indices, ~, ~, ~, ~, alarm_comments]=rdann(record_location,'alarms');
        try
            [expert_sample_indices, ~, ~, ~, ~, expert_comments]=rdann(record_location,'alM');
        catch
            expert_sample_indices = [];
        end
        
        %Get signal information
        [siginfo] = wfdbdesc(record_location);
            
        previous_record_id = record_id;
        previous_alarm_sample_indices = alarm_sample_indices;
        previous_alarm_comments = alarm_comments;
        previous_expert_sample_indices = expert_sample_indices;
        previous_expert_comments = expert_comments;
        previous_siginfo = siginfo;
    end
        
    time_between_samples = 1./double(siginfo(1).SamplingFrequency);

    alarm_sample_index = alarm_sample_indices(alarm_index);
    if size(alarm_sample_indices, 1) > 0
        alarm_sample_indices = alarm_sample_indices(cellfun(@is_valid_alarm, [alarm_comments{:, 1}].'),:);
    end
    if size(expert_sample_indices, 1) > 0
        expert_sample_indices = expert_sample_indices(cellfun(@is_valid_alarm, [expert_comments{:, 1}].'),:);
    end
        
    previous_alarms = alarm_sample_indices(alarm_sample_indices < alarm_sample_index);
    previous_true_alarms = expert_sample_indices(expert_sample_indices < alarm_sample_index);
    previous_false_alarms = setdiff(previous_alarms, previous_true_alarms);
   
    num_previous_alarms = size(previous_alarms, 1);
    if num_previous_alarms == 0
        fraction_previous_true = NaN;
        time_last_alarm = NaN;
    else
        fraction_previous_true = 1.0*size(previous_true_alarms, 1)/(1.0*num_previous_alarms);
        time_last_alarm = (alarm_sample_index - previous_alarms(end))*time_between_samples;
    end
        
    length_waveform = alarm_sample_index*time_between_samples;
    alarms_in_last_hour = previous_alarms(previous_alarms > alarm_sample_index-(60./time_between_samples));
    num_alarms_last_hour = size(alarms_in_last_hour, 1);
    truefalse = sum(expert_sample_indices == alarm_sample_index);
    num_true_alarms = size(previous_true_alarms, 1);
    num_false_alarms = size(previous_false_alarms, 1);
    has_expert = num_true_alarms;
    if has_expert > 0
        has_expert = 1;
    end
    
    fid = fopen(strcat(directory, 'WAVEFORM'), 'a+');
    fprintf(fid, '%s,%i,%1.3f,%3.2f,%3.2f,%i,%i,%i,%i,%i\n', record, num_previous_alarms, fraction_previous_true, length_waveform, time_last_alarm, num_alarms_last_hour, truefalse, num_true_alarms, num_false_alarms, has_expert);
    fclose(fid);
end