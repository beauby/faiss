# NOTE(beauby): This is needed as conda does not symlink `python-config`.
./configure --without-cuda
make -j $CPU_COUNT
make py
cd python
$PYTHON setup.py install --single-version-externally-managed --record=record.txt
