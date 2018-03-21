import numpy as np
import config

#cpdef matML(dict state, list taxa, dict ll_mats):
cpdef matML(pi, int root, dict ll_mats, list edges, tmats):
    LL_mats = []
    LL_mat = {}
    cdef int parent, child
    #cdef double[:] p_t, pi
    #cdef list edges
    #cdef dict p_t
    
    #root = state["root"]
    #p_ts = state["transitionMat"]
    #pi = state["pi"]
    #edges = state["postorder"]
    ll = np.zeros(config.N_SITES)

    for p_t in tmats:
        LL_mat = {}
        for parent, child in edges:
            if child <= config.N_TAXA:
                if parent not in LL_mat:
                    LL_mat[parent] = p_t[parent,child].dot(ll_mats[child])
                else:
                    LL_mat[parent] *= p_t[parent,child].dot(ll_mats[child])
            else:
                if parent not in LL_mat:
                    LL_mat[parent] = p_t[parent,child].dot(LL_mat[child])
                else:
                    X = p_t[parent,child].dot(LL_mat[child])
                    LL_mat[parent] *= X
                
        ll += np.dot(pi, LL_mat[root])/config.N_CATS
        LL_mats.append(LL_mat)
    LL = np.sum(np.log(ll))
    return LL, LL_mats

#cpdef cache_matML(dict state, list taxa, dict ll_mats, list cache_LL_Mats, list nodes_recompute):
cpdef cache_matML(pi, int root, dict ll_mats, list cache_LL_Mats, list nodes_recompute, list edges, tmats):
    LL_mats = []
    cdef dict LL_mat = {}
    #cdef int root, parent, i
    cdef int parent, i
    #cdef double[:] p_t, pi
    #cdef list edges
    #cdef dict p_t
    
    #root = state["root"]
    #p_ts = state["transitionMat"]
    #pi = state["pi"]
    #edges = state["postorder"]
    ll = np.zeros(config.N_SITES)

    for i, p_t in enumerate(tmats):
        LL_mat = {}
        for parent, child in edges:
            if parent in nodes_recompute:
                if child <= config.N_TAXA:
                    if parent not in LL_mat:
                        LL_mat[parent] = p_t[parent,child].dot(ll_mats[child])
                    else:
                        LL_mat[parent] *= p_t[parent,child].dot(ll_mats[child])
                else:
                    if parent not in LL_mat:
                        LL_mat[parent] = p_t[parent,child].dot(LL_mat[child])
                    else:
                        LL_mat[parent] *= p_t[parent,child].dot(LL_mat[child])
            else:
                LL_mat[parent] = cache_LL_Mats[i][parent]#.copy()
        ll += np.dot(pi, LL_mat[root])/config.N_CATS
        LL_mats.append(LL_mat)
    LL = np.sum(np.log(ll))
    return LL, LL_mats


cpdef matML1(dict state, list taxa, dict ll_mats):
    LL_mats = []
    cdef dict LL_mat = {}
    cdef int root, parent, i, child
    #cdef double[:] p_t, pi
    cdef list edges, p_ts
    #cdef double[:] pi
    cdef dict p_t
    cdef int n_cats = config.N_CATS
    cdef float LL
    cdef int n_taxa = config.N_TAXA

    root = state["root"]
    p_ts = state["transitionMat"]
    pi = state["pi"]
    edges = state["postorder"]
    ll = np.zeros((n_cats,config.N_SITES))

    for i, p_t in enumerate(p_ts):
        LL_mat = {}
        for parent, child in edges:
            if child <= n_taxa:
                if parent not in LL_mat:
                    #print(p_ts[i])
                    LL_mat[parent] = p_t[parent,child].dot(ll_mats[child])
                else:
                    LL_mat[parent] *= p_t[parent,child].dot(ll_mats[child])
            else:
                if parent not in LL_mat:
                    LL_mat[parent] = p_t[parent,child].dot(LL_mat[child])
                else:
                    LL_mat[parent] *= p_t[parent,child].dot(LL_mat[child])
        x = np.dot(pi, LL_mat[root])/n_cats
        #print(x)
        ll[i] = x
    #print(ll)
    LL = np.sum(np.log(ll))
    return LL, LL_mats
