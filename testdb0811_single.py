import pymongo
import json,os,time
import argparse
import gzip
import logging
logger = logging.getLogger(__name__)
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

if __name__ == '__main__':

    cli_parser = argparse.ArgumentParser()
    cli_parser.add_argument("--file",default='/data/photonic/reddit_raw_comments/day_ngrams/every_day_ngrams/', help="path")
    cli_parser.add_argument("--language",default='en')
    cli_parser.add_argument("--ngrams",default='3', help="path")
    cli_args = cli_parser.parse_args()
    # language = cli_args.language
    # ngrams = cli_args.ngrams
    for language in ['en', 'ar', 'de', 'fr', 'it', 'ja', 'pt', 'ru']:
        for ngrams in ['1', '2', '3']:
            file_path = os.path.join(os.path.join(cli_args.file,language),ngrams+'gramc')

            myclient = pymongo.MongoClient("mongodb://localhost:27017/")
            dblist = myclient.list_database_names()
            mydb = myclient["zoujj"]
            my_collection = mydb['test0812']

            files = sorted(os.listdir(file_path))

            for file in files[304:]:
                logger.info(file)
                # print(file)
                with gzip.open(os.path.join(file_path,file),'r') as f:
                    lines = f.readlines()
                    date_flag = file.split('.tsv')[0].split('_')[1]
                    for line in lines[1:30000]:
                        line_str = line.decode()
                        data_original = line_str.strip().split('\t')
                        word_flag = data_original[0]
                        count = float(data_original[1])
                        rank = float(data_original[2])
                        freq = float(data_original[3])

                        data_t_0 = {
                                'language':language,
                                'ngram':ngrams,
                                'words':word_flag}
                        my_collection.update_one({'words':word_flag},{'$set':data_t_0},upsert=True)

                        date_idx = dates_list.index(date_flag)
                        my_collection.update_one({'words':word_flag},{"$set":{'data.dates.{}'.format(date_idx):date_flag}})
                        my_collection.update_one({'words':word_flag},{"$set":{'data.count.{}'.format(date_idx):count}})
                        my_collection.update_one({'words':word_flag},{"$set":{'data.rank.{}'.format(date_idx):rank}})
                        my_collection.update_one({'words':word_flag},{"$set":{'data.freq.{}'.format(date_idx):freq}})
                t1=time.gmtime()
                logger.info(language+' '+ngrams+' '+file+' done! '+time.strftime("%Y-%m-%d %H:%M:%S",t1))
                print(language+' '+ngrams+' '+file+' done! '+time.strftime("%Y-%m-%d %H:%M:%S",t1))
