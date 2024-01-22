import pymongo,argparse
import json,os,time
from concurrent.futures import ThreadPoolExecutor
from multiprocessing import Pool
from collections import defaultdict
from pymongo import InsertOne, DeleteOne, ReplaceOne, UpdateOne
import gzip
import logging
logger = logging.getLogger(__name__)
t0=time.gmtime()

INSERT_MANY_COUNT = 5000
NUM = 30000
t0=time.gmtime()
print(time.strftime("%Y-%m-%d %H:%M:%S",t0))

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
my_collection = mydb['ngrams0815']

def gen_file(filepath):
    """将大型文件转化为生成器对象，每次返回一行对应的字典格式数据"""
    date_flag = filepath.split('/')[-1].split('.tsv')[0].split('_')[1]
    # with open(os.path.join("data_files",filepath), "r", encoding="utf-8") as f:
    with gzip.open(filepath,'r') as f:
        while True:
            line_b = f.readline()
            line = line_b.decode()
            if not line:
                break
            if line.strip().split('\t')[0] == "ngram" and line.strip().split('\t')[1] == 'count' and line.strip().split('\t')[2] == 'rank' and line.strip().split('\t')[3] == 'freq':
                continue
            data_original = line.strip().split('\t')
            data_original.append(date_flag)

            word_flag = data_original[0]
            data_t_0 = {
                    'language':'en',
                    'ngram':'1',
                    'words':word_flag}
            date_idx = dates_list.index(date_flag)
            FILEDS = ["id", 'data.count.{}'.format(date_idx), 'data.rank.{}'.format(date_idx), 'data.freq.{}'.format(date_idx),'data.dates.{}'.format(date_idx)]

            doc_dict = defaultdict()
            doc_dict = {k: v for k, v in zip(FILEDS[1:], data_original[1:])}
            yield doc_dict,data_t_0

def update_mongo(filepath):
# 连接 MongoDB
    file_gen = gen_file(filepath)
    print(filepath)
    # print(f'执行完毕！耗时{0}s,结果为{1}')
    # date_flag = filepath.split('.tsv')[0].split('_')[1]
    # while True:
    for n in range(int(NUM/INSERT_MANY_COUNT)):
        requests = []
        try:
            for i in range(INSERT_MANY_COUNT):
                doc,data_t_0 = next(file_gen)
                word_flag = data_t_0['words']
                # docs.append(doc)
                # datas.append(data_t_0)
                requests.append(
                    UpdateOne(
                        {'words':word_flag},
                        {'$set':data_t_0},
                         upsert=True)
                    )
                for key,value in doc.items():
                    requests.append(
                        UpdateOne(
                            {'words':word_flag},
                            {'$set':{key:value}}
                            )
                        )

            my_collection.bulk_write(requests)
            # my_collection.insert_many(datas)
            # my_collection.update_many(datas)
            # word_flag = data_t_0['words']
            # my_collection.update_one({'words':word_flag},{'$set':data_t_0},upsert=True)
            # for key,value in doc.items():
            #     my_collection.update_one({'words':word_flag},{"$set":{key:value}})
        except StopIteration:
            break

# def run_insert_pool(filepath):
#     update_mongo(filepath)
#     print('done')

if __name__ == '__main__':
    cli_parser = argparse.ArgumentParser()
    cli_parser.add_argument("--file",default='/data/photonic/reddit_raw_comments/day_ngrams/every_day_ngrams/', help="path")
    cli_parser.add_argument("--language",default='en')
    cli_parser.add_argument("--ngrams",default='3', help="path")
    cli_args = cli_parser.parse_args()
    # language = cli_args.language
    # ngrams = cli_args.ngrams
    for language in ['en', 'ar', 'de', 'fr', 'it', 'ja', 'pt', 'ru']:
        for ngrams in ['1']: #, '2', '3'
            file_path = os.path.join(os.path.join(cli_args.file,language),ngrams+'gramc')

            files = sorted(os.listdir(file_path))
            p = Pool(15)
            for f in files[5564:]:
                # print(f"开始执行{f}个任务...")
                p.apply_async(update_mongo, args=(os.path.join(file_path,f),))
            p.close()
            p.join()
            t1=time.gmtime()
            print(time.strftime("%Y-%m-%d %H:%M:%S",t1))
            # logger.info(language+' '+ngrams+' '+f+' done! '+time.strftime("%Y-%m-%d %H:%M:%S",t1))
            # print(language+' '+ngrams+' '+f+' done! '+time.strftime("%Y-%m-%d %H:%M:%S",t1))



