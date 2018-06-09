# GeodePy web

AWS infrastructure for web application of [GeodePy](https://github.com/GeoscienceAustralia/geodesy-package)

![](infrastructure-graph.png)

Image generated with:

```
$ terraform graph \
 | grep -Ev "meta.count-boundary|local.|var.|output.|data.aws_caller_identity.current|provider." \
 | dot -Tpng > infrastructure-graph.png
```

## Building

Python packages such as `numpy` aren't available on the AWS Lambda python runtime by default, and must be packaged along with the source. Furthermore, `numpy` requires natively compiled libraries (e.g., for BLAS), and must also be packaged along with the source.

This project uses docker (with the Amazon Linux image used on AWS Lambda) to build these dependencies.

```
$ ./build.sh
```

Some notes on building python dependencies (numpy, etc.), within 50mb AWS Lambda limit:
https://blog.mapbox.com/aws-lambda-python-magic-e0f6a407ffc6

## Deploying

```
$ ./deploy.sh
```

Add `--dry-run` to run terraform with `plan` only, and not `apply`.

## Usage

```
$ curl -XPOST \
 -H"Accept: text/csv" \
 -H"Content-Type: text/csv" \
 -d$'-37.57037203, 144.25295244, -37.39101561, 143.5535383\n-37.57037203, 144.25295244, -37.39101561, 143.5535383' \
 https://<your-endpoint-url>
```

returns:

```
54972.27100000, 306.86815919, 127.17363062
54972.27100000, 306.86815919, 127.17363062
```
