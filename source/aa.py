import requests
import pandas as pd
# import boto3/
from datetime import datetime

# Polygon API 키 설정
api_key = "QE0t8vHW3Ndx82q30U_qiZMOQc0kRrl6"

# API 요청 URL 설정
ticker = "AAPL"
start_date = "2024-07-01"
end_date = "2024-09-30"
url = f"https://api.polygon.io/v2/aggs/ticker/{ticker}/range/5/minute/{start_date}/{end_date}?adjusted=true&sort=asc&limit=50000&apiKey={api_key}"

# API 요청
response = requests.get(url)
data = response.json()


# 데이터프레임으로 변환
df = pd.DataFrame(data['results'])

# 타임스탬프를 날짜로 변환
df['t'] = pd.to_datetime(df['t'], unit='ms')

# 열 이름 변경
df.rename(columns={
    't': 'date',
    'o': 'open',
    'h': 'high',
    'l': 'low',
    'c': 'close',
    'v': 'volume'
}, inplace=True)

# 데이터프레임 저장
csv_file = './AAPL/stock_data_2024.07-09.csv'
df.to_csv(csv_file, index=False)
