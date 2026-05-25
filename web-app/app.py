from flask import Flask, Response
import mysql.connector
import os
import time

app = Flask(__name__)

def get_db_connection():
    return mysql.connector.connect(
        host=os.environ.get('MYSQL_HOST', 'mysql-master'),
        user='root',
        password='Test123456',
        database='testdb'
    )

request_count = 0
error_count = 0
start_time = time.time()

@app.route('/')
def hello():
    global request_count
    request_count += 1
    return 'Hello from Web App!'

@app.route('/users')
def users():
    global request_count, error_count
    request_count += 1
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute('SELECT * FROM users')
        rows = cursor.fetchall()
        conn.close()
        return {'users': [{'id': r[0], 'name': r[1]} for r in rows]}
    except Exception as e:
        error_count += 1
        return {'error': str(e)}, 500

@app.route('/metrics')
def metrics():
    uptime = time.time() - start_time
    data = f'''# HELP web_requests_total Total requests
# TYPE web_requests_total counter
web_requests_total {request_count}
# HELP web_errors_total Total errors
# TYPE web_errors_total counter
web_errors_total {error_count}
# HELP web_uptime_seconds Web app uptime
# TYPE web_uptime_seconds gauge
web_uptime_seconds {uptime:.2f}
'''
    return Response(data, mimetype='text/plain')

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
