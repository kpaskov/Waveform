% Author: Kelley Paskov

function [ ] = get_record_data( record_id, directory )
%Pulls alarm data for a record and writes it to matlab files in given directory.

%Record url for physionet
record_location = strcat('mimic2db/', record_id, '/', record_id);

%Get alarm annotations
[alarm_sample_indices, ~, ~, ~, ~, alarm_comments]=rdann(record_location,'alarms');
try
    [expert_sample_indices, ~, ~, ~, ~, ~]=rdann(record_location,'alM');
catch
    expert_sample_indices = [];
end

%Get signal information
[siginfo] = wfdbdesc(record_location);
time_between_samples = 1./double(siginfo(1).SamplingFrequency);

%Pull 5min window before each alarm
previous_alarm_index = 1;
for i=1:size(alarm_sample_indices, 1)
    alarm_signal_index = alarm_sample_indices(i);
    alarm_comment = alarm_comments{i}{1};
    alarm_type = get_alarm_type(alarm_comment);

    if ~isnan(alarm_type)
        %If this alarm isn't near (within 5 min of) the previous alarm
        window_size = round(double(60*5)/time_between_samples);
        if alarm_signal_index - window_size >= previous_alarm_index
            wfdb2mat(record_location, [], alarm_signal_index-1, alarm_signal_index-window_size);
            movefile(strcat(record_id, 'm.mat'),strcat(directory, record_id, 'm_', num2str(i), '.mat'))
            movefile(strcat(record_id, 'm.hea'),strcat(directory, record_id, 'm_', num2str(i), '.hea'))
            
            %Add trailing alarm info to header file.
            fid = fopen(strcat(directory, record_id, 'm_', num2str(i), '.hea'), 'a+');
            fprintf(fid, '#%s\n', alarm_type);
            alarm_value = '0';
            if sum(expert_sample_indices == alarm_signal_index) == 0
                fprintf(fid, '#False alarm\n');
            else
                fprintf(fid, '#True alarm\n');
                alarm_value = '1';
            end
            fclose(fid);
            
            %Add to RECORDS and ALARMS files
            fid = fopen(strcat(directory, 'RECORDS'), 'a+');
            fprintf(fid, '%s\n', strcat(record_id, 'm_', num2str(i)));
            fclose(fid);
            
            fid = fopen(strcat(directory, 'ALARMS'), 'a+');
            fprintf(fid, '%s,%s,%s\n', strcat(record_id, 'm_', num2str(i)), alarm_type, alarm_value);
            fclose(fid);
            
            previous_alarm_index = alarm_signal_index;
        end
    end
end
