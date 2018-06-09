pushd packaging
make scipy
popd

pushd terraform
zip -r ../packaging/package_scipy.zip handler.py geodepy
popd
