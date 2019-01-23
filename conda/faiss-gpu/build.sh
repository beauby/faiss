./configure
cat makefile.inc
make -j $CPU_COUNT
make -C gpu -j $CPU_COUNT
cd python
make cpu
make gpu
make build
$PYTHON setup.py install --single-version-externally-managed --record=record.txt
