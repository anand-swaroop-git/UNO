from flask import Flask, request
import boto3
import random
import string

app = Flask(__name__)


@app.route('/create', methods=['POST'])
def create():
    # json request object
    req_data = request.get_json()

    # parse json values
    user_title = req_data['title']
    user_firstName = req_data['firstName']
    user_lastName = req_data['lastName']
    user_mobileNumber = req_data['mobileNumber']
    user_address = req_data['address']

    # generate random userid
    uid = ''.join(random.choices(string.digits, k=8))

    # dynamodb
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table('unouserdb')

    # Improvement - check duplicate user in DB
    table.put_item(
        Item={
            'userId': uid,
            'title': user_title,
            'firstName': user_firstName,
            'lastName': user_lastName,
            'mobileNumber': user_mobileNumber,
            'address': user_address,
        }
    )
    return '{} {} has been added with userid: {}'.format(user_title, user_firstName, uid)


if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5001)
