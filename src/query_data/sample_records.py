from shutil import copyfile
from random import shuffle
import os

__author__ = 'kelley'

'''
This file selects samples from the MIMICII data in such a way that no more than three alarms of a given
type are taken from the same record.
'''
mimic_directory = '/Users/kelley/Data/Waveform/MIMICII'
new_directory = '/Users/kelley/Data/Waveform/MIMICII_Sampled'

record_to_info = dict()

#Load sample information
f = open(mimic_directory + '/ALARMS', 'r')
for line in f:
    pieces = line.strip().split(',')
    file = pieces[0]
    record = file.split('_')[0]
    alarm_type = pieces[1]
    true_alarm = pieces[2]

    if record not in record_to_info:
        record_to_info[record] = {
                'Ventricular_Tachycardia': [],
                'Asystole': [],
                'Tachycardia': [],
                'Ventricular_Flutter_Fib': [],
                'Bradycardia': []
            }
    record_to_info[record][alarm_type].append((file, true_alarm))
f.close()



alarm_file = open(new_directory + '/ALARMS', 'w+')
record_file = open(new_directory + '/RECORDS', 'w+')

#Choose only three alarms of each type per record
for record, info in record_to_info.iteritems():
    for alarm_type, alarms in info.iteritems():
        if len(alarms) <= 3:
            chosen_alarms = alarms
        else:
            shuffle(alarms)
            chosen_alarms = alarms[:3]

        for alarm in chosen_alarms:
            copyfile(mimic_directory + '/' + alarm[0] + '.hea', new_directory + '/' + alarm[0] + '.hea')
            copyfile(mimic_directory + '/' + alarm[0] + '.mat', new_directory + '/' + alarm[0] + '.mat')
            alarm_file.write(alarm[0] + ',' + alarm_type + ',' + alarm[1] + '\n')
            record_file.write(alarm[0] + '\n')

alarm_file.close()
record_file.close()