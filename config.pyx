cdef int N_CHARS, N_TAXA, N_SITES, N_GEN, THIN
cdef list ALPHABET, TAXA
cdef double NORM_BETA
cdef dict LEAF_LLMAT
cdef str MODEL, IN_DTYPE

N_CHARS = 0
N_TAXA = 0
N_SITES = 0
N_GEN = 0
THIN = 0

ALPHABET = []
TAXA = []

NORM_BETA = 0.0

LEAF_LLMAT = {}

MODEL = ""
IN_DTYPE = ""