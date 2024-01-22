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

    # fig, axes = plt.subplots(3,4,figsize=(16,20),sharex='col') #sharex='col',
    fig1=plt.figure(figsize=(8,27))
    spec=fig1.add_gridspec(nrows=2,ncols=1,width_ratios=[1],height_ratios=[4,6],hspace=0.2,wspace=0.2)

    dates = pd.DataFrame({'date':pd.date_range('2005-12-01','2021-12-31',freq='D')})
    date_str = {}
    for i in range(len(dates)):
        date_str[dates.date.dt.date[i].strftime('%Y-%m-%d') ] = i
    date_x_label = ['2010','2014','2018','2022'] #'2006','2008',
    date_x_idx = []
    for d_label in date_x_label:
        if len(d_label) > 0:
            if d_label == '2022':
                d_flag = '2021-12-31'
            else:
                d_flag = d_label+'-01-01'
        date_x_idx.append(date_str[d_flag])

    res_files = ['ngrams_res/ngrams_res_0830_color_emotion_activity_dep.json','twitter_compare0908/twitter_data.json']
    data_res_all = []

    inner = spec[1,0].subgridspec(3,4,hspace=0.35,wspace=0.35,width_ratios=[0.1,0.1,0.1,0.1],height_ratios=[0.1,0.1,0.1])
    inner_all = spec[0,0].subgridspec(1,1,hspace=0.2,wspace=0.4,width_ratios=[1],height_ratios=[5])

    word_flag_0 = 'Reddit'
    word_flag_1 = 'Twitter'

    with open(res_files[0], 'r') as f0:
        data_0 = json.load(f0)
    with open(res_files[1], 'r') as f1:
        data_1 = json.load(f1)

    all_avg_dict = defaultdict(list)
    date_all = []
    word_0 = data_0.get('.')
    word_1 = data_0.get('!')
    word_2 = data_0.get('?')
    data_p0 = defaultdict(list)
    data_p1 = defaultdict(list)
    data_p2 = defaultdict(list)
    
    all_avg_dict_1 = defaultdict(list)
    word_01 = data_1.get('.')
    word_11 = data_1.get('!')
    word_21 = data_1.get('?')
    data_p01 = defaultdict(list)
    data_p11 = defaultdict(list)
    data_p21 = defaultdict(list)
    
    for item in word_0:
        data_p0[item[-1]].append(item[0])
    for item in word_1:
        data_p1[item[-1]].append(item[0])
    for item in word_2:
        data_p2[item[-1]].append(item[0])

    for item in word_01:
        data_p01[item[-1]].append(item[0])
    for item in word_11:
        data_p11[item[-1]].append(item[0])
    for item in word_21:
        data_p21[item[-1]].append(item[0])

    for idx,w_c in enumerate(words_all):
        title_label = titles_all[idx]

        row = idx // 4
        col = idx % 4
        data_dict = defaultdict(list)
        avgdict = []
        date = []

        data_dict_1 = defaultdict(list)
        avgdict_1 = []
        date_1 = []

        for w in w_c: #[::3]
            word_d = data_0.get(w)
            word_d_1 = data_1.get(w)

            if word_d is None or word_d_1 is None:
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
                for item_1 in word_d_1:
                    count_1 = item_1[0]
                    date_t_1 = item_1[-1]
                    try:
                        if date_t_1 <= '2021-12-31' and date_t_1 >= '2010-01-01':
                            p_sum_1 = data_p01[date_t_1][0] + data_p11[date_t_1][0] + data_p21[date_t_1][0]
                            data_dict_1[date_t_1].append(count_1/p_sum_1)
                            all_avg_dict_1[date_t_1].append(count_1/p_sum_1)
                        else:
                            continue
                    except:
                        print('error:',date_t_1,w)
        for key in sorted(data_dict.keys()):
            v = data_dict[key]
            avgdict.append(sum(v) / len(v))
            date.append(date_str[key])

        for key in sorted(data_dict_1.keys()):
            v = data_dict_1[key]
            avgdict_1.append(sum(v) / len(v))
            date_1.append(date_str[key])

        avgdict_np = np.array(avgdict)
        data_res_scaled = (avgdict_np-np.min(avgdict_np))/(max(avgdict_np)-min(avgdict_np))
        smoother.smooth(data_res_scaled)
        low, up = smoother.get_intervals('confidence_interval')
        data_plot_y = smoother.smooth_data.squeeze(0)

        avgdict_np_1 = np.array(avgdict_1)
        data_res_scaled_1 = (avgdict_np_1-np.min(avgdict_np_1))/(max(avgdict_np_1)-min(avgdict_np_1))
        smoother.smooth(data_res_scaled_1)
        low_1, up_1 = smoother.get_intervals('confidence_interval')
        data_plot_y_1 = smoother.smooth_data.squeeze(0)

        axes =fig1.add_subplot(inner[row,col])
        
        axes.set_yscale('log')

        axes.scatter(date,data_res_scaled,color='gray',alpha=0.3,s=0.5) #date[:-1493],avgdict[:-1493] avgdict
        axes.plot(date,data_plot_y,label=word_flag_0,linewidth=2.5) #date[:-1493],avgdict[:-1493] avgdict
        axes.scatter(date_1,data_res_scaled_1,color='gray',alpha=0.3,s=0.5) #date[:-1493],avgdict[:-1493] avgdict
        axes.plot(date_1,data_plot_y_1,label=word_flag_1,linewidth=2.5) #date[:-1493],avgdict[:-1493] avgdict

        axes.fill_between(date, low[0], up[0], alpha=0.5)
        axes.fill_between(date_1, low_1[0], up_1[0], alpha=0.5)
        # axes.set_xticks(date_x_idx)
        
        axes.tick_params(labelsize=10)
        if row != 2:
            axes.set_xticks(date_x_idx)
            axes.set_xticklabels(['']*len(axes.get_xticks()))
        axes.spines['top'].set_linewidth(1.2)
        axes.spines['bottom'].set_linewidth(1.2)
        axes.spines['left'].set_linewidth(1.2)
        axes.spines['right'].set_linewidth(1.2)
        axes.set_title(title_label,fontsize=10)
        axes.text(-0.1, 1.1, string.ascii_lowercase[idx+1], transform=axes.transAxes, size=12, weight='bold')
        if row == 2 and col == 3:
            axes.legend(loc='best',fontsize=8,framealpha=0.5,frameon=False)
        if row == 0 and col == 0:
            axes.set_ylabel('Normalized value',fontsize=10)
        if row == 1 and col == 0:
            axes.set_ylabel('Normalized value',fontsize=10)
        if row == 2 and col == 0:
            axes.set_ylabel('Normalized value',fontsize=10)
            axes.set_xticks(date_x_idx)
            axes.set_xticklabels(date_x_label,fontsize=8)
        if  row == 2 and col == 1 or row == 2 and col == 2 or row == 2 and col == 3:
            axes.set_xticks(date_x_idx)
            axes.set_xticklabels(date_x_label,fontsize=8)

        if row==0 and col==0:
            axes.set_ylim(0.0005,0.15)
        elif row==1 and col==0:
            axes.set_ylim(0.02,1)
        elif row==1 and col==3:
            axes.set_ylim(0.02,1)
        elif row==0 and col==3:
            axes.set_ylim(0.02,1)
        elif row==2 and col==3:
            axes.set_ylim(0.08,1)
        elif row==2 and col==2:
            axes.set_ylim(0.08,1)
        else:
            axes.set_ylim(0.05,1)
    data_res_all.append(all_avg_dict)
    data_res_all.append(all_avg_dict_1)
    axes_all =fig1.add_subplot(inner_all[0,0])
    for data_id,all_avg_item in enumerate(data_res_all):
        if data_id == 0:
            word_flag = 'Reddit'
        if data_id == 1:
            word_flag = 'Twitter'
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
        axes_all.scatter(date_all,date_all_scaled,color='gray',alpha=0.5,s=0.5) #label=w,
        axes_all.plot(date_all,data_all_plot_y,linewidth=2.5,label=word_flag)
        axes_all.fill_between(date_all, low[0], up[0], alpha=0.5)
        axes_all.set_ylim(0,0.7)
        axes_all.set_xticks(date_x_idx)
        axes_all.set_xticklabels(date_x_label,fontsize=12)
        axes_all.text(-4.2, 7, string.ascii_lowercase[0], transform=axes.transAxes, size=12, weight='bold')
    axes_all.set_title('Cognitive distortion schemata n-gram prevalence',fontsize=15,y=1.05)
    axes_all.legend(loc='best',fontsize=12,framealpha=0.5,frameon=False)
    axes_all.spines['top'].set_linewidth(1.2)
    axes_all.spines['bottom'].set_linewidth(1.2)
    axes_all.spines['left'].set_linewidth(1.2)
    axes_all.spines['right'].set_linewidth(1.2)
    axes_all.set_ylabel('Normalized value',fontsize=15)
    plt.savefig('figure_res/ngrams_distortion_all_1103.pdf',dip=300,bbox_inches='tight')
    plt.savefig('figure_res/ngrams_distortion_all_1103.svg',dip=300,bbox_inches='tight')
    plt.savefig('figure_res/ngrams_distortion_all_1103.png',dip=300,bbox_inches='tight')
    print('done')