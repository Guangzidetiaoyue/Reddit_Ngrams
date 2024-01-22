from matplotlib import lines
import requests
import json
import pandas as pd
import csv


with open('twitter_compare0908/words.txt','r',encoding='utf-8') as f:
    with open('twitter_compare0908/rc_gram_1_url.txt','w',encoding='utf-8') as f1:
        lines = f.readlines()
        for line in lines[1:]:
            gram_1 = line.strip().split('\t')[0]
            url = 'https://storywrangling.org/api/ngrams/'+gram_1
            f1.write(url+'\n')
