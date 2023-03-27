#from struct import pack

#def float_to_unsigned_long(value:float):
#    return int(''.join('{:0>8b}'.format(c) for c in pack('!f', value)),2)

from numba import njit
from numpy import empty,zeros,uint32,uint32,eye,float32,array
from math import ceil

@njit
def compute_statistics(values_array,max_value,non_zero_voxels_count):
    '''
    # DEPRECATED
    '''
    statistics = zeros(max_value + 1,dtype=uint32)
    for i in range(values_array.shape[0]):
        # [NOTE] richiede cast durante o prima
        statistics[uint32(values_array[i])] +=1
    summation = 0
    index = 1
    results = empty(max_value+1,dtype=uint32)
    for i in range(1,max_value+1):
        summation += statistics[i]
        c = summation / non_zero_voxels_count
        if c > 0.05 * index:
            if index == 9:
                return i
            results[index] = i
            index += 1
    return 0