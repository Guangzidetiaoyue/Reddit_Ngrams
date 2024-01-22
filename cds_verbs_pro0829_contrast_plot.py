from pytrends.request import TrendReq
from datetime import datetime
import pandas as pd
import json
from matplotlib import pyplot as plt
import matplotlib.ticker as mtick
import string
from tsmoothie.smoother import LowessSmoother
import matplotlib
matplotlib.rcParams['font.sans-serif'] = ['serif']
smoother = LowessSmoother(smooth_fraction=0.2, iterations=1)

color_l = ['#e789c3','#cc4ec6','#66c2a4','#8d9fca']
color_b = ['#fae7f3','#f5dcf4','#e0f3ed','#8d9fa9']
words_ob = [
    'COVID-19',
    'unemployment',
    'BLM',
    'Black Lives Matter',
    'metaverse',
    'NFT',
    'populism',
    'Genshin',
    'shooting',
    'mask',
    'vaccine',
    'rightwing',
    'pollution',
    'strike',
    'China',
    'nuclear'
]
platform_s = ['Reddit','Twitter','Google Trends','Cable TV news']
platform = ['reddit','twitter','gtrends','tvnews']
data_contrast = pd.read_csv('ngrams_res/platform19_21.csv')
dates = data_contrast[data_contrast['ngram']=='BLM']['date'].to_list()
dates_idx = [dates.index(i) for i in dates[::26]] +[dates.index(dates[-1])]
dates_label = [i[2:] for i in dates[::26]]+[dates[-1][2:]]
fig, axes = plt.subplots(4,4,sharex='col',figsize=(16,18)) #
for idx,w in enumerate(words_ob):
    row = idx // 4
    col = idx % 4
    axes[row,col].text(-0.1, 1.08, string.ascii_lowercase[idx], transform=axes[row,col].transAxes, size=20, weight='bold')
    for i,p in enumerate(platform):
        data_plot_y = (data_contrast[data_contrast['ngram']==w][p]).to_list()
        dates = data_contrast[data_contrast['ngram']==w]['date'].to_list()
        time = [t for t in range(0,len(dates))]
        smoother.smooth(data_plot_y)
        low, up = smoother.get_intervals('confidence_interval')
        data_plot_y = smoother.smooth_data.squeeze(0)

        axes[row,col].plot(time,data_plot_y,linewidth=2,label=platform_s[i]) #y[i] ,c=color_l[i]
            # axes[row,col].scatter(time,emojis_dis_y_np[i],s=1,alpha=0.2,linewidths=1)
        # axes[row,col].plot(time,low[0],c=color_l[i],linewidth=0.2)
        # axes[row,col].plot(time,up[0],c=color_l[i],linewidth=0.2)
        # axes[row,col].fill_between(range(len(smoother.data[0])), low[0], up[0], alpha=0.5,facecolor=color_b[i])
        axes[row,col].axhline(y=50,linestyle='--',linewidth=1.2,c='gray')
        axes[row,col].set_ylim(0,100)
        axes[row,col].set_yticks([0,50,100])
        axes[row,col].set_yticklabels(['0','50','100'])
        axes[row,col].yaxis.set_major_formatter(mtick.FormatStrFormatter('%.0f'))
        axes[row,col].tick_params(bottom=True,top=False,left=True,right=False)
        axes[row,col].set_xticks(dates_idx)
        axes[row,col].set_xticklabels(dates_label,rotation=36,fontsize=10)
        axes[row,col].xaxis.label.set_size(16)
        
        # axes[row,col].set_ylim(-0.3,0.25)
        axes[row,col].spines['top'].set_linewidth(2)
        axes[row,col].spines['bottom'].set_linewidth(2)
        axes[row,col].spines['left'].set_linewidth(2)
        axes[row,col].spines['right'].set_linewidth(2)
        axes[row,col].set_title(w,fontsize=16)
        if row == 0 and col == 0:
            axes[row,col].legend(loc='upper left',fontsize=10,framealpha=0.5,frameon=False)
plt.subplots_adjust(left=None,bottom=None,top=None,right=None,wspace=0.2,hspace=0.3)
plt.savefig('figure_res/compare_date0912.pdf',dip=300,bbox_inches='tight')
plt.savefig('figure_res/compare_date0912.svg',dip=300,bbox_inches='tight')
plt.savefig('figure_res/compare_date0912.png',dip=300,bbox_inches='tight')
print('done')
