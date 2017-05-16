from flask import Flask, request
import json
import traceback
app = Flask(__name__)


@app.route('/')
def hello_world():
    return 'Hello, world!'


@app.route('/apps', methods=['POST'])
def submit_apps():
    try:
        data = json.loads(request.data.decode('UTF-8'))
        return json.dumps(
            {
                "success": True
            },
            sort_keys=True
        )

    except Exception as ex:
        return json.dumps(
            {
                'success': False,
                'detail': traceback.format_exc()
            },
            sort_keys=True
        ), 402


@app.route("/events")
def retrieve_score():
    return '[]'


if __name__ == '__main__':
    app.run()
