FROM nvidia/cuda:8.0-devel-ubuntu16.04
MAINTAINER Pierre Letessier <pletessier@ina.fr>

RUN apt-get update -y
RUN apt-get install -y libopenblas-dev python-numpy python-dev swig git python-pip curl

RUN pip install matplotlib

COPY . /opt/faiss

WORKDIR /opt/faiss

RUN ./configure

RUN make -j $(nproc) && make test

RUN make -C gpu -j $(nproc) && make -C gpu/tests && \
    ./gpu/tests/demo_ivfpq_indexing_gpu

RUN make -C python gpu build install

RUN curl -L ftp://ftp.irisa.fr/local/texmex/corpus/sift.tar.gz | tar xz && \
    mv sift sift1M

RUN demos/demo_sift1M
