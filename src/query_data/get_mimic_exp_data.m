% Author: Kelley Paskov
% This script creates a file that indicates, for each sample, did it come from a record that had
% any expert annotations.
% We use this information in order to create a list of samples whose true/false annotation we are
% confident about.

directory = '/Users/kelley/Data/Waveform/MIMICII_Sampled/';
records = readtable(strcat(directory, 'RECORDS'),'Delimiter',',','Format','%s');

previous_record_id = NaN;
previous_has_expert = NaN;

for i=1:size(records, 1)
    record = records{i, 1}{1};
    disp(record);
    
    split_record_id = strsplit(record, '_');
    alarm_index = str2double(split_record_id{2});
    record_id = split_record_id{1}(1:end-1);
        
    if record_id == previous_record_id
        has_expert = previous_has_expert;
    else
        disp('Getting Data');
        %Record url for physionet
        record_location = strcat('mimic2db/', record_id, '/', record_id);

        try
            [expert_sample_indices, ~, ~, ~, ~, ~]=rdann(record_location,'alM');
            if size(expert_sample_indices, 1) > 0
                has_expert = 1;
            else
                has_expert = 0;
            end
        catch
            has_expert = 0;
        end
        
        previous_record_id = record_id;
        previous_has_expert = has_expert;
    end
        
    fid = fopen(strcat(directory, 'EXPERT'), 'a+');
    fprintf(fid, '%s,%i\n', record, has_expert);
    fclose(fid);
end