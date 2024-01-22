import os,json,time
import gzip,argparse
from collections import defaultdict
import pandas as pd

if __name__ == '__main__':

    words_punctuation = ['.','!','?']

    print('words done')
    cli_parser = argparse.ArgumentParser()
    cli_parser.add_argument("--file",default='/data/photonic/reddit_raw_comments/day_ngrams/every_day_ngrams/', help="path")
    cli_parser.add_argument("--language",default='en')
    cli_parser.add_argument("--ngrams",default='3', help="path")
    cli_args = cli_parser.parse_args()
    # language = cli_args.language
    # ngrams = cli_args.ngrams
    decompress_path = 'data_file'
    words_dict = defaultdict(list)
    t0 = time.time()
    res_file = 'ngrams_res/ngrams_res_0829_punctuation.json'
    for language in ['en']: #, 'ar', 'de', 'fr', 'it', 'ja', 'pt', 'ru'
        for ngrams in ['1']: #
            words_dict_temp = defaultdict(list)
            file_path = os.path.join(os.path.join(cli_args.file,language),ngrams+'gramc')
            files = sorted(os.listdir(file_path),reverse=True)[1096:] #
            for idx,f in enumerate(files):
                # print(f"开始执行{f}个任务...")
                try:
                    cds_flag = 0
                    verbs_flag = 0
                    filepath=os.path.join(file_path,f)
                    date_flag = filepath.split('/')[-1].split('.tsv')[0].split('_')[1]
                    if idx % 100 == 0:
                        print(ngrams+' '+f+' '+ str(time.time() - t0)[:5])
                        t0 = time.time()
                    # data_ori = pd.read_csv(filepath,sep='\t',header=0)
                    g_file_obj = gzip.GzipFile(filepath,'rb')
                    g_file_data = os.path.join(decompress_path,f[:-3])
                    with open(g_file_data,'wb') as fd:
                        fd.write(g_file_obj.read())
                    g_file_obj.close()

                    data_ori = pd.read_csv(g_file_data,sep='\t',header=0)

                    if ngrams == '1':
                        x = data_ori[data_ori.ngram.isin(words_punctuation)]
                        for n,row in x.iterrows():
                            # print(row['ngram'],row['count'],row['rank'],row['freq'])
                            words_dict[row['ngram']].append([row['count'],row['rank'],row['freq'],date_flag])
                            words_dict_temp[row['ngram']].append([row['count'],row['rank'],row['freq'],date_flag])
                    os.remove(g_file_data)
                except:
                    print(f)
    data_res_str = json.dumps(words_dict, indent=4)
    with open(res_file, 'a') as fr:
        fr.write(data_res_str)

    # with open('ngrams_res/ngrams_res_0824.json','r') as fin:
    #     res = json.load(fin)
    # for wt in cds_1:
    #     if wt not in res:
    #         print(wt)