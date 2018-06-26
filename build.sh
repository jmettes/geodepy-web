pushd packaging
make scipy
popd

pushd terraform
pip install --no-dependencies --target="." --upgrade geodepy
zip -r ../packaging/package_scipy.zip handler.py geodepy --exclude "*.pyc" "*/__pycache__/*"
popd
