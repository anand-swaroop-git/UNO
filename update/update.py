from flask import Flask, request, jsonify
import requests
import boto3
import re
app = Flask(__name__)

@app.route('/hc-update')
def healthcheck():
    return "update endpoint healthy"

@app.route('/update', methods=['PUT'])
def update():
    # json request object
    req_data = request.get_json()
    uid = req_data.get('userId', None)
    USER_RE = re.compile(r'^\d{8}$')
    if USER_RE.match(uid) is None:
        return 'This is not a valid userId, it must contain only 8 numeric characters!'

    # parse json values
    title = req_data.get('title', None)
    firstName = req_data.get('firstName', None)
    lastName = req_data.get('lastName', None)
    mobileNumber = req_data.get('mobileNumber', None)
    address = req_data.get('address', None)

    # dynamodb
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table('unouserdb')

    response = table.update_item(
        Key={
            'userId': uid
        },
        UpdateExpression='set title=:t, firstName=:f, lastName=:l, mobileNumber=:m, address=:a',
        ExpressionAttributeValues={
                ':t': title,
                ':f': firstName,
                ':l': lastName,
                ':m': mobileNumber,
                ':a': address
        },
        ReturnValues="UPDATED_NEW"
    )
    return jsonify(response['Attributes'])


if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5003)