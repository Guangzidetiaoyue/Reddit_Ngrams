import pymongo
import json,os

dates_dict = {}
dates_list = []
year = [str(i) for i in range(2005,2022)]
month = ['01','02','03','04','05','06','07','08','09','10','11','12']
day = ['01','02','03','04','05','06','07','08','09']+[str(i) for i in range(10,29)]
for y in  year:
    if y == '2005':
        day0 = day + ['29','30','31']
        for d in day0:
            dates_dict[y+'-'+'12'+'-'+d] = 0
            dates_list.append(y+'-'+'12'+'-'+d)
    else:
        for m in month:
            if m in ['01','03','05','07','08','10','12']:
                day0 = day + ['29','30','31']
                for d in day0:
                    dates_dict[y+'-'+m+'-'+d] = 0
                    dates_list.append(y+'-'+m+'-'+d)
            elif m in ['04','06','09','11']:
                day0 = day + ['29','30']
                for d in day0:
                    dates_dict[y+'-'+m+'-'+d] = 0
                    dates_list.append(y+'-'+m+'-'+d)
            elif m=='02' and y in ['2008','2012','2016','2020']:
                day0 = day + ['29']
                for d in day0:
                    dates_dict[y+'-'+m+'-'+d] = 0
                    dates_list.append(y+'-'+m+'-'+d)
            else:
                for d in day:
                    dates_dict[y+'-'+m+'-'+d] = 0
                    dates_list.append(y+'-'+m+'-'+d)


myclient = pymongo.MongoClient("mongodb://localhost:27017/")
dblist = myclient.list_database_names()
mydb = myclient["zoujj"]
my_collection = mydb['test']

files = sorted(os.listdir('data_files'))

for file in files:
    with open(os.path.join('data_files',file),'r',encoding='utf-8') as f:
        lines = f.readlines()
        date_flag = file.split('.tsv')[0].split('_')[1]
        for line in lines[1:]:
            data_original = line.strip().split('\t')
            word_flag = data_original[0]
            count = float(data_original[1])
            rank = float(data_original[2])
            freq = float(data_original[3])

            # flag_init = 0
            # zeros_data = [0 for i in range(0,len(dates_list))]
            # data_t = {'data':{'date':dates_list,
            #                     'count':zeros_data,
            #                     'rank':zeros_data,
            #                     'freq':zeros_data},
            #           'language':'en',
            #           'ngram':'1',
            #           'words':word_flag}

            data_t_0 = {
                    'language':'en',
                    'ngram':'1',
                    'words':word_flag}
            my_collection.update_one({'words':word_flag},{'$set':data_t_0},upsert=True)

            date_idx = dates_list.index(date_flag)
            my_collection.update_one({'words':word_flag},{"$set":{'data.dates.{}'.format(date_idx):date_flag}})
            my_collection.update_one({'words':word_flag},{"$set":{'data.count.{}'.format(date_idx):count}})
            my_collection.update_one({'words':word_flag},{"$set":{'data.rank.{}'.format(date_idx):rank}})
            my_collection.update_one({'words':word_flag},{"$set":{'data.freq.{}'.format(date_idx):freq}})

            # data_t_0 = {
            #           'language':'en',
            #           'ngram':'1',
            #           'words':word_flag}
            # my_collection.update_one({'words':word_flag},{'$set':data_t_0},upsert=True)
            # my_collection.update_one({'words':word_flag},{"$push":{"count":{date_flag:count}}})
            # my_collection.update_one({'words':word_flag},{"$push":{"rank":{date_flag:rank}}})
            # my_collection.update_one({'words':word_flag},{"$push":{"freq":{date_flag:freq}}})

            # data_t_init = {'data':{'count':dates_dict,
            #             'rank':dates_dict,
            #             'freq':dates_dict},
            #           'language':'en',
            #           'ngram':'1',
            #           'words':word_flag}
            # data_t = {'data':{'count':{date:count},
            #                     'rank':{date:rank},
            #                     'freq':{date:freq}},
            #           'language':'en',
            #           'ngram':'1',
            #           'words':word_flag}
            # if flag_init == 0:
            #     my_collection.update_one({'words':word_flag},{'$set':data_t_init},upsert=True)
            #     my_collection.update_one({'words':word_flag},{'$set':data_t},upsert=True)
            #     flag_init = 1
            # else:
            #     my_collection.update_one({'words':word_flag},{"$set":{'data.count.{}'.format(date):count}})
            #     my_collection.update_one({'words':word_flag},{"$set":{'data.rank.{}'.format(date):rank}})
            #     my_collection.update_one({'words':word_flag},{"$set":{'data.freq.{}'.format(date):freq}})
            


print('done')