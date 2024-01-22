from pytrends.request import TrendReq
from datetime import datetime
import pandas as pd
import json
import numpy as np
from matplotlib import pyplot as plt
import matplotlib.ticker as mtick
from tsmoothie.smoother import LowessSmoother
from collections import defaultdict
smoother = LowessSmoother(smooth_fraction=0.2, iterations=1)

color_l = ['#e789c3','#cc4ec6','#66c2a4','#8d9fca']
color_b = ['#fae7f3','#f5dcf4','#e0f3ed','#8d9fa9']
verbs = []
with open('sources/verbs.tsv', 'r',encoding='utf-8') as f:
    lines = f.readlines()
    for line in lines:
        if ":" not in line:
            words_temp = line.strip().split(', ')
            verbs = words_temp
with open ('ngrams_res/ngrams_res_0824_1.json', 'r') as f:
    data = json.load(f)
dates = pd.DataFrame({'date':pd.date_range('2005-12-01','2021-12-31',freq='D')})
date_str = {}
for i in range(len(dates)):
    date_str[dates.date.dt.date[i].strftime('%Y-%m-%d') ] = i
date_x_label = ['2010','2012','2014','2016','2018','2020','2022']
date_x_idx = []
for d_label in date_x_label:
    if d_label == '2022':
        d_flag = '2021-12-31'
    else:
        d_flag = d_label+'-01-01'
    date_x_idx.append(date_str[d_flag])

data_res = np.zeros((len(dates),9))
verbs_dict = defaultdict(list)
v_0 = []
v_1 = []
for v in verbs:
    v_data = data[v]
    for item in v_data:
        date = item[-1]
        freq = item[-2]
        date_idx = date_str[date]
        if freq >= 1e-1:
            data_res[date_idx,0] += 1
        elif freq >= 1e-2:
            data_res[date_idx,1] += 1
        elif freq >= 1e-3:
            data_res[date_idx,2] += 1
        elif freq >= 1e-4:
            data_res[date_idx,3] += 1
        elif freq >= 1e-5:
            data_res[date_idx,4] += 1
        elif freq >= 1e-6:
            data_res[date_idx,5] += 1
        elif freq >= 1e-7:
            data_res[date_idx,6] += 1
        elif freq >= 1e-8:
            data_res[date_idx,7] += 1
        else:
            data_res[date_idx,8] += 1
freq_x = [i for i in range(9)]

for i in date_x_idx:
    freq_y = [i for j in range(len(freq_x))]
    plt.plot(freq_x,freq_x,data_res[i,:])
plt.savefig('figure_res/compare_date0830.svg',dip=300)
print('done')
