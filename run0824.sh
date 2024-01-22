#!/bin/bash
path='/data/photonic/reddit_raw_comments/day_ngrams/every_day_ngrams/en'

for g in 'test_ngram' #'1gramc' '2gramc' '3gramc'
do
    for file in `ls $path/$g`
        do
            #echo $path/$g/$file
            gzip -kd $path/$g/$file
            cds_verbs0824.py $path/$g/$file
        done
done