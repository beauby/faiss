/**
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

%module swigfaiss_gpu;

%import "swigfaiss.swig"

%template(GpuResourcesVector) std::vector<faiss::gpu::GpuResourcesProvider*>;


%shared_ptr(faiss::gpu::GpuResources);
%shared_ptr(faiss::gpu::StandardGpuResourcesImpl);

%{

#include <faiss/IndexFlat.h>
#include <faiss/VectorTransform.h>
#include <faiss/IndexPreTransform.h>
#include <faiss/IndexLSH.h>
#include <faiss/IndexPQ.h>
#include <faiss/IndexIVF.h>
#include <faiss/IndexIVFPQ.h>
#include <faiss/Index2Layer.h>
#include <faiss/IndexIVFPQR.h>
#include <faiss/IndexIVFFlat.h>
#include <faiss/IndexPQFastScan.h>
#include <faiss/IndexIVFPQFastScan.h>
#include <faiss/IndexScalarQuantizer.h>
#include <faiss/IndexIVFSpectralHash.h>
#include <faiss/IndexShards.h>
#include <faiss/IndexReplicas.h>
#include <faiss/IndexHNSW.h>
#include <faiss/MetaIndexes.h>
#include <faiss/IndexRefine.h>
#include <faiss/IndexBinaryFlat.h>
#include <faiss/IndexBinaryIVF.h>
#include <faiss/IndexBinaryFromFloat.h>
#include <faiss/IndexBinaryHNSW.h>
#include <faiss/IndexBinaryHash.h>
#include <faiss/IndexLattice.h>

#include <faiss/gpu/StandardGpuResources.h>
#include <faiss/gpu/GpuIndicesOptions.h>
#include <faiss/gpu/GpuClonerOptions.h>
#include <faiss/gpu/GpuIndex.h>
#include <faiss/gpu/GpuIndexFlat.h>
#include <faiss/gpu/GpuIndexIVF.h>
#include <faiss/gpu/GpuIndexIVFPQ.h>
#include <faiss/gpu/GpuIndexIVFFlat.h>
#include <faiss/gpu/GpuIndexIVFScalarQuantizer.h>
#include <faiss/gpu/GpuIndexBinaryFlat.h>
#include <faiss/gpu/GpuAutoTune.h>
#include <faiss/gpu/GpuCloner.h>
#include <faiss/gpu/GpuDistance.h>

int get_num_gpus()
{
    return faiss::gpu::getNumDevices();
}

void gpu_profiler_start()
{
    return faiss::gpu::profilerStart();
}

void gpu_profiler_stop()
{
    return faiss::gpu::profilerStop();
}

void gpu_sync_all_devices()
{
    return faiss::gpu::synchronizeAllDevices();
}

%}

%define DOWNCAST_GPU(subclass)
    if (dynamic_cast<faiss::gpu::subclass *> ($1)) {
      $result = SWIG_NewPointerObj($1,SWIGTYPE_p_faiss__gpu__ ## subclass,$owner);
    } else
%enddef

%typemap(out) faiss::Index * {
    DOWNCAST_GPU(GpuIndexIVFPQ)
    DOWNCAST_GPU(GpuIndexIVFFlat)
    DOWNCAST_GPU(GpuIndexIVFScalarQuantizer)
    DOWNCAST_GPU(GpuIndexFlat)
    // default for non-recognized classes
    DOWNCAST(Index)
    if ($1 == NULL)
    {
#ifdef SWIGPYTHON
        $result = SWIG_Py_Void();
#endif
    } else {
        assert(false);
    }
}

%typemap(out) faiss::IndexBinary * {
    DOWNCAST_GPU(GpuIndexBinaryFlat)
    // default for non-recognized classes
    DOWNCAST(IndexBinary)
    if ($1 == NULL)
    {
#ifdef SWIGPYTHON
        $result = SWIG_Py_Void();
#endif
    } else {
        assert(false);
    }
}

%template() std::pair<int, unsigned long>;
%template() std::map<std::string, std::pair<int, unsigned long> >;
%template() std::map<int, std::map<std::string, std::pair<int, unsigned long> > >;

typedef CUstream_st* cudaStream_t;

// causes weird wrapper bug
%ignore *::allocMemoryHandle;
%ignore faiss::gpu::GpuMemoryReservation;
%ignore faiss::gpu::GpuMemoryReservation::operator=(GpuMemoryReservation&&);

%include  <faiss/gpu/GpuResources.h>
%include  <faiss/gpu/StandardGpuResources.h>

// quiet SWIG warnings
%ignore faiss::gpu::GpuIndexIVF::GpuIndexIVF;

%include <faiss/gpu/GpuIndicesOptions.h>
%include <faiss/gpu/GpuClonerOptions.h>
%include <faiss/gpu/GpuIndex.h>
%include <faiss/gpu/GpuIndexFlat.h>
%include <faiss/gpu/GpuIndexIVF.h>
%include <faiss/gpu/GpuIndexIVFPQ.h>
%include <faiss/gpu/GpuIndexIVFFlat.h>
%include <faiss/gpu/GpuIndexIVFScalarQuantizer.h>
%include <faiss/gpu/GpuIndexBinaryFlat.h>
%include <faiss/gpu/GpuDistance.h>
%include <faiss/gpu/GpuAutoTune.h>

%newobject index_gpu_to_cpu;
%newobject index_cpu_to_gpu;
%newobject index_cpu_to_gpu_multiple;

%include  <faiss/gpu/GpuCloner.h>

%inline %{

// interop between pytorch exposed cudaStream_t and faiss
cudaStream_t cast_integer_to_cudastream_t(long long x) {
  return (cudaStream_t) x;
}

long long cast_cudastream_t_to_integer(cudaStream_t x) {
  return (long) x;
}

%}
