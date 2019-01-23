# NOTE(beauby): This is needed as conda does not symlink `python-config`.
./configure --with-cuda=/dev/null
make -j $CPU_COUNT
cd python
make cpu
make build
$PYTHON setup.py install --single-version-externally-managed --record=record.txt
