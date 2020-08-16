:: Copyright (c) Facebook, Inc. and its affiliates.
::
:: This source code is licensed under the MIT license found in the
:: LICENSE file in the root directory of this source tree.

:: Build vanilla version (no avx).
cmake -B _build_python_%PY_VER% ^
      -DFAISS_ENABLE_GPU=OFF ^
      -DCMAKE_BUILD_TYPE=Release ^
      -DPython_EXECUTABLE=%PYTHON% ^
      faiss/python

cmake --build _build_python_%PY_VER% -j %CPU_COUNT%


:: Build actual python module.
cd _build_python_%PY_VER%/
%PYTHON% setup.py install --single-version-externally-managed --record=record.txt --prefix=%PREFIX%
