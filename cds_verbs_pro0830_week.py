from pytrends.request import TrendReq
from datetime import datetime
import pandas as pd
import json
import numpy as np
from matplotlib import pyplot as plt
import matplotlib.ticker as mtick
from tsmoothie.smoother import LowessSmoother
from collections import defaultdict
from datetime import datetime
import seaborn as sns
from matplotlib.colors import ListedColormap,LinearSegmentedColormap
from shap.plots.colors  import _colorconv
import matplotlib.colors as mcolors
import matplotlib.colorbar as colorbar
from tsmoothie.smoother import LowessSmoother
import string
from mpl_toolkits.axes_grid1.inset_locator import inset_axes
smoother = LowessSmoother(smooth_fraction=0.2, iterations=1)
from sklearn.preprocessing import StandardScaler
scaler = StandardScaler()
def moving_average(interval,windowsize):
    window = np.ones(int(windowsize))/float(windowsize)
    re = np.convolve(interval,window,'same')
    return re

def lch2rgb(x):
    return _colorconv.lab2rgb(_colorconv.lch2lab([[x]]))[0][0]
# blue_lch = [54., 70., 4.6588]
blue_lch = [90., 0., 0]
l_mid = 40.
red_lch = [60., 80., 1.0 + 2* np.pi] # [60., 80., 18 + 2* np.pi] #[60., 90., 0.35470565 + 2* np.pi]
gray_lch = [90., 0., 0.]
blue_rgb = lch2rgb(blue_lch)
red_rgb = lch2rgb(red_lch)
gray_rgb = lch2rgb(gray_lch)
white_rgb = np.array([1.,1.,1.])
colors = []
for alpha in np.linspace(1, 0, 100):
    c = blue_rgb * alpha + (1 - alpha) * white_rgb
    colors.append(c)
for alpha in np.linspace(0, 1, 100):
    c = red_rgb * alpha + (1 - alpha) * white_rgb
    colors.append(c)
newcmp = LinearSegmentedColormap.from_list('chaos', colors)



# cmap = plt.cm.get_cmap('magma_r')
# cmaplist = [cmap(i) for i in range(cmap.N)]
# cmaplist[0] = (1, 1, 1, 1.0)  # force the first color entry to be white
# cmap = mcolors.LinearSegmentedColormap.from_list(None, cmaplist, cmap.N)
# norm = mcolors.BoundaryNorm(bounds, cmap.N)
# # cmap = sns.diverging_palette(200,20,sep=20,as_cmap=True)
words_emotion = ['anger','envy','fear','gloomy','grief','happy','hate','hope','joy','pity','proud','regret','sad','shame','surprised','worry','merry','desire','good','like','love','bad','want','happiness']

words_el = ['PTSD','depression','suicide','psychology','insomnia','stress','anxiety','schizophrenia','phobias','ASD','anorexia','bipolar']#['anger','happy','fear','sad','love','proud','shame','worry']
words_et = ['Friday','Thursday','Biden','LGBT','PTSD','ASD','Alphago','blockchain','December','insomnia','stress','anxiety','schizophrenia','phobias','ASD','anorexia','bipolar','anger','envy','fear','gloomy','grief','happy','hate','hope','joy','pity','proud','regret','sad','shame','surprised','worry','merry','desire','good','like','love','bad','want','happiness'] #'work',
words_scaled = ['sex','shopping','breakfast','sleep','lunch','dinner',
                'stress','anxiety','depression','suicide','insomnia','schizophrenia',
                'bipolar','PTSD','ASD','anorexia','phobias','envy',
                'happy','hate','hope','joy','proud','sad',
                'desire','good','like','love','bad','want',
                'happiness','regret','worry','fear','anger','pity',
                'December','Friday','Thursday','Biden','LGBT','Alphago',
                'Higgs','blockchain','red','blue','yellow','green']
with open ('ngrams_res/ngrams_res_0830_color_emotion_activity_dep.json', 'r') as f:
    data = json.load(f)
dates = pd.DataFrame({'date':pd.date_range('2005-12-01','2021-12-31',freq='D')})
date_str = {}
for i in range(len(dates)):
    date_str[dates.date.dt.date[i].strftime('%Y-%m-%d') ] = i

date_start =  '20100104' #'20100104' #'20190107'#
date_end = '20211226'
days_t = (datetime.strptime(date_end,"%Y%m%d")-datetime.strptime(date_start,"%Y%m%d")).days

# fig, axes = plt.subplots(3,3,figsize=(16,16))

fig1=plt.figure(figsize=(18,16))
spec=fig1.add_gridspec(nrows=3,ncols=2,width_ratios=[1,1],height_ratios=[5,5,5],hspace=0.4,wspace=0.2)

# date_x_label = ['2010','2011','2012','2013','2014','2015','2016','2017','2018','2019','2020','2021','2022']
date_x_label = ['2010','','2012','','2014','','2016','','2018','','2020','','2022']
date_y_label = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun']
date_x_idx = []
# for d_label in date_x_label:
#     if len(d_label) > 0:
#         d_flag = d_label+'-01-01'
#         date_x_idx.append(date_str[d_flag])

idx = 0
word_flag = ''
for i,w in enumerate(words_scaled):
    idx_label = i % 6
    idx_int = i // 6
    word_flag = w
    if idx_int != 0 and idx_label == 0:
        plt.subplots_adjust(left=None,bottom=None,top=None,right=None,wspace=0.2,hspace=0.2)
        plt.savefig('figure_res/word_week_1103_{}.pdf'.format(word_flag),dip=300,bbox_inches='tight')
        plt.savefig('figure_res/word_week_1103_{}.svg'.format(word_flag),dip=300,bbox_inches='tight')
        plt.savefig('figure_res/word_week_1103_{}.png'.format(word_flag),dip=300,bbox_inches='tight')
        plt.close()
        idx = 0
        fig1=plt.figure(figsize=(18,16))
        spec=fig1.add_gridspec(nrows=3,ncols=2,width_ratios=[1,1],height_ratios=[5,5,5],hspace=0.4,wspace=0.2)
        row = idx // 2
        col = idx % 2
        idx += 1
        # row_b = row // 2
        # col_b = col % 2

        data_res_freq = np.zeros((7,(days_t//7+1)))
        data_res_rank = np.zeros((7,(days_t//7+1)))
        word_d = data.get(w)
        freq = []
        if word_d is None:
            continue
        else:
            for item in word_d:
                date_temp = item[-1].replace('-','')
                if date_temp > date_end or date_temp < date_start:
                    continue
                else:
                    rank = item[1]
                    freq = item[-2]
                    day_sep = (datetime.strptime(date_temp,"%Y%m%d")-datetime.strptime(date_start,"%Y%m%d")).days
                    week_n = day_sep // 7
                    week_r = day_sep % 7
                    data_res_freq[week_r,week_n] = freq
                    data_res_rank[week_r,week_n] = rank

        data_res_scaled = scaler.fit_transform(data_res_freq)
        vmin, vmax = np.nanpercentile(data_res_scaled, [1, 99])
        bounds = np.linspace(vmin, vmax, 21)
        norm = mcolors.BoundaryNorm(bounds, newcmp.N)
        data_res_scaled_col = np.mean(data_res_freq, axis=0) # data_res_freq data_res_rank
        data_res_scaled_raw = np.mean(data_res_scaled, axis=1) #data_res_rank data_res_scaled

        inner = spec[row,col].subgridspec(2,2,hspace=0.1,wspace=0.05,width_ratios=[0.4,0.08],height_ratios=[5,5])
        ax =fig1.add_subplot(inner[0,0])
        cax = inset_axes(ax,
                width="20%",  # width: 40% of parent_bbox width
                height="10%",  # height: 10% of parent_bbox height
                loc='lower left',
                bbox_to_anchor=(0, 1.22, 1, 1),
                bbox_transform=ax.transAxes,
                borderpad=0,
                )
        sns.heatmap(data_res_scaled, cmap=newcmp,norm=norm,ax=ax,cbar_ax=cax,cbar_kws={'orientation': 'horizontal','ticks':[-1.5,0,1.5]})
        ax.set_title(w,fontsize=18,y=1.12)
        ax.axhline(y=1,c='black',lw=1.15)
        ax.axhline(y=2,c='black',lw=1.15)
        ax.axhline(y=3,c='black',lw=1.15)
        ax.axhline(y=4,c='black',lw=1.15)
        ax.axhline(y=5,c='black',lw=1.15)
        ax.axhline(y=6,c='black',lw=1.15)
        ax.set_yticks([0.5,1.5,2.5,3.5,4.5,5.5,6.5])
        ax.set_yticklabels(date_y_label,fontsize=12,rotation=0)
        ax.set_xticks([])
        ax.text(-0.08, 1.2, string.ascii_lowercase[idx_label], transform=ax.transAxes, size=20, weight='bold')
    
        # data_res_scaled_col = np.mean(data_res_freq, axis=0)
        ax1=fig1.add_subplot(inner[1,0])

        ax1.set_yscale('log')
        ax1.set_xlim(0,len(data_res_scaled_col))
        # ax1.set_ylim(0,0.2)
        for i in list(range(7)):
            ax1.scatter(range(0,len(data_res_freq[i])),data_res_freq[i],s=0.5,color='gray',alpha=0.5)
        ax1.plot(range(0,len(data_res_scaled_col)),data_res_scaled_col,linewidth=1.3,color='firebrick') #,alpha=0.8
        ax1.text(
                    1.09, -0.4, "↑\nMore", ha='center',
                    verticalalignment='center', transform=ax.transAxes, color='grey',
                fontsize=11)
        ax1.text(
                    1.09, -0.65, "Frequency", ha='center',
                    verticalalignment='center', transform=ax.transAxes,
                fontsize=11
                ) #color='grey',
        ax1.text(
                    1.09, -0.9, "Less\n↓", ha='center',
                    verticalalignment='center', transform=ax.transAxes, color='grey',
                fontsize=11
                )
        # ax1.plot(range(0,len(data_res_scaled_col)),data_res_scaled_col,color='royalblue',linewidth=1) #'orangered
        ax1.grid(True,axis='y',which="both")
        ax1.grid(True,axis='x',which="both")
        # ax1.yaxis.grid(True)
        # y_av = moving_average(data_res_scaled_col,7)
        # ax1.plot(range(0,len(data_res_scaled_col)),y_av,color='black')
        ax1.set_xticks(list(range(0,len(data_res_scaled_col),52)))
        ax1.set_xticklabels(date_x_label,fontsize=12)
        ax1.spines['right'].set_visible(False)
        ax1.spines['left'].set_visible(False)
        ax1.spines['top'].set_visible(False)
        # data_res_scaled_raw = np.mean(data_res_scaled, axis=1)
        # smoother.smooth(data_res_scaled_raw)
        # v_all = smoother.smooth_data.squeeze(0)
        ax2=fig1.add_subplot(inner[0,1])
        # ax2.bar(x=0,width=data_res_scaled_raw,height=0.5,bottom=range(7),orientation='horizontal')
        ax2.barh(list(reversed(range(7))),data_res_scaled_raw,height=0.3,color='salmon') #darkorange
        ax2.axvline(x=0,c='black',lw=1.1)
        ax2.set_xlim(-0.4,0.4)
        ax2.set_yticks([])
        ax2.set_xticks([])
        ax2.spines['right'].set_visible(False)
        ax2.spines['left'].set_visible(False)
        ax2.spines['top'].set_visible(False)
        ax2.text(
                    1.19, -0.1, "More →", ha='center',
                    verticalalignment='center', transform=ax.transAxes, color='grey',
                    fontsize=11
                )
        ax2.text(
                    1.07, -0.1, "← Less", ha='center',
                    verticalalignment='center', transform=ax.transAxes, color='grey',
                fontsize=11
                )
        ax2.text(
                    1.13, 1.15, "Average scaled frequency \n of the week", ha='center',
                    verticalalignment='center', transform=ax.transAxes,
                fontsize=11
                ) #, color='grey',
    else:
        row = idx // 2
        col = idx % 2
        idx += 1
        # row_b = row // 2
        # col_b = col % 2

        data_res_freq = np.zeros((7,(days_t//7+1)))
        data_res_rank = np.zeros((7,(days_t//7+1)))
        word_d = data.get(w)
        freq = []
        if word_d is None:
            continue
        else:
            for item in word_d:
                date_temp = item[-1].replace('-','')
                if date_temp > date_end or date_temp < date_start:
                    continue
                else:
                    rank = item[1]
                    freq = item[-2]
                    day_sep = (datetime.strptime(date_temp,"%Y%m%d")-datetime.strptime(date_start,"%Y%m%d")).days
                    week_n = day_sep // 7
                    week_r = day_sep % 7
                    data_res_freq[week_r,week_n] = freq
                    data_res_rank[week_r,week_n] = rank

        data_res_scaled = scaler.fit_transform(data_res_freq)
        vmin, vmax = np.nanpercentile(data_res_scaled, [1, 99])
        bounds = np.linspace(vmin, vmax, 21)
        norm = mcolors.BoundaryNorm(bounds, newcmp.N)
        data_res_scaled_col = np.mean(data_res_freq, axis=0) # data_res_freq data_res_rank
        data_res_scaled_raw = np.mean(data_res_scaled, axis=1) #data_res_rank data_res_scaled

        inner = spec[row,col].subgridspec(2,2,hspace=0.1,wspace=0.05,width_ratios=[0.4,0.08],height_ratios=[5,5])
        ax =fig1.add_subplot(inner[0,0])
        cax = inset_axes(ax,
                width="20%",  # width: 40% of parent_bbox width
                height="10%",  # height: 10% of parent_bbox height
                loc='lower left',
                bbox_to_anchor=(0, 1.22, 1, 1),
                bbox_transform=ax.transAxes,
                borderpad=0,
                )
        sns.heatmap(data_res_scaled, cmap=newcmp,norm=norm,ax=ax,cbar_ax=cax,cbar_kws={'orientation': 'horizontal','ticks':[-1.5,0,1.5]})
        ax.set_title(w,fontsize=18,y=1.12)
        ax.axhline(y=1,c='black',lw=1.15)
        ax.axhline(y=2,c='black',lw=1.15)
        ax.axhline(y=3,c='black',lw=1.15)
        ax.axhline(y=4,c='black',lw=1.15)
        ax.axhline(y=5,c='black',lw=1.15)
        ax.axhline(y=6,c='black',lw=1.15)
        ax.set_yticks([0.5,1.5,2.5,3.5,4.5,5.5,6.5])
        ax.set_yticklabels(date_y_label,fontsize=12,rotation=0)
        ax.set_xticks([])
        ax.text(-0.08, 1.2, string.ascii_lowercase[idx_label], transform=ax.transAxes, size=20, weight='bold')
    
        # data_res_scaled_col = np.mean(data_res_freq, axis=0)
        ax1=fig1.add_subplot(inner[1,0])

        ax1.set_yscale('log')
        ax1.set_xlim(0,len(data_res_scaled_col))
        # ax1.set_ylim(0,0.2)
        for i in list(range(7)):
            ax1.scatter(range(0,len(data_res_freq[i])),data_res_freq[i],s=0.5,color='gray',alpha=0.5)
        ax1.plot(range(0,len(data_res_scaled_col)),data_res_scaled_col,linewidth=1.3,color='firebrick') #,alpha=0.8
        ax1.text(
                    1.09, -0.4, "↑\nMore", ha='center',
                    verticalalignment='center', transform=ax.transAxes, color='grey',
                fontsize=11)
        ax1.text(
                    1.09, -0.65, "Frequency", ha='center',
                    verticalalignment='center', transform=ax.transAxes,
                fontsize=11
                ) #color='grey',
        ax1.text(
                    1.09, -0.9, "Less\n↓", ha='center',
                    verticalalignment='center', transform=ax.transAxes, color='grey',
                fontsize=11
                )
        # ax1.plot(range(0,len(data_res_scaled_col)),data_res_scaled_col,color='royalblue',linewidth=1) #'orangered
        ax1.grid(True,axis='y',which="both")
        ax1.grid(True,axis='x',which="both")
        # ax1.yaxis.grid(True)
        # y_av = moving_average(data_res_scaled_col,7)
        # ax1.plot(range(0,len(data_res_scaled_col)),y_av,color='black')
        ax1.set_xticks(list(range(0,len(data_res_scaled_col),52)))
        ax1.set_xticklabels(date_x_label,fontsize=12)
        ax1.spines['right'].set_visible(False)
        ax1.spines['left'].set_visible(False)
        ax1.spines['top'].set_visible(False)
        # data_res_scaled_raw = np.mean(data_res_scaled, axis=1)
        # smoother.smooth(data_res_scaled_raw)
        # v_all = smoother.smooth_data.squeeze(0)
        ax2=fig1.add_subplot(inner[0,1])
        # ax2.bar(x=0,width=data_res_scaled_raw,height=0.5,bottom=range(7),orientation='horizontal')
        ax2.barh(list(reversed(range(7))),data_res_scaled_raw,height=0.3,color='salmon') #darkorange
        ax2.axvline(x=0,c='black',lw=1.1)
        ax2.set_xlim(-0.4,0.4)
        ax2.set_yticks([])
        ax2.set_xticks([])
        ax2.spines['right'].set_visible(False)
        ax2.spines['left'].set_visible(False)
        ax2.spines['top'].set_visible(False)
        ax2.text(
                    1.19, -0.1, "More →", ha='center',
                    verticalalignment='center', transform=ax.transAxes, color='grey',
                    fontsize=11
                )
        ax2.text(
                    1.07, -0.1, "← Less", ha='center',
                    verticalalignment='center', transform=ax.transAxes, color='grey',
                fontsize=11
                )
        ax2.text(
                    1.13, 1.15, "Average scaled frequency \n of the week", ha='center',
                    verticalalignment='center', transform=ax.transAxes,
                fontsize=11
                ) #, color='grey',

plt.subplots_adjust(left=None,bottom=None,top=None,right=None,wspace=0.2,hspace=0.2)
# plt.savefig('figure_res/word_week_0907_{}.pdf'.format(word_flag),dip=300,bbox_inches='tight')
plt.savefig('figure_res/word_week_1103_{}.pdf'.format(word_flag),dip=300,bbox_inches='tight')
plt.savefig('figure_res/word_week_1103_{}.png'.format(word_flag),dip=300,bbox_inches='tight')
plt.savefig('figure_res/word_week_1103_{}.svg'.format(word_flag),dip=300,bbox_inches='tight')
plt.close()
# idx = 0
# fig1=plt.figure(figsize=(18,16))
# spec=fig1.add_gridspec(nrows=3,ncols=2,width_ratios=[1,1],height_ratios=[5,5,5],hspace=0.4,wspace=0.2)
# print('done')
