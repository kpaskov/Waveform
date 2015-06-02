% Author: Kelley Paskov

function [ alarm_type ] = get_alarm_type( comment )
%Converts a physionet comment to an alarm type

%Asystole, Extreme Bradycardia, Extreme Tachycardia

if not(isempty(strfind(comment, 'ASYSTOLE')))
    alarm_type = 'Asystole';
elseif not(isempty(strfind(comment, 'BRADY')))
    alarm_type = 'Bradycardia';
elseif not(isempty(strfind(comment, 'TACHY')))
    alarm_type = 'Tachycardia';
elseif not(isempty(strfind(comment, 'V-TACH')))
    alarm_type = 'Ventricular_Tachycardia';
elseif not(isempty(strfind(comment, 'V-FIB')))
    alarm_type = 'Ventricular_Flutter_Fib';
else
    alarm_type = NaN;
end

