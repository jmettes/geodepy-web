import json


def handler(event, context):
    # message = 'Hello {} {}!'.format(event['first_name'],
    #                                 event['last_name'])
    return {
        "statusCode": 200,
        "body": json.dumps({"message": "hello"})
    }
