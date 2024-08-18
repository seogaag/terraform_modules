import json
import os

# 입력 및 출력 경로 설정
input_data_path = '/opt/ml/processing/input'
output_data_path = '/opt/ml/processing/output'
output_file = os.path.join(output_data_path, 'processed_data.jsonl')

# 출력 파일 열기
with open(output_file, 'w') as outfile:
    # 입력 디렉토리의 모든 파일에 대해 반복
    for filename in os.listdir(input_data_path):
        if filename.endswith('.json'):
            input_file_path = os.path.join(input_data_path, filename)

            # 파일 읽기
            with open(input_file_path, 'r') as infile:
                raw_data = json.load(infile)

                # 각 데이터를 JSONLines 형식으로 변환하여 출력 파일에 쓰기
                for entry in raw_data:
                    processed_entry = {
                        "start": entry["timestamp"],
                        "target": [float(entry["close"])],
                        "item_id": os.path.splitext(filename)[0]  # 파일명을 item_id로 사용
                    }
                    outfile.write(json.dumps(processed_entry) + '\n')
