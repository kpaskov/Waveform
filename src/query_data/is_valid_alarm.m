% Author: Kelley Paskov

function [ truefalse ] = is_valid_alarm( comment )
% Determines whether a physionet comment is indicating an alarm of interest.
% We are interested in Asystole, Bradycardia, Tachycardia, Ventrycular Tachycardia, and Ventricular
% Fibrillation alarms.

if not(isempty(strfind(comment, 'ASYSTOLE')))
    truefalse = true;
elseif not(isempty(strfind(comment, 'BRADY')))
    truefalse = true;
elseif not(isempty(strfind(comment, 'TACHY')))
    truefalse = true;
elseif not(isempty(strfind(comment, 'V-TACH')))
    truefalse = true;
elseif not(isempty(strfind(comment, 'V-FIB')))
    truefalse = true;
else
    truefalse = false;
end

