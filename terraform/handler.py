import json
from io import StringIO
import numpy as np

from geodepy.conversions import dms2dd_v
from geodepy.geodesy import vincinv


def parse_json(body):
    coordinates = json.loads(body)['coords']
    # rows = dms2dd_v()
    rows = dms2dd_v(np.array(list(tuple(coords.values()) for coords in coordinates)))
    vincenty_rows = list(vincinv(*list(coords)) for coords in np.atleast_2d(rows))
    return {'vincinv': tuple(dict(zip(('el_dist', 'azi1to2', 'azi2to1'), row)) for row in vincenty_rows)}


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
        body = parse_json(event['body'])

    return {
        "statusCode": 200,
        "headers": {
            "X-Requested-With": '*',
            "Access-Control-Allow-Headers": 'Content-Type,X-Amz-Date,Authorization,X-Api-Key,x-requested-with',
            "Access-Control-Allow-Origin": '*',
            "Access-Control-Allow-Methods": 'POST,GET,OPTIONS'
        },
        "body": body if accept == 'text/csv' else json.dumps(body)
    }


if __name__ == '__main__':
    # event = {
    #     'headers': {
    #         'Content-Type': ' text/csv',
    #         'Accept': ' text/csv'
    #     },
    #
    #     'body': '-37.57037203, 144.25295244, -37.39101561, 143.55353839\n'
    #             + '-37.57037203, 144.25295244, -37.39101561, 143.55353839'
    # }

    event = {
        'headers': {
            'Content-Type': ' application/json',
            'Accept': ' application/json'
        },

        'body': {
            'coords': json.dumps([
                {'lat1': -37.57037203, 'lon1': 144.25295244, 'lat2': -37.39101561, 'lon2': 143.55353839},
                {'lat1': -37.57037203, 'lon1': 144.25295244, 'lat2': -37.39101561, 'lon2': 143.55353839}
            ])
        }
    }

    print(handler(event, None))
