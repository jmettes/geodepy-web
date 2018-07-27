import unittest
import subprocess
import os
from urllib.request import Request, urlopen


class TestVincenty(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        abs_path = os.path.abspath(os.path.dirname(__file__))

        # get API endpoint from terraform
        cmd = 'terraform output endpoint'
        with subprocess.Popen(cmd,
                              shell=True,
                              stdout=subprocess.PIPE,
                              stderr=subprocess.STDOUT,
                              cwd=os.path.join(abs_path, '../terraform/')) as p:
            endpoint, error = p.communicate()

        cls.endpoint = endpoint.decode('utf-8').strip()

    def test_csv(self):
        data = '-37.57037203, 144.25295244, -37.39101561, 143.5535383'
        req = Request(self.endpoint + '/vincenty',
                      data=data.encode('ascii'),
                      headers={'Accept': 'text/csv', 'Content-Type': 'text/csv'}
                      )
        resp = urlopen(req).read().decode('utf-8')

        expected_output = '54972.28900000, 306.86814530, 127.17361687'
        self.assertEqual(resp, expected_output)

    def test_json(self):
        data = '{"coords":[{"lat1":-37.57037203,"lon1":144.25295244,"lat2":-37.39101561,"lon2":143.55353839}]}'

        req = Request(self.endpoint + '/vincenty',
                      data=data.encode('ascii'),
                      headers={'Accept': 'application/json', 'Content-Type': 'application/json'}
                      )
        resp = urlopen(req).read().decode('utf-8')

        expected_output = '{"vincinv": [{"el_dist": 54972.271, "azi1to2": 306.868159189, "azi2to1": 127.173630616}]}'
        self.assertEqual(resp, expected_output)


if __name__ == '__main__':
    unittest.main()
