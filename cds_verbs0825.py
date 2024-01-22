import os,json
import gzip,argparse
from collections import defaultdict
import pandas as pd

if __name__ == '__main__':
    file_path = 'sources/CDS.tsv'
    file_path0 = 'sources/verbs.tsv'
    cds_words = []
    cds_1 = []
    cds_2 = []
    cds_3 = []
    verbs_words = []
    verbs_1 = []
    verbs_2 = []
    verbs_3 = []
    with open(file_path, 'r',encoding='utf-8') as f:
        lines = f.readlines()
        for line in lines:
            if ":" not in line:
                words_temp = line.strip().split(', ')
                for item in words_temp:
                    if len(item.split(' ')) < 4 and len(item) > 0:
                        cds_words.append(item)
                    if len(item.split(' ')) == 1 and len(item) > 0:
                        cds_1.append(item)
                    if len(item.split(' ')) == 2 and len(item) > 0:
                        cds_2.append(item)
                    if len(item.split(' ')) == 3 and len(item) > 0:
                        cds_3.append(item)
    cds_count = len(cds_words)

    with open(file_path0, 'r',encoding='utf-8') as f:
        lines = f.readlines()
        for line in lines:
            if ":" not in line:
                words_temp = line.strip().split(', ')
                for item in words_temp:
                    if len(item.split(' ')) < 4 and len(item) > 0:
                        verbs_words.append(item)
                    if len(item.split(' ')) == 1 and len(item) > 0:
                        verbs_1.append(item)
                    if len(item.split(' ')) == 2 and len(item) > 0:
                        verbs_2.append(item)
                    if len(item.split(' ')) == 3 and len(item) > 0:
                        verbs_3.append(item)
    verbs_count = len(verbs_words)


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
    for language in ['en']: #, 'ar', 'de', 'fr', 'it', 'ja', 'pt', 'ru'
        for ngrams in ['3', '2', '1']:
            file_path = os.path.join(os.path.join(cli_args.file,language),ngrams+'gramc')
            files = sorted(os.listdir(file_path),reverse=True) #
            for idx,f in enumerate(files[2000:]):
                # print(f"开始执行{f}个任务...")
                cds_flag = 0
                verbs_flag = 0
                filepath=os.path.join(file_path,f)
                date_flag = filepath.split('/')[-1].split('.tsv')[0].split('_')[1]
                data_res_temp = {}
                if idx % 100 == 0:
                    print(ngrams+' '+f)

                with gzip.open(filepath,'r') as fin:
                    while True:
                        line_b = fin.readline()
                        line = line_b.decode()
                        if not line:
                            break
                        if line.strip().split('\t')[0] == "ngram" and line.strip().split('\t')[1] == 'count' and line.strip().split('\t')[2] == 'rank' and line.strip().split('\t')[3] == 'freq':
                            continue
                        data_original = line.strip().split('\t')
                        word_flag = data_original[0]
                        data_original.append(date_flag)
                        data_res_temp[word_flag] = data_original[1:]

                if ngrams == '1':
                    for word_flag in cds_1:
                        words_dict[word_flag].append(data_res_temp.get(word_flag))

                    for word_flag in verbs_1:
                        words_dict[word_flag].append(data_res_temp.get(word_flag))
                if ngrams == '2':
                    for word_flag in cds_2:
                        words_dict[word_flag].append(data_res_temp.get(word_flag))
                    for word_flag in verbs_2:
                        words_dict[word_flag].append(data_res_temp.get(word_flag))
                if ngrams == '3':
                    for word_flag in cds_3:
                        words_dict[word_flag].append(data_res_temp.get(word_flag))
                    for word_flag in verbs_3:
                        words_dict[word_flag].append(data_res_temp.get(word_flag))

    data_res_str = json.dumps(words_dict, indent=4)
    res_file = 'ngrams_res/ngrams_res_0824.json'
    with open(res_file, 'w') as fr:
        fr.write(data_res_str)