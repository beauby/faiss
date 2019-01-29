FROM soumith/conda-cuda:latest

COPY ./ faiss-conda
RUN cd faiss-conda && \
    FAISS_BUILD_VERSION=1.5.0 \
    FAISS_BUILD_NUMBER=1 \
    conda build -c pytorch --no-anaconda-upload faiss-gpu && \
    conda build -c pytorch --no-anaconda-upload faiss
