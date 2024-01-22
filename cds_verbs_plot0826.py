import os,json
import gzip,argparse
from collections import defaultdict
import pandas as pd
import numpy as np
from matplotlib import pyplot as plt
import string
# import proplot as plt
from tsmoothie.smoother import LowessSmoother
smoother = LowessSmoother(smooth_fraction=0.2, iterations=1)

def moving_average(interval,windowsize):
    window = np.ones(int(windowsize))/float(windowsize)
    re = np.convolve(interval,window,'same')
    return re

if __name__ == '__main__':
    word_year = ['2007','2010','2013','2016','2019','2021']#['2007','2008','2009','2010','2011','2012','2013','2014','2015','2016','2017','2018','2019','2020','2022','2021','2023']
    word_month = ['January', 'April', 'July', 'October', 'December']#['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December']
    word_week = ['Sunday','Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday']
    word_sport = ['Olympics','World Cup', 'Super Bowl', 'NBA']
    word_disease = ['cholera', 'Zika', 'Ebola', 'coronavirus', 'Monkeypox', 'AIDS', 'COVID-19']
    word_disaster = ['Haiti Earthquake', 'Fukushima accident', 'earthquake', 'flood', 'tsunami', 'hurricane', 'wildfire', 'Fukushima', 'Chernobyl']
    word_Famous = ['Donald Trump', 'Cristiano Ronaldo', 'Kobe Bryant', 'Barack Obama', 'Taylor Swift', 'Papa Francesco']
    word_conflict = ['Gaza', 'Libya', 'Syria', 'Turkish', 'Russia-Ukraine', 'Taiwan', 'Indo-Chinese', 'nuclear war'] #'war'
    word_movement = ['Arab Spring', 'Occupy', 'Brexit', 'MeToo', 'Black Lives Matter', 'the yellow vest']
    # word_science = ['Higgs', 'CRISPR', 'Alphago', 'BERT', 'black hole', 'Metaverse', 'gravitational waves', 'Voyager 1', 'artificial chromosome', 'AI', 'quantum computing', 'gene editing', 'climate crisis', 'GPT', 'blockchain']
    words_all = [word_year,word_month,word_week,word_sport,word_disease,word_disaster,word_Famous,word_conflict,word_movement]
    fig, axes = plt.subplots(3,3,figsize=(16,18)) #sharex='col',
    # fig, axes = plt.subplots(ncols=3,nrows=3,axwidth=1.4)
    dates = pd.DataFrame({'date':pd.date_range('2005-12-01','2021-12-31',freq='D')})
    date_str = {}
    for i in range(len(dates)):
        date_str[dates.date.dt.date[i].strftime('%Y-%m-%d') ] = i
    date_x_label = ['2006','2008','2010','2012','2014','2016','2018','2020','2022']
    date_x_idx = []
    for d_label in date_x_label:
        if d_label == '2022':
            d_flag = '2021-12-31'
        else:
            d_flag = d_label+'-01-01'
        date_x_idx.append(date_str[d_flag])

    res_file = 'ngrams_res/ngrams_res_0824_0.json'
    with open(res_file, 'r') as f:
        data = json.load(f)
    # plt.figure()
    subplots_labels = ['a','b','c','d','e','f','g','h','i']
    for idx,w_c in enumerate(words_all):
        row = idx // 3
        col = idx % 3
        for w in w_c: #[::3]
            word_d = data.get(w)
            date = []
            rank = []
            freq = []
            x = []
            if word_d is None:
                continue
            else:
                for item in word_d:
                    date.append(item[-1])
                    rank.append(item[1])
                    freq.append(item[2])
                    x.append(date_str[item[-1]])
                max_y = max(freq)
                max_idx = x[freq.index(max_y)]
                # max_date = date_str[date[max_idx]]
                # date_r  = list(reversed(date))
                # rank_r = list(reversed(rank))
                # smoother.smooth(freq)
                # emo_v_all_sm = smoother.smooth_data.squeeze(0)
                y_av = moving_average(freq,50)
                axes[row,col].set_yscale('log')
                axes[row,col].plot(x,freq,color='gray',linewidth=0.7,alpha=0.3)
                axes[row,col].plot(x,y_av,label=w)

                axes[row,col].scatter(max_idx,max_y,s=20)

        axes[row,col].set_xticks(date_x_idx)
        axes[row,col].set_xticklabels(date_x_label,fontsize=12)
        axes[row,col].text(-0.1, 1.05, string.ascii_lowercase[idx], transform=axes[row,col].transAxes, size=20, weight='bold')
        axes[row,col].tick_params(labelsize=12)
        axes[row,col].legend(loc='best',fontsize=10,framealpha=0.5,frameon=False)
        axes[row,col].spines['top'].set_linewidth(2)
        axes[row,col].spines['bottom'].set_linewidth(2)
        axes[row,col].spines['left'].set_linewidth(2)
        axes[row,col].spines['right'].set_linewidth(2)
    # axes.format(abc=True,abcstyle='(A)',abcsize=12,abcloc='ul')
    plt.subplots_adjust(left=None,bottom=None,top=None,right=None,wspace=0.2,hspace=0.3)
    plt.savefig('figure_res/ngrams_date0912.pdf',dip=300,bbox_inches='tight')
    plt.savefig('figure_res/ngrams_date0912.svg',dip=300,bbox_inches='tight')
    plt.savefig('figure_res/ngrams_date0912.png',dip=300,bbox_inches='tight')
    print('done')