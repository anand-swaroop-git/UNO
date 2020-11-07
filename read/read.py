from flask import Flask, request
import requests
import boto3
import re

app = Flask(__name__)


@app.route('/read')
def read():
    # user input validation for userId
    uid = request.args.get('userId')
    USER_RE = re.compile(r'^\d{8}$')
    if USER_RE.match(uid) is None:
        return 'This is not a valid userId, it must contain only 8 numeric characters!'
    else:
        # dynamodb
        dynamodb = boto3.resource('dynamodb')
        table = dynamodb.Table('unouserdb')

        response = table.get_item(
            Key={
                'userId': uid
            }
        )

        # Validate if the userId exists in dynamodb, else return a valid error message
        if 'Item' not in response:
            return 'userId: {}, does not exist!'.format(uid)
        else:
            return response['Item']


if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5002)
