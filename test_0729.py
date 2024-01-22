import json

data_file = 'love'
with open(data_file, 'r') as f:
    lines = f.readlines()
    for line in lines:
        data = json.loads(line)
print(data)