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
from mpl_toolkits.axes_grid1.inset_locator import inset_axes
smoother = LowessSmoother(smooth_fraction=0.2, iterations=1)
from sklearn.preprocessing import StandardScaler
scaler = StandardScaler()

if __name__ == '__main__':
    words_verb_rir = []
    words_verbs_all = []
    ori_v_list = []
    ir_i_path = 'sources/verbs0910.txt'
    with open(ir_i_path,'r',encoding='utf-8') as fv:
        lines = fv.readlines()
        for line in lines:
            line_item = line.strip().split('\t')
            if line_item[-1] == 'TRUE':
                ori_v = line_item[0].lower().replace(' ','').split(',')
                r_v = line_item[-2].lower().replace(' ','').split(',')
                ir_v = line_item[1].lower().replace(' ','').split(',') + line_item[2].lower().replace(' ','').split(',')
                ori_v_list.append(ori_v[0])
                words_verb_rir.append([r_v,ir_v])
                for item in r_v:
                    words_verbs_all.append(item)
                for item_ in ir_v:
                    words_verbs_all.append(item_)
    words_verbs_all = list(set(words_verbs_all))
    with open ('ngrams_res/ngrams_res_0910_iri_verbs.json', 'r') as f:
        data = json.load(f)

    dates = pd.DataFrame({'date':pd.date_range('2005-12-01','2021-12-31',freq='D')})
    date_str = {}
    for i in range(len(dates)):
        date_str[dates.date.dt.date[i].strftime('%Y%m%d') ] = i

    date_start =  '20100104' #'20100104' #'20190107'#
    date_end = '20211226'
    days_t = (datetime.strptime(date_end,"%Y%m%d")-datetime.strptime(date_start,"%Y%m%d")).days

    verbs_r = []
    verbs_ir= []
    for item_s in words_verb_rir:
        single_verb_r_dict = {}
        single_verb_ir_dict_value = {}
        single_verb_ir_dict = defaultdict(list)

        word_r_d = data.get(item_s[0][0])
        if word_r_d is None:
            r_d_ir = 0
            continue
        else:
            for item_r in word_r_d:
                date_temp = item_r[-1].replace('-','')
                if date_temp > date_end or date_temp < date_start:
                    continue
                else:
                    single_verb_r_dict[date_temp] = item_r[0]

        verbs_r.append(single_verb_r_dict)

        for item_s_ir in item_s[1]:
            word_ir_d = data.get(item_s_ir)
            if word_ir_d is None:
                r_d_ir = 0
                continue
            else:
                for item_ir in word_ir_d:
                    date_temp = item_ir[-1].replace('-','')
                    if date_temp > date_end or date_temp < date_start:
                        continue
                    else:
                        single_verb_ir_dict[date_temp].append(item_ir[0])
        for k,v in single_verb_ir_dict.items():
            single_verb_ir_dict_value[k] = sum(v)

        verbs_ir.append(single_verb_ir_dict_value)

    x = []
    y = []
    for idx, item_s in enumerate(words_verb_rir):
        v_r = verbs_r[idx]
        v_ir = verbs_ir[idx]
        rate0 = []
        date0 = []
        rate1 = []
        date1 = []
        for key in sorted(v_r.keys()):
            if key > date_start and key <= '20121231':
                if key in v_ir.keys():
                    date0.append(key)
                    rate0.append(v_r[key]/(v_r[key]+v_ir[key]))
            if key > '20190101' and key < date_end:
                if key in v_ir.keys():
                    date1.append(key)
                    rate1.append(v_r[key]/(v_r[key]+v_ir[key]))
        if len(rate0) == 0 or len(rate1) == 0:
            continue
        else:
            rate0_avg = sum(rate0)/len(rate0)
            rate1_avg = sum(rate1)/len(rate1)
            x.append(rate0_avg)
            y.append(rate1_avg)

    fig = plt.figure(figsize=(11,10))
    plt.scatter(x,y,s=16)
    plt.yscale('log')
    plt.xscale('log')
    plt.ylim(0.2,0.98)
    plt.xlim(0.25,0.7)
    for i in range(len(x)):
        if x[i] < 0.5 and y[i] > 0.5:
            plt.annotate(ori_v_list[i],xy=(x[i],y[i]),xytext=(x[i],y[i]),color=[0.698,0.133,0.133],fontsize=14)
        elif x[i] > 0.5 and y[i] < 0.5:
            plt.annotate(ori_v_list[i],xy=(x[i],y[i]),xytext=(x[i],y[i]),color=[0.392,0.584,0.929],fontsize=14)
        else:
            plt.annotate(ori_v_list[i],xy=(x[i],y[i]),xytext=(x[i],y[i]),fontsize=16)
    plt.axvline(x=0.5,linestyle='--')
    plt.axhline(y=0.5,linestyle='--')
    plt.xlabel('Mean regularity 2010-2012',fontsize=15)
    plt.ylabel('Mean regularity 2019-2021',fontsize=15)
    axes = plt.gca()
    axes.spines['top'].set_linewidth(1.2)
    axes.spines['bottom'].set_linewidth(1.2)
    axes.spines['left'].set_linewidth(1.2)
    axes.spines['right'].set_linewidth(1.2)

    axes0 = fig.add_axes([0.2,0.62,0.35,0.2])
    axes0.scatter(x,y,s=0.5,alpha=1)
    plt.axvline(x=0.5,linestyle='--')
    plt.axhline(y=0.5,linestyle='--')
    axes0.set_xscale('log')
    axes0.set_yscale('log')
    axes0.set_title('Scatterplot of the irregular verbs')
    axes0.spines['top'].set_linewidth(1.2)
    axes0.spines['bottom'].set_linewidth(1.2)
    axes0.spines['left'].set_linewidth(1.2)
    axes0.spines['right'].set_linewidth(1.2)

    axes1 = fig.add_axes([0.72,0.25,0.15,0.15])
    plt.axhline(y=0.5,linestyle='--')
    axes1.set_yscale('log')
    word_time_list = ['vex','burn','dream']
    for target in word_time_list:
        rate_target = []
        date_target = []
        word_target_idx = ori_v_list.index(target)
        word_target_r = verbs_r[word_target_idx]
        word_target_ir = verbs_ir[word_target_idx]
        for key in sorted(word_target_r.keys()):
            if key in word_target_ir.keys():
                date_target.append(date_str[key])
                rate_target.append(word_target_r[key]/(word_target_r[key]+word_target_ir[key]))
            # else:
            #     date_target.append(date_str[key])
            #     rate_target.append(1)
        rate_target_np =np.array(rate_target)
        smoother.smooth(rate_target_np)
        low, up = smoother.get_intervals('confidence_interval')
        rate_target_plot_y = smoother.smooth_data.squeeze(0)
        axes1.plot(date_target,rate_target_plot_y,alpha=1,label=target)
        axes1.legend(loc='best',fontsize=8,framealpha=0.5,frameon=False)
        axes1.spines['top'].set_linewidth(1.2)
        axes1.spines['bottom'].set_linewidth(1.2)
        axes1.spines['left'].set_linewidth(1.2)
        axes1.spines['right'].set_linewidth(1.2)

    date_x_label = ['2012','2017','2021']
    date_x_idx = []
    for d_label in date_x_label:
        if d_label == '2022':
            d_flag = '20211231'
        else:
            d_flag = d_label+'0101'
        date_x_idx.append(date_str[d_flag])
    axes1.set_xticks(date_x_idx)
    axes1.set_xticklabels(date_x_label)
    plt.savefig('figure_res/verbs_regularity_0911.pdf',dip=300,bbox_inches='tight')
    plt.savefig('figure_res/verbs_regularity_0911.svg',dip=300,bbox_inches='tight')
    plt.savefig('figure_res/verbs_regularity_0911.png',dip=300,bbox_inches='tight')
    print('done')