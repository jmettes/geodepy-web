import json
from io import StringIO
import numpy as np

from geodepy.conversions import dms2dd_v
from geodepy.geodesy import vincinv


def parse_csv(body):
    rows = np.genfromtxt(StringIO(body),
                         delimiter=',',
                         dtype='f8, f8, f8, f8',
                         names=['lat1', 'lon1', 'lat2', 'lon2'])
    rows = dms2dd_v(np.array(rows[['lat1', 'lon1', 'lat2', 'lon2']].tolist()))
    vincenty_rows = list(vincinv(*list(coords)) for coords in np.atleast_2d(rows))
    return '\n'.join('%12.8f, %12.8f, %12.8f' % tuple(v) for v in vincenty_rows)


def handler(event, context):
    # make header keys lowercase
    headers = dict(zip((k.lower() for k in event['headers'].keys()), event['headers'].values()))

    content_type = headers['content-type'].strip() \
        if 'content-type' in headers \
        else None

    accept = headers['accept'].strip() \
        if 'accept' in headers \
        else None

    if content_type == 'text/csv':
        body = parse_csv(event['body'])
    else:
        body = event

    return {
        "statusCode": 200,
        "body": body if accept == 'text/csv' else json.dumps(body)
    }


if __name__ == '__main__':
    event = {
        'headers': {
            'Content-Type': ' text/csv',
            'Accept': ' text/csv'
        },

        'body': '-37.57037203, 144.25295244, -37.39101561, 143.55353839'
        # 'body': {
        #     'lat1': -37.57037203,
        #     'lon1': 144.25295244,
        #     'lat2': -37.39101561,
        #     'lon2': 143.55353839
        # }
    }

    print(handler(event, None))
