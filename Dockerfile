FROM nvidia/cuda:8.0-devel-ubuntu16.04

RUN apt-get update -y && apt-get install -y wget
RUN wget -O- https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS-2019.PUB | apt-key add -
RUN echo deb https://apt.repos.intel.com/mkl all main > /etc/apt/sources.list.d/intel-mkl.list
RUN apt-get update -y
RUN apt-get install -y intel-mkl-64bit-2019.1-053
RUN apt-get install -y python-numpy libpython-dev swig git
RUN apt-get install -y python-setuptools
ENV LD_LIBRARY_PATH /opt/intel/lib/intel64:/opt/intel/mkl/lib/intel64:$LD_LIBRARY_PATH
ENV LIBRARY_PATH /opt/intel/lib/intel64:/opt/intel/mkl/lib/intel64:$LIBRARY_PATH

COPY . /opt/faiss

WORKDIR /opt/faiss

RUN ./configure --without-cuda CPPFLAGS="-I/usr/include/python2.7"
RUN make -j $(nproc)
RUN make test
RUN make install
