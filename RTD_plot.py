
from rtd_utils import rank_turbulence_divergence
import jsonlines
import argparse,os
import gzip
# def date_data(date_file):
#     words = {}
#     with open(date_file,'r',encoding='utf-8') as f:
#         lines = f.readlines()
#         for line in lines[1:]:
#             words[line.strip().split('\t')[0]] = int(line.strip().split('\t')[1])
#     return words
def date_data(date_file):
    words = {}
    with gzip.open(date_file,'r') as f:
        while True:
            line_b = f.readline()
            line = line_b.decode()
            if line.startswith('ngram\tcount\trank\tfreq'):
                continue
            elif not line:
                break
            else:
                words[line.strip().split('\t')[0]] = int(line.strip().split('\t')[1])
    return words

def get_hot_words(start, end,start_day, next_day, alpha=1/4, topK=30):
    words1 = date_data(start)
    words2 = date_data(end)
    start_time = start_day.split('.')[0]
    end_time = next_day.split('.')[0]
    hot1, hot2 = rank_turbulence_divergence(start_time,end_time,words1, words2, alpha, topK)
    return hot1, hot2

# def get_data(file):
#     data = []
#     with gzip.open(file,'r') as f:
#         while True:
#             line_b = f.readline()
#             line = line_b.decode()
#             data.append(line)
#             if not line:
#                 break
#             # if line.strip().split('\t')[0] == "ngram" and line.strip().split('\t')[1] == 'count' and line.strip().split('\t')[2] == 'rank' and line.strip().split('\t')[3] == 'freq':
#             #     continue
#             # data.append(line)
#     return data

if __name__ == '__main__':

    res_path = 'rtd_res_everyday/rtd_res.jsonl'
    cli_parser = argparse.ArgumentParser()
    cli_parser.add_argument("--file",default='/data/photonic/reddit_raw_comments/day_ngrams/every_day_ngrams/', help="path")
    cli_parser.add_argument("--language",default='en')
    cli_parser.add_argument("--ngrams",default='3', help="path")
    cli_args = cli_parser.parse_args()
    # language = cli_args.language
    # ngrams = cli_args.ngrams
    for language in ['en']: #, 'ar', 'de', 'fr', 'it', 'ja', 'pt', 'ru'
        for ngrams in ['1']: #, '2', '3'
            file_path = os.path.join(os.path.join(cli_args.file,language),ngrams+'gramc')
            files = sorted(os.listdir(file_path))
            # for i,f in enumerate(files[2221:2230]):
            for i,f in enumerate(files[2221:5874]):
                start_day = f
                next_day = files[2221+i+1]
                path_start = os.path.join(file_path,f)
                path_next = os.path.join(file_path,next_day)
                with jsonlines.open(res_path,'a') as fin:
                    h1,h2 = get_hot_words(path_start, path_next, start_day, next_day)
                    if i == 0:
                        fin.write(h1)
                        fin.write(h2)
                    else:
                        fin.write(h2)
                print(f)