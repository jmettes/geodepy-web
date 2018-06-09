SHELL = bash

python3:
	docker build -f Dockerfiles/python3.6 --tag lambda:python3.6 .

scipy:
	docker build -f Dockerfiles/python3.6 --tag lambda:python3.6 .
	docker build -f Dockerfiles/scipy --tag lambda:scipy .
	docker run --name lambda -itd lambda:scipy
	docker cp lambda:/tmp/package.zip package_scipy.zip
	docker stop lambda
	docker rm lambda