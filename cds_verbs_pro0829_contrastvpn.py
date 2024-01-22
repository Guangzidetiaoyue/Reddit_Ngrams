from pytrends.request import TrendReq
from datetime import datetime
import pandas as pd
import json
from matplotlib import pyplot as plt
thresholds = {
        'reddit': 10,
        'news': 3,
    }
start_date=datetime(2019, 1, 1)
end_date=datetime(2021, 12, 31)
timescale='W'
targets = [
    'COVID-19',
    'unemployment',
    'BLM',
    'Black Lives Matter',
    'metaverse',
    'NFT',
    'populism',
    'Genshin',
    'shooting',
    'mask',
    'vaccine',
    'rightwing',
    'pollution',
    'strike',
    'China',
    'nuclear'
]

pytrends = TrendReq(
    hl='en-US',
    tz=-300,
    timeout=(6, 12),
    retries=3,
    backoff_factor=0.1,
    requests_args={'verify': False}
)
tvnews_path = 'ngrams_res/news_2019-2021.csv'
tvnews = pd.read_csv(tvnews_path, header=0, index_col='Time')
tvnews['Query'] = tvnews['Query'].str.replace('"', '')
tvnews['Query'] = tvnews['Query'].str.replace('text=', '')
tvnews.index = pd.to_datetime(tvnews.index)

data_twitter = pd.read_csv('ngrams_res/story_twitter.csv')

with open('ngrams_res/ngrams_res_0829_contrast.json','r') as fr:
    data_reddit = json.load(fr)

df = None
for w in targets:
    print(w)
    if w == 'COVID-19':
        w_n = 'COVID'
    else:
        w_n = w
    pytrends.build_payload(
        [w],
        timeframe=f"{start_date.strftime('%Y-%m-%d')} {end_date.strftime('%Y-%m-%d')}",
        geo='',
        gprop='',
    )
    gtrends = pytrends.interest_over_time()
    gtrends = pd.Series(0, index=pd.date_range(start_date, end_date)) if gtrends.empty else gtrends[w]
    gtrends = gtrends.resample(timescale).sum()

    news = tvnews[tvnews['Query'] == w_n]['Value']
    if news.empty:
        news = pd.Series(0, index=pd.date_range(start_date, end_date))
    else:
        news = pd.concat([news, pd.Series(0, index=pd.date_range(start_date, end_date))]).fillna(0)

    news = news.resample(timescale).sum()
    news = news.loc[gtrends.index]
    news[news < thresholds['news']] = 0
    news = ((news - news.min()) / (news.max() - news.min())) * 100

    data_reddit_w = list(reversed(data_reddit[w]))
    data_reddit_dict = {}
    for item in data_reddit_w:
        data_reddit_dict[item[-1]] = item[0]
    reddit = pd.DataFrame(list(data_reddit_dict.items()),columns=['Date','count'])
    reddit = reddit.set_index('Date')
    reddit.index = pd.to_datetime(reddit.index)
    # reddit = reddit['count']
    if reddit.empty:
        reddit = pd.Series(0, index=pd.date_range(start_date, end_date))
    else:
        reddit = pd.concat([reddit, pd.Series(0, index=pd.date_range(start_date, end_date))]).fillna(0)
    reddit = reddit['count'].fillna(0).resample(timescale).sum()
    reddit = reddit.loc[gtrends.index]
    reddit[reddit < thresholds['reddit']] = 0
    reddit = ((reddit - reddit.min()) / (reddit.max() - reddit.min())) * 100

    twitter_xx = data_twitter[data_twitter['ngram']==w]
    twitter_xx = twitter_xx.set_index('Date')
    twitter_xx.index = pd.to_datetime(twitter_xx.index)
    if twitter_xx.empty:
        twitter_xx = pd.Series(0, index=pd.date_range(start_date, end_date))
    else:
        twitter_xx = pd.concat([twitter_xx, pd.Series(0, index=pd.date_range(start_date, end_date))]).fillna(0)
    twitter = twitter_xx['count'].fillna(0).resample(timescale).sum()
    twitter = twitter.loc[gtrends.index]
    twitter[twitter < thresholds['reddit']] = 0
    twitter = ((twitter - twitter.min()) / (twitter.max() - twitter.min())) * 100

    ts = pd.DataFrame(dict(
        ngram=w,
        date=reddit.index,
        reddit=reddit,
        gtrends=gtrends,
        news=news
    )).fillna(0)

    if df is not None:
        df = df.append(ts)
    else:
        df = ts
df.to_csv('ngrams_res/platform19_21.csv')