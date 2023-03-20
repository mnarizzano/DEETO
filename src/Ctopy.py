from struct import pack

def float_to_unsigned_long(value:float):
    return int(''.join('{:0>8b}'.format(c) for c in pack('!f', value)),2)

from numba import njit
from numpy import empty,uint32

@njit
def compute_statistics(statistics,len_statistics,non_zero_voxels_count):
    summation = 0
    index = 1
    results = empty(len_statistics,dtype=uint32)
    for i in range(1,len_statistics):
        summation += statistics[i]
        c = summation / non_zero_voxels_count
        if c > 0.05 * index:
            results[index] = i
            index += 1
    return results[9]