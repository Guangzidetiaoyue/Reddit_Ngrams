
from rtd_utils import rank_turbulence_divergence
import jsonlines
import argparse,os
import gzip
import seaborn as sns
from matplotlib import pyplot as plt
import numpy as np
import string
from matplotlib.font_manager import FontProperties
font = FontProperties()
# font.set_weight('bold')
def date_data(date_file):
    words = {}
    with gzip.open(date_file,'r') as f:
        while True:
            line_b = f.readline()
            line = line_b.decode()
            if line.startswith('ngram\tcount\trank\tfreq'):
                continue
            elif not line:
                break
            else:
                words[line.strip().split('\t')[0]] = int(line.strip().split('\t')[1])
    return words
colors0 = ['#FFAEAF','#93BE6C','#F4B184','#CBA1D8','#A1D99C']
        ##'#DFEBF7', ,'#E5F5E0','#9ECBE1','#F2C479','#A5C8F6','#FFDDDC''#F08180',#FBE5D6
            #93BE6C,#AE9DC7,#CBA1D8
colors1 = ['#9DC4E6','#D18CB8','#85D4B8','#8D9FD1','#F2C479']

if __name__ == '__main__':

    data_path = 'rtd_res_everyday/rtd_res.jsonl'
    dates = ['2012-06-04','2012-08-06','2014-07-01','2014-09-01','2016-02-21','2016-12-03','2017-11-01','2018-02-15','2020-01-01','2021-01-07'] #'2012-06-02',
    words = []
    values = []
    with jsonlines.open(data_path,'r') as fin:
        for item in fin:
            date_flag = list(item.keys())[0].split('_')[1]
            if date_flag in dates:
                w = list(item.values())[0]['words'][0:15]
                v = list(item.values())[0]['value'][0:15]
                w.reverse()
                v.reverse()
                words.append(w)
                values.append(v)

    fig, axes = plt.subplots(1,5,sharex='col',figsize=(30,8)) #
    for idx in range(5):
        row = 0
        col = idx
        axes[idx].text(-0.1, 1.05, string.ascii_lowercase[idx], transform=axes[idx].transAxes, size=20, weight='bold')
        axes[idx].text(0.15, 1.06, 'Divergence contribution', transform=axes[idx].transAxes,size=12, weight='bold')
        wp0 = words[idx*2]
        vp0 = values[idx*2]
        wp1 = words[idx*2+1]
        vp1 = values[idx*2+1]
        date_l = dates[idx*2]
        date_r = dates[idx*2+1]
        axes[idx].barh(range(len(wp0)),-np.array(vp0),color=colors0[idx])
        axes[idx].barh(range(len(wp1)),np.array(vp1),color=colors1[idx])
        index = list(range(len(wp0)))
        index.reverse()
        for i in index:
            # axes[idx].text(-0.05, 0.05, string.ascii_lowercase[idx], transform=axes[idx].transAxes, size=20, weight='bold')
            axes[idx].text(-0.01, i, wp0[i],ha='right', va='center',weight='bold',alpha=0.6)
            axes[idx].text(-0.02, -1.5, date_l,ha='right', va='center',size=12,weight='bold')
            axes[idx].text(0.01, i, wp1[i],ha='left', va='center',weight='bold',alpha=0.6)
            axes[idx].text(0.02, -1.5, date_r,ha='left', va='center',size=12,weight='bold')
        axes[idx].axvline(x=0,linestyle='--',linewidth=1.2,c='gray')
        axes[idx].xaxis.set_ticks_position('top')
        axes[idx].yaxis.set_ticks_position('none')

        axes[idx].tick_params(top=True,right=False,left=False,bottom=False,direction='out',width=1.5,labelsize=11)
        if idx == 1 or idx == 3 or idx == 4:
            axes[idx].set_xticks([-0.1,0,0.1])
            axes[idx].set_xticklabels([0.1,0.0,0.1],fontproperties=font)
        else:
            axes[idx].set_xticks([-0.25,-0.1,0,0.1])
            axes[idx].set_xticklabels([0.25,0.1,0.0,0.1],fontproperties=font)
        # axes[idx].set_yticks([])
        axes[idx].set_yticklabels([])
        # axes[idx].set_ylim(-0.3,0.25)
        if idx == 0:
            axes[idx].spines['top'].set_linewidth(1.5)
            axes[idx].spines['bottom'].set_linewidth(1.5)
            axes[idx].spines['right'].set_visible(False)
            # axes[idx].yaxis.set_ticks_position('left')
            axes[idx].spines['left'].set_visible(False)
            lk = list(range(len(wp0)))
            axes[idx].set_yticks(lk)
            lkk = list(range(1,len(wp0)+1))
            lkk.reverse()
            axes[idx].set_yticklabels(lkk,fontproperties=font)
            axes[idx].set_ylabel('Rank of top-15 topics',fontsize=20,weight="bold")
        else:
            axes[idx].spines['top'].set_linewidth(1.5)
            axes[idx].spines['bottom'].set_linewidth(1.5)
            axes[idx].spines['left'].set_visible(False)
            axes[idx].spines['right'].set_visible(False)
        # axes[idx].spines['left'].set_linewidth(1.5)
        # axes[idx].spines['right'].set_linewidth(1.5)
        # axes[idx].set_title(w,fontsize=16)
    
    # axes[0].axvline(x=-0.25,linestyle='-',linewidth=1.2,c='gray')
    plt.tight_layout()
    plt.savefig('figure_res/day_topic_1123.pdf',dip=300,bbox_inches='tight')
    plt.savefig('figure_res/day_topic_1123.png',dip=300,bbox_inches='tight')
    plt.savefig('figure_res/day_topic_1123.svg',dip=300,bbox_inches='tight')
    # plt.show()
    # plt.tight_layout()
    print('done')