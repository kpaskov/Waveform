% Author: Kelley Paskov
% This script collects waveform data from MIMICII and saves it to .mat and .hea files in the same
% format as the Cardiology Challenge Data

directory = '/Users/kelley/Data/Waveform/MIMICII/';
match_data = load('Mimic2dbMAP.mat');
match_data = match_data.Mimic2dbMAP;

for i=1:size(match_data, 1)
    try
        record_id = match_data(i, 1);
        record_id = record_id{1};
        disp(record_id);

        get_record_data(record_id, directory);
    catch Error
        display(Error);
    end
end

