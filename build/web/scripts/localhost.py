from flask import Flask, request
import pprint

app = Flask(__name__)

@app.route('/MinorWebApp/<path:path>', methods=['POST'])
def handle_post(path):
    data = request.form.to_dict()
    print(f"POST request received on /MinorWebApp/{path}")
    print(data)
    pprint.pprint(data)
    return f'POST request received on /MinorWebApp/{path}', 200

if __name__ == '__main__':
    app.run(host='localhost', port=8080)