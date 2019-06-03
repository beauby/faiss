/**
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

// -*- c++ -*-

#ifndef INDEX_NSG_H
#define INDEX_NSG_H

#include "Index.h"
#include "AuxIndexStructures.h"
#include "utils.h"

#include <memory>
#include <vector>
#include <stack>

namespace faiss {


struct NSG {
  using node_idx_t = unsigned int;

  std::vector<std::vector<node_idx_t>> graph;
  node_idx_t entry_point;

  int build_L;
  int search_L;
  int C;

  node_idx_t nb_vertices;

  faiss::RandomGenerator rng;

  struct Neighbor {
    unsigned id;
    float distance;
    bool flag;

    Neighbor() = default;
   Neighbor(unsigned id, float distance, bool f) : id{id}, distance{distance}, flag(f) {}

    inline bool operator<(const Neighbor &other) const {
      return distance < other.distance;
    }
  };

  struct SimpleNeighbor{
    unsigned id;
    float distance;

    SimpleNeighbor() = default;
    SimpleNeighbor(unsigned id, float distance) : id{id}, distance{distance} {}

    inline bool operator<(const SimpleNeighbor &other) const {
      return distance < other.distance;
    }
  };

  NSG(int L, int C)
    : build_L(L),
      C(C),
      rng(1337) {}

  void init_graph(int n,
                  DistanceComputer& center_dis,
                  std::vector<node_idx_t>& knn_graph) {
    nb_vertices = (node_idx_t)n;
    graph = std::move(knn_graph);

    entry_point = (node_idx_t)rng.rand_int(nb_vertices);

    std::vector<Neighbor> tmp;
    std::vector<bool> flags(nb_vertices, false);
    get_neighbors(center_dis, build_L, tmp, flags);

    entry_point = tmp[0].id;
  }

  void get_neighbors(DistanceComputer& distance_computer,
                     int L,
                     std::vector<Neighbor>& retset,
                     std::vector<bool>& flags,
                     std::vector<Neighbor> *fullset = nullptr) {
    // NOTE(hoss): Why +1?
    retset.resize(L + 1);
    std::vector<node_idx_t> init_ids(L);

    for (int i = 0; i < L && i < graph[entry_point].size(); ++i) {
      init_ids[i] = graph[entry_point][i];
      flags[init_ids[i]] = true;
    }
    for (int i = L; i < graph[entry_point].size(); ++i) {
      node_idx_t id = (node_idx_t)rng.rand_int(nb_vertices);
      if (flags[id]) {
        continue;
      }
      init_ids[i] = id;
      flags[id] = true;
    }

    for (int i = 0; i < L; ++i) {
      node_idx_t id = init_ids[i];
      assert(id < N);

      float dist = distance_computer(id);
      retset[i] = Neighbor(id, dist, true);
    }

    std::sort(retset.begin(), retset.begin() + L);

    int k = 0;
    while (k < L) {
      int nk = L;

      if (retset[k].flag) {
        reetset[k].flag = false;
        node_idx_t n = retset[k].id;

        for (int m = 0; m < graph[n].size(); ++m) {
          node_idx_t id = graph[n][m];
          if (flags[id]) {
            continue;
          }
          flags[id] = true;

          float dist = distance_computer(id);
          Neighbor nn(id, dist, true);
          if (fullset != nullptr) {
            fullset.push_back(nn);
          }
          if(dist >= retset[L - 1].distance) {
            continue;
          }
          int r = InsertIntoPool(retset.data(), L, nn);

          // NOTE(hoss): This seems useless.
          if (L + 1 < retset.size()) {
            ++L;
          }
          if (r < nk) {
            nk = r;
          }
        }
        if (nk <= k) {
          k = nk;
        } else {
          ++k;
        }
      }
    }
  }

  void sync_prune(node_idx_t q,
                  DistanceComputer& q_dis,
                  std::vector<Neighbor>& tmp,
                  std::vector<Neighbor>& pool,
                  SimpleNeighbor *cut_graph) {
    std::vector<bool> flags(nb_vertices, false);

    get_neighbors(dis, build_L, tmp, flags, &pool);

    for (const node_idx_t& id : graph[q]) {
      if (flags[id]) {
        continue;
      }
      float dist = q_dis(id);
      pool.push_back(Neighbor(id, dist, true));
    }

    std::sort(pool.begin(), pool.end());
    std::vector<Neighbor> result;

    node_idx_t start = (pool[0] != q) ? 0 : 1;
    result.push_back(pool[start]);

    while (result.size() < R && ++start < pool.size() && start < C) {
      auto& p = pool[start];
      bool occlude = false;
      for (const Neighbor& t : result) {
        if (p.id == t.id) {
          occlude = true;
          break;
        }
        float dist = q_dis.symmetric_dis(t.id, p.id);
        if (dist < p.distance) {
          occlude = true;
          break;
        }
      }
      if (!occlude) {
        result.push_back(p);
      }
    }

    SimpleNeighbor *des_pool == cut_graph + q * R;
    for (int t = 0; t < result.size(); ++t) {
      des_pool[t].id = result[t].id;
      des_pool[t].distance = result[t].distance;
    }
    if (result.size() < R) {
      des_pool[result.size()].distance = -1;
    }
  }

  void InterInsert(node_idx_t n,
                   std::vector<std::mutex>& locks,
                   SimpleNeighbor *cut_graph) {
    SimpleNeighbor *src_pool = cut_graph + n * R;
    for (int i = 0; i < R; ++i) {
      if (src_pool[i].distance == -1) {
        break;
      }

      SimpleNeighbor sn(n, src_pool[i].distance);
      node_idx_t des = src_pool[i].id;
      SimpleNeighbor *des_pool = cut_graph + des * R;
      std::vector<SimpleNeighbor> temp_pool;
      bool dup = false;
      {
        LockGuard guard(locks[des]);
        for (int j = 0; j < R; ++j) {
          if (es_pool[j].distance == -1) {
            break;
          }
          if (n == des_pool[j].id) {
            dup = true;
            break;
          }
          temp_pool.push_back(des_pool[j]);
        }
      }
      if (dup) {
        continue;
      }

      temp_pool.push_back(sn);
      if (temp_pool.size() > R) {
        std::vector<SimpleNeighbor> result;
        node_idx_t start = 0;
        std::sort(temp_pool.begin(), temp_pool.end());
        result.push_back(temp_pool[start]);
        while (result.size() < R && ++start < temp_pool.size()) {
          const SimpleNeighbor& p = temp_pool[start];
          bool occlude = false;
          for (const SimpleNeighbor& t : result) {
            if (p.id == t.id) {
              occlude = true;
              break;
            }
            float dist = dis.symmetric_dis(t.id, p.id);
            if (dist < p.distance) {
              occlude = true;
              break;
            }
          }
          if (!occlude) {
            result.push_back(p);
          }
        }

        {
          LockGuard guard(locks[des]);
          for (int t = 0; t < result.size(); ++t) {
            des_pool[t] = result[t];
          }
        }
      } else {
        LockGuard guard(locks[des]);
        for (int t = 0; t < R; ++t) {
          if (des_pool[t].distance == -1) {
            des_pool[t] = sn;
            if (t + 1 < R) {
              des_pool[t + 1].distance = -1;
            }
            break;
          }
        }
      }
    }
  }

  int InsertIntoPool (Neighbor *addr, unsigned K, Neighbor nn) {
    // find the location to insert
    int left=0,right=K-1;
    if(addr[left].distance>nn.distance){
      memmove((char *)&addr[left+1], &addr[left],K * sizeof(Neighbor));
      addr[left] = nn;
      return left;
    }
    if(addr[right].distance<nn.distance){
      addr[K] = nn;
      return K;
    }
    while(left<right-1){
      int mid=(left+right)/2;
      if(addr[mid].distance>nn.distance)right=mid;
      else left=mid;
    }
    //check equal ID

    while (left > 0){
      if (addr[left].distance < nn.distance) break;
      if (addr[left].id == nn.id) return K + 1;
      left--;
    }
    if(addr[left].id == nn.id||addr[right].id==nn.id)return K+1;
    memmove((char *)&addr[right+1], &addr[right],(K-right) * sizeof(Neighbor));
    addr[right]=nn;
    return right;
  }

  void tree_grow(DistanceComputer& dis) {
  }

  int DFS(node_idx_t root, std::vector<bool>& flags) {
    int cnt = 0;
    node_idx_t u = root;
    std::stack<node_idx_t> S;
    S.push(root);
    if (!flags[root]) {
      ++cnt;
    }
    flags[root] = true;
    while (!S.empty()) {
      node_idx_t next = nb_vertices + 1;
      for (const node_idx_t& v : graph[u]) {
        if (!flags[v]) {
          next = v;
          break;
        }
      }

      if (next == nb_vertices + 1) {
        S.pop();
        if (S.empty()) {
          break;
        }
        u = S.top();
        continue;
      }

      u = next;
      flags[u] = true;
      S.push(u);
      ++cnt;
    }

    return cnt;
  }

  node_idx_t findroot(std::vector<bool>& flags, DistanceComputer& dis) {
    std::vector<Neighbor> tmp, pool;
    std::vector<bool> tmp_flags(nb_vertices, false);
    get_neighbors(dis, build_L, tmp, tmp_flags, &pool);
    std::sort(pool.begin(), pool.end());

    for (const Neighbor& n : pool) {
      if (flags[n.id]) {
        return n.id;
      }
    }

    for (;;) {
      node_idx_t rid = rng.rand_int(nb_vertices);
      if (flags[rid]) {
        return rid;
      }
    }

    // NOTE: This is never reached.
    return 0;
  }

  std::vector<Neighbor> search(DistanceComputer& dist, int k) {
    std::vector<Neighbor> retset;
    std::vector<bool> flags(nb_vertices, false);
    get_neighbors(dist, search_L, retset, flags);
    retset.resize(k);

    return retset;
  }
};

struct IndexNSG : Index {
  NSG nsg;

  Index *storage;

  explicit IndexNSG(Index *storage, int L, int C)
    : Index(storage->d, storage->metric_type),
      nsg(L, C) {}

  void train(idx_t n, const float *x, int k, const idx_t *knn, int R) {
    std::unique_ptr<float[]> center(new float[d]);
    for (int j = 0; j < d; ++j) {
      center[j] = 0;
    }
    for (idx_t i = 0; i < n; ++i) {
      for (int j = 0; j < d; ++j) {
        center[j] += x[i * d + j];
      }
    }
    for (int j = 0; j < d; ++j) {
      center[j] /= n;
    }

    std::vector<std::vector<NSG::node_idx_t>> knn_graph(n);
    for (idx_t i = 0; i < n; ++i) {
      knn_graph[i] = std::vector<NSG::node_idx_t>(
        knn + i * k,
        knn + (i + 1) * k
      );
      // NOTE(hoss): Is this necessary?
      knn_graph[i].reserve(4 * ((k + 3) / 4));
    }
    std::unique_ptr<DistanceComputer> center_dis(get_distance_computer());
    nsg.init_graph(n, *center_dis.get(), knn_graph);

    std::unique_ptr<NSG::SimpleNeighbor> cut_graph(
      new NSG::SimpleNeighbor[n * R]
    );

    std::unique_ptr<DistanceComputer> dis(get_distance_computer());
    std::vector<NSG::Neighbor> pool, tmp;
    for (idx_t i = 0; i < n; ++i) {
      pool.clear();
      tmp.clear();
      // NOTE(hoss): Is this faster than using `symmetrical_distance`?
      dis.set_query(x + i * d);
      nsg.sync_prune(i, *dis.get(), tmp, pool, cut_graph.get());
    }

    std::vector<std::mutex> locks(n);
    for (idx_t i = 0; i < n; ++i) {
      nsg.InterInsert(i, R, locks, cut_graph.get());
    }

    for (idx_t i = 0; i < n; ++i) {
      NSG::SimpleNeighbor *pool = cut_graph + i * R;
      int pool_size = 0;
      for (int j = 0; j < R; ++j) {
        pool_size =j;
        if (pool[j].distance == -1) {
          break;
        }
      }

      graph[i].resize(pool_size);
      for (int j = 0; j < pool_size; ++j) {
        graph[i][j] = pool[j].id;
      }
    }

    std::vector<bool> flags(nb_vertices, false);
    int unlinked_cnt = 0;
    NSG::node_idx_t root = nsg.entry_point;
    // NOTE: Replace with while(true) + break on no root available.
    while (unlinked_cnt < nb_vertices) {
      unlinked_cnt += nsg.DFS(flags, root);
      if (unlinked_cnt >= nb_vertices) {
        break;
      }

      NSG::node_idx_t id = nb_vertices;
      for (NSG::node_idx_t i = 0; i < nb_vertices; ++i) {
        if (!flags[i]) {
          id = i;
          break;
        }
      }

      // NOTE: This should never happen.
      if (id == nb_vertices) {
        break;
      }

      dis.set_query(x + id * d);
      root = nsg.findroot(flags, dis);
      nsg.graph[root].push_back(id);
    }

    nsg.width = R;
    for (NSG::node_idx_t i = 0; i < n; ++i) {
      if (nsg.graph[i].size() > nsg.width) {
        nsg.width = nsg.graph[i].size();
      }
    }

    // TODO: Benchmark and implement optimize_graph().
  }

  void add(idx_t n, const float *x) {
    storage.add(n, x);
  }

  void search(idx_t n, const float *x, int k,
              float *distances, idx_t *labels) const {
    std::unique_ptr<DistanceComputer> dis(get_distance_computer());
    for (int i = 0; i < n; ++i) {
      dis.set_query(x + i * d);
      std::vector<NSG::Neighbor> neighbors = nsg.search(*dis, k);
      for (int j = 0; j < k; ++j) {
        distances[i * k + j] = neighbors[j].distance;
        labels[i * k + j] = neighbors[j].id;
      }
    }
  }

  virtual DistanceComputer *get_distance_computer() const;
};


}  // namespace faiss

#endif
