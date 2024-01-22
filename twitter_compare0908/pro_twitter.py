import os
import json
from collections import defaultdict
if __name__ == '__main__':
    path = 'twitter_compare0908/twitter_data'
    files = os.listdir(path)
    data_all = defaultdict(list)
    for file in files:
        with open(os.path.join(path,file),'r',encoding='utf-8') as f:
            data = json.load(f)
            keys = list(data['data'].keys())
            for k in keys:
                data_temp = data['data'][k]
                date = data_temp['date']
                count = data_temp['count']
                rank = data_temp['rank']
                freq = data_temp['freq']
                for i in range(len(date)):
                    data_all[k].append([count[i],rank[i],freq[i],date[i]])

    data_res_str = json.dumps(data_all, indent=4)
    with open('twitter_compare0908/twitter_data.json', 'a') as fr:
        fr.write(data_res_str)
