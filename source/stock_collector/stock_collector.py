# import json
# import boto3
# import requests
# from datetime import datetime
# import os

# # AWS S3 클라이언트 생성
# s3 = boto3.client('s3')

# # 환경 변수에서 값 가져오기
# BUCKET_NAME = os.environ['BUCKET_NAME']
# API_KEY = os.environ['API_KEY']
# SYMBOLS = os.environ['SYMBOLS'].split(',')

# def stock_collector(event, context):
#     # 결과를 저장할 빈 리스트 초기화
#     results = []

#     # 각 회사 심볼에 대해 주가 데이터 요청
#     for symbol in SYMBOLS:
#         url = f"https://www.alphavantage.co/query?function=TIME_SERIES_INTRADAY&symbol={symbol}&outputsize=1&interval=5min&apikey={API_KEY}"
#         try:
#             # API 요청
#             response = requests.get(url)
#             response.raise_for_status()  # HTTP 오류 발생 시 예외 발생
            
#             # 데이터 파싱
#             data = response.json()
            
#             # 'Time Series (5min)' 데이터만 추출
#             time_series_data = data.get('Time Series (5min)', {})
            
#             # 타임스탬프와 관련된 데이터만 포맷팅
#             formatted_data = [
#                 {
#                     'timestamp': timestamp,
#                     'open': values.get('1. open'),
#                     'high': values.get('2. high'),
#                     'low': values.get('3. low'),
#                     'close': values.get('4. close'),
#                     'volume': values.get('5. volume')
#                 }
#                 for timestamp, values in time_series_data.items()
#             ]
            
#             # 파일명에 타임스탬프 추가
#             timestamp = datetime.utcnow().strftime('%Y-%m-%d_%H-%M-%S')
#             file_name = f"{symbol}/{timestamp}.json"
            
#             # S3에 데이터 저장
#             s3.put_object(Bucket=BUCKET_NAME, Key=file_name, Body=json.dumps(formatted_data))
            
#             # 성공 메시지 추가
#             results.append({'symbol': symbol, 'file': file_name, 'status': 'success'})
        
#         except requests.exceptions.RequestException as e:
#             # API 요청 오류 발생 시 결과에 실패 메시지 추가
#             results.append({'symbol': symbol, 'status': 'failed', 'error': str(e)})

#     # 모든 결과를 포함하여 응답 반환
#     return {
#         'statusCode': 200,
#         'body': json.dumps(results)
#     }
