
import _json
import datetime
import pymysql

#connect to mysql server
db = pymysql.connect(
  host="localhost",
  user="root",
  password="NGNZJJ5110.",
  database="nlp_database"
)

cursor = db.cursor()

prefix_str = 'test_'

start_date = datetime.datetime(2012, 1, 1)
end_date = datetime.datetime(2012, 1, 1)

num_files = (end_date - start_date).days + 1

date = start_date

time_delta = datetime.timedelta(1)

#insert data
for i in range(num_files):
    str_date = str(date)[:10]
    file_name = prefix_str + str_date + ".tsv"

    file_i = open(file_name, "r")

    for line in file_i.readlines()[1:]:
        temp = (line.split('\t'))
        ngram = temp[0].strip()
        count = temp[1].strip()
        rank = temp[2].strip()
        frequency = temp[3].strip()
        dateC = str_date

        if (ngram == "ngram"):
            continue

        cursor.execute("SHOW TABLES")
        if ngram not in cursor:
            # syntax error
            string = "CREATE TABLE %s (ngram VARCHAR(255) PRIMARY KEY, count INT,rank FLOAT, frequency FLOAT, date VARCHAR(255))" % ngram 
            cursor.execute(string)

        sql = "INSERT INTO %s (ngram, count, rank, frequency, datea) VALUES (%s, %d, %f, %f, %s)" % ngram
        val = (ngram, count, rank, frequency, dateC)
        cursor.execute(sql, val)

        db.commit()

    date += time_delta

cursor.execute("SELECT * FROM s")
result = cursor.fetchall()
for x in result:
    print(x)



