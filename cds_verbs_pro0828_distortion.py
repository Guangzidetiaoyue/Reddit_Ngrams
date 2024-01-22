import os,json
import gzip,argparse
from collections import defaultdict
import pandas as pd
import numpy as np
from matplotlib import pyplot as plt
from tsmoothie.smoother import LowessSmoother
smoother = LowessSmoother(smooth_fraction=0.2, iterations=1)
from sklearn.preprocessing import StandardScaler
import string

scaler = StandardScaler()

def moving_average(interval,windowsize):
    window = np.ones(int(windowsize))/float(windowsize)
    re = np.convolve(interval,window,'same')
    return re

if __name__ == '__main__':
    Catastrophizing = ['will go wrong', 'will end', 'will be impossible', 'will not happen', 'will be terrible', 'will be horrible','will never end', 'will not end'] #'will fail', 
    Dichotomous_Reasoning = ['only', 'every', 'everyone', 'everybody', 'everything', 'everywhere', 'always', 'perfect', 'the best', 'all', 'not a single', 'no one', 'nobody', 'nothing', 'nowhere', 'never', 'worthless', 'the worst', 'neither', 'nor', 'either or', 'black or white', 'ever']
    Disqualifying = ['great but', 'good but', 'OK but', 'not that great', 'not that good', 'it was not', 'not all that', 'fine but', 'acceptable but', 'great yet', 'good yet', 'OK yet', 'fine yet', 'acceptable yet']
    Emotional = ['but I feel', 'since I feel', 'because I feel', 'but it feels', 'since it feels', 'because it feels', 'still feels']
    Fortune_telling = ['I will not', 'we will not', 'you will not', 'they will not', 'it will not', 'that will not', 'he will not', 'she will not']
    Labeling_mislabeling = ['I am a', 'he is a', 'she is a', 'they are a', 'it is a', 'that is a', 'sucks at', 'suck at',' I never', 'he never', 'she never', 'you never', 'we never', 'they never', 'I am an', 'he is an', 'she is an', 'they are an', 'it is an', 'that is an', 'a burden', 'a complete', 'a completely', 'a huge', 'a loser', 'a major', 'a total', 'a totally', 'a weak', 'an absolute', 'an utter', 'a bad', 'a broken', 'a damaged', 'a helpless', 'a hopeless', 'an incompetent', 'a toxic', 'an ugly', 'an undesirable', 'an unlovable', 'a worthless', 'a horrible', 'a terrible']
    Magnification_Minimization = ['worst', 'best', 'not important', 'not count', 'not matter', 'no matter', 'the only thing', 'the one thing'] #'war'
    Mental_Filtering = ['I see only', 'all I see', 'can only think', 'nothing good', 'nothing right', 'completely bad', 'completely wrong', 'only the bad', 'only the worst', 'if I just', 'if I only', 'if it just', 'if it only']
    Mindreading = ['everyone believes', 'everyone knows', 'everyone thinks', 'everyone will believe', 'everyone will know', 'everyone will think', 'nobody believes', 'nobody knows', 'nobody thinks', 'nobody will believe', 'nobody will know', 'nobody will think', 'he believes', 'he knows', 'he thinks', 'he will believe', 'he will know', 'he will think', 'she believes', 'she knows', 'she thinks', 'she will believe', 'she will know', 'she will think', 'they believe', 'they know', 'they think', 'they will believe', 'they will know', 'they will think', 'we believe', 'we know', 'we think', 'we will believe', 'we will know', 'we will think', 'you believe', 'you know', 'you think', 'you will believe', 'you will know', 'you will think']
    Overgeneralizing =['all of them', 'all the time', 'always happens', 'always like', 'happens every time', 'completely', 'no one ever', 'nobody ever', 'I always', 'you always', 'he always', 'she always', 'they always', 'I am always', 'you are always', 'he is always', 'she is always', 'they are always']
    Personalizing =['all me', 'all my', 'because I', 'because my', 'because of my', 'because of me', 'I am responsible', 'blame me', 'I caused', 'I feel responsible', 'all my doing', 'all my fault', 'my bad', 'my responsibility']
    Should_statements = ['should', 'ought', 'must', 'have to', 'has to']
    
    words_all = [Catastrophizing,Dichotomous_Reasoning,Disqualifying,Emotional,Fortune_telling,Labeling_mislabeling,Magnification_Minimization,Mental_Filtering,Mindreading,Overgeneralizing,Personalizing,Should_statements]
    titles_all = ['Catastrophizing','Dichotomous','Disqualifying','Emotional','Fortune_telling','Labeling','Magnification','Mental','Mindreading','Overgeneralizing','Personalizing','Should']
    # l=0
    # for item in words_all:
    #     l += len(item)
    fig, axes = plt.subplots(3,4,figsize=(16,20),sharex='col') #sharex='col',

    dates = pd.DataFrame({'date':pd.date_range('2005-12-01','2021-12-31',freq='D')})
    date_str = {}
    for i in range(len(dates)):
        date_str[dates.date.dt.date[i].strftime('%Y-%m-%d') ] = i
    date_x_label = ['2010','2012','2014','2016','2018','2020','2022'] #'2006','2008',
    date_x_idx = []
    for d_label in date_x_label:
        if d_label == '2022':
            d_flag = '2021-12-31'
        else:
            d_flag = d_label+'-01-01'
        date_x_idx.append(date_str[d_flag])

    res_files = ['ngrams_res/ngrams_res_0830_color_emotion_activity_dep.json','twitter_compare0908/twitter_data.json']
    data_res_all = []
    for data_idx, res_file in enumerate(res_files):
        if data_idx == 0:
            word_flag = 'reddit'
        if data_idx == 1:
            word_flag = 'twitter'

        with open(res_file, 'r') as f:
            data = json.load(f)

        all_avg_dict = defaultdict(list)
        date_all = []
        word_0 = data.get('.')
        word_1 = data.get('!')
        word_2 = data.get('?')
        data_p0 = defaultdict(list)
        data_p1 = defaultdict(list)
        data_p2 = defaultdict(list)
        for item in word_0:
            data_p0[item[-1]].append(item[0])
        for item in word_1:
            data_p1[item[-1]].append(item[0])
        for item in word_2:
            data_p2[item[-1]].append(item[0])

        for idx,w_c in enumerate(words_all):
            title_label = titles_all[idx]

            row = idx // 4
            col = idx % 4
            data_dict = defaultdict(list)
            avgdict = []
            date = []

            for w in w_c: #[::3]
                word_d = data.get(w)
                rank = []
                freq = []
                if word_d is None:
                    print(w)
                    continue
                else:
                    for item in word_d:
                        count = item[0]
                        date_t = item[-1]
                        try:
                            if date_t <= '2021-12-31' and date_t >= '2010-01-01':
                                p_sum = data_p0[date_t][0] + data_p1[date_t][0] + data_p2[date_t][0]
                                data_dict[date_t].append(count/p_sum)
                                all_avg_dict[date_t].append(count/p_sum)
                            else:
                                continue
                        except:
                            print('error:',date_t,w)
            for key in sorted(data_dict.keys()):
                v = data_dict[key]
                avgdict.append(sum(v) / len(v))
                date.append(date_str[key])

            avgdict_np = np.array(avgdict)
            data_res_scaled = (avgdict_np-np.min(avgdict_np))/(max(avgdict_np)-min(avgdict_np))

            smoother.smooth(data_res_scaled)
            low, up = smoother.get_intervals('confidence_interval')
            data_plot_y = smoother.smooth_data.squeeze(0)

            axes[row,col].set_title(title_label,fontsize=15)
            axes[row,col].set_yscale('log')
            if row==0 and col==0:
                axes[row,col].set_ylim(0.0005,0.15)
            elif row==1 and col==0:
                axes[row,col].set_ylim(0.02,1)
            elif row==1 and col==3:
                axes[row,col].set_ylim(0.02,1)
            elif row==0 and col==3:
                axes[row,col].set_ylim(0.02,1)
            elif row==2 and col==3:
                axes[row,col].set_ylim(0.1,1)
            elif row==2 and col==2:
                axes[row,col].set_ylim(0.1,1)
            else:
                axes[row,col].set_ylim(0.05,1)
            axes[row,col].scatter(date,data_res_scaled,color='gray',alpha=0.3,s=0.5) #date[:-1493],avgdict[:-1493] avgdict
            axes[row,col].plot(date,data_plot_y,label=word_flag,linewidth=2.5) #date[:-1493],avgdict[:-1493] avgdict
            axes[row,col].fill_between(date, low[0], up[0], alpha=0.5)
            # axes[row,col].set_xticks(date_x_idx)
            axes[row,col].set_xticks(date_x_idx)
            axes[row,col].set_xticklabels(date_x_label,fontsize=12)
            axes[row,col].tick_params(labelsize=12)
            axes[row,col].spines['top'].set_linewidth(1.2)
            axes[row,col].spines['bottom'].set_linewidth(1.2)
            axes[row,col].spines['left'].set_linewidth(1.2)
            axes[row,col].spines['right'].set_linewidth(1.2)
            if data_idx == 0:
                axes[row,col].text(-0.1, 1.1, string.ascii_lowercase[idx], transform=axes[row,col].transAxes, size=12, weight='bold')
            if row == 0 and col == 0:
                axes[row,col].legend(loc='best',fontsize=8,framealpha=0.5)
        data_res_all.append(all_avg_dict)
    axes[0,0].set_ylabel('Normalized value',fontsize=15)
    axes[1,0].set_ylabel('Normalized value',fontsize=15)
    axes[2,0].set_ylabel('Normalized value',fontsize=15)
    plt.subplots_adjust(left=None,bottom=None,top=None,right=None,wspace=0.25,hspace=0.2)
    plt.savefig('figure_res/ngrams_distortion.pdf',dip=300,bbox_inches='tight')
    plt.close()
    for data_id,all_avg_item in enumerate(data_res_all):
        if data_id == 0:
            word_flag = 'reddit'
        if data_id == 1:
            word_flag = 'twitter'
        all_avg = []
        date_all = []
        for key in sorted(all_avg_item.keys()):
            v = all_avg_item[key]
        # for k,v in all_avg_item.items():
            all_avg.append(sum(v) / len(v))
            date_all.append(date_str[key])
        date_all_np = np.array(all_avg)
        date_all_scaled = (date_all_np-np.min(date_all_np))/(max(date_all_np)-min(date_all_np))
        smoother.smooth(date_all_scaled)
        low, up = smoother.get_intervals('confidence_interval')
        data_all_plot_y = smoother.smooth_data.squeeze(0)
        plt.scatter(date_all,date_all_scaled,color='gray',alpha=0.5,s=0.5) #label=w,
        plt.plot(date_all,data_all_plot_y,linewidth=2.5,label=word_flag)
        plt.fill_between(date_all, low[0], up[0], alpha=0.5)
        plt.ylim(0,0.7)
        plt.xticks(date_x_idx,date_x_label,fontsize=12)
    plt.ylabel('Normalized value',fontsize=15)
    plt.legend(loc='best',fontsize=8,framealpha=0.5)
    plt.savefig('figure_res/ngrams_distortion_all_0912.pdf',dip=300,bbox_inches='tight')
    print('done')