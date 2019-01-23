FROM soumith/conda-cuda:latest

RUN wget -q https://developer.nvidia.com/compute/cuda/9.2/Prod2/local_installers/cuda_9.2.148_396.37_linux && \
    chmod +x cuda_9.2.148_396.37_linux && \
    ./cuda_9.2.148_396.37_linux --silent --toolkit


COPY ./ faiss-conda
#RUN cd faiss-conda && \
#    FAISS_BUILD_VERSION=1.5.0 \
#    FAISS_BUILD_NUMBER=1 \
#    conda build -c pytorch --no-anaconda-upload faiss

# 8.0 9.0 10.0
RUN cd faiss-conda && for cuda_version in 9.2; do \
    mkdir -p /usr/local && \
    rm -rf /usr/local/cuda && \
    ln -s /usr/local/cuda-$cuda_version /usr/local/cuda && \
    CUDA_VERSION=$cuda_version \
    FAISS_BUILD_VERSION=1.5.0 \
    FAISS_BUILD_NUMBER=1 \
    conda-build -c pytorch --no-anaconda-upload faiss-gpu; \
    done
