from shutil import copyfile
from random import shuffle, random
import os

__author__ = 'kelley'

directory = '/Users/kelley/Data/Waveform/MIMICII_Sampled'

info_to_train_total = {
    'Ventricular_Tachycardia': [0, 0, 0, 0],
    'Asystole': [0, 0, 0, 0],
    'Tachycardia': [0, 0, 0, 0],
    'Ventricular_Flutter_Fib': [0, 0, 0, 0],
    'Bradycardia': [0, 0, 0, 0]
}
record_to_train = dict()

#Load sample information
f = open(directory + '/ALARMS', 'r')
train_file = open(directory + '/TRAIN', 'w+')
for line in f:
    pieces = line.strip().split(',')
    file = pieces[0]
    record = file.split('_')[0]
    if record in record_to_train:
        train = record_to_train[record]
    else:
        if random() > .2:
            train = 1
        else:
            train = 0
        record_to_train[record] = train

    #Write to train file
    train_file.write(file + ',' + str(train) + '\n')

    #Store split info

    alarm_type = pieces[1]
    true_alarm = pieces[2]

    if train == 1:
        if true_alarm == '1':
            info_to_train_total[alarm_type][0] += 1
        else:
            info_to_train_total[alarm_type][1] += 1
    else:
        if true_alarm == '1':
            info_to_train_total[alarm_type][2] += 1
        else:
            info_to_train_total[alarm_type][3] += 1

f.close()
train_file.close()

for alarm_type, split_info in info_to_train_total.iteritems():
    print alarm_type, 1.0*(split_info[0] + split_info[2])/(sum(split_info)), 1.0*split_info[0]/(split_info[0] + split_info[1]), 1.0*split_info[2]/(split_info[2] + split_info[3])