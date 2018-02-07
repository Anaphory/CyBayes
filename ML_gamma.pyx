import numpy as np
import config

cpdef matML(dict state, list taxa, dict ll_mats):
    LL_mats = []
    LL_mat = {}
    cdef int root, parent
    #cdef double[:] p_t, pi
    cdef list edges
    #cdef dict p_t
    
    root = state["root"]
    p_ts = state["transitionMat"]
    pi = state["pi"]
    edges = state["postorder"]
    ll = np.zeros(config.N_SITES)

    for p_t in p_ts:
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

cpdef cache_matML(dict state, list taxa, dict ll_mats, dict cache_LL_Mat, list nodes_recompute):
    cdef dict LL_mat = {}
    cdef int root, parent
    #cdef double[:] p_t, pi
    cdef list edges
    #cdef dict p_t
    
    root = state["root"]
    p_t = state["transitionMat"]
    pi = state["pi"]
    edges = state["postorder"]

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
            LL_mat[parent] = cache_LL_Mat[parent]#.copy()
    #print(pi, LL_mat[root])
    #print(np.sum(np.log(np.dot(pi, LL_mat[root]))))
    #ll = np.sum(np.log(np.dot(pi, LL_mat[root])))
    #ll = np.sum(np.log(np.sum(np.dot(pi, LL_mat[root]),axis =0)))
    ll = np.sum(np.log(np.dot(pi, LL_mat[root])))
    return ll, LL_mat


