./configure --with-cuda=/usr/local/cuda
make -j $CPU_COUNT
cd python
make
$PYTHON setup.py install --single-version-externally-managed --record=record.txt
