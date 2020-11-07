from flask import Flask, request
import requests
import boto3
app = Flask(__name__)
@app.route('/update', methods=['PUT'])
def update():
    # get userid from query parameter
    uid = request.args.get('userId')
    old_item = request.args.get('old_item')
    new_item = request.args.get('new_item')
    # dynamodb
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table('unouserdb')

    #  Improvement - return user not found if user doesnt exist in DB
    response = table.update_item(
        Key={
            'userId': uid
        },
        UpdateExpression="set {} = :g".format(old_item),
        ExpressionAttributeValues={
                ':g': new_item
        },
        ReturnValues="UPDATED_NEW"
    )
    return response


if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5003)