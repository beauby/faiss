./configure
make -j $CPU_COUNT
make -C python
cd python
$PYTHON setup.py install --single-version-externally-managed --record=record.txt
