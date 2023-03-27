from numpy import clip,subtract,zeros,uint32,max,mean,indices,einsum,sqrt,ndindex
from itertools import product

def is_valid_region(region:tuple[slice],borders:tuple[tuple]):
    '''
    gets a region as tuple of slices of N dimension and a tuple of start border and end border (both inclusive) of N dimension\n
    returns True if region is within borders
    soft checks on input
    '''
    return borders is not None and region is not None and all(reg_slice.start >= min_val and reg_slice.stop <= max_val for reg_slice,(min_val,max_val) in zip(region,zip(borders[0],borders[1])))

def get_squared_region(center_point:tuple,region_size:int,clipping_min_max: tuple[tuple] or None=None) -> tuple[slice]:
    '''
    creates a tuple of ndimensions of slices with start (center - region_size) and stop (center + region_size + 1) values that map a (possibly) squared region\n
    if clipping_min_max tuple is provided the region is clipped with borders (both inclusive)\n
    supports any dimension but does not check correctness of input to go brrrr
    '''
    if clipping_min_max is not None:
        min_v, max_v = clipping_min_max[0],clipping_min_max[1]
        start_point = clip(subtract(center_point,region_size),min_v,max_v)
        end_point = clip(subtract(center_point,-(region_size+1)),min_v,max_v)
    else:
        start_point = subtract(center_point,region_size)
        end_point = subtract(center_point,-(region_size+1))
    return tuple(slice(*start_end) for start_end in zip(start_point,end_point))    # returns slices

def get_region_size(region:tuple[slice]):
    return tuple(reg_slice.stop-reg_slice.start for reg_slice in region)

def region_generator(center_point:tuple,region_size:int,clipping_min_max: tuple[tuple] or None=None,C_style_iterator=False):
    '''
    Creates a squared region generator from a center and region_size half side.\n
    No checks on input correctness to go brr

    Params
    -------
        center_point : the center as a tuple of points in whatever dimension (1D,2D,3D,4D,for more, a Sycamore chip is required)\n
        region_size : size of the region (the square will be center - region to center + region with endpoint included)\n
        C_style_iterator : if False loops from left to right, else from right to left
            example: in 2D and C_style_iterator False is for COLS { for ROWS { arr[ ROW , COL ] } }
    '''
    region = get_squared_region(center_point,region_size,clipping_min_max)
    if not C_style_iterator:
        for point in product(*(range(reg_slice.start, reg_slice.stop) for reg_slice in region[::-1])):
            yield tuple(reversed(point))
    else:
        for point in product(*(range(reg_slice.start, reg_slice.stop) for reg_slice in region)):
            yield point

#-----------------------------TESTING-------------------------------

import numpy as np


def compute_center_of_gravity(image,spacing):
    
    image_dim = image.shape
    
    physical_spacing = np.array(spacing)
    
    image_region = np.array(image_dim)

    pixel_indices = np.array(list(region_generator(zeros(len(image_dim),dtype=int),image_dim[0],clipping_min_max=(zeros(len(image_dim),dtype=int),image_dim))))
    # Compute the zeroth moment
    m0 = np.sum(image)
    #if m0 == 0:
    #    return True, 0
    #m1 = np.sum(np.multiply(pixel_indices, image.reshape(-1,1)),axis=0)
    m1 = np.einsum('i...,ij->j...', pixel_indices, image.reshape(-1, 1))
    #m2 = np.sum(np.multiply())
    #[TODO] per m2 mi viene detto che si possa calcolare così
    #pixel_indices_squared = pixel_indices ** 2
    second_moment = np.einsum('i...,ij,ik->jk...', pixel_indices,pixel_indices, image.reshape(-1, 1), image.reshape(-1, 1))
    ##################
    weights = image.reshape(-1)[:, np.newaxis, np.newaxis] * pixel_indices * pixel_indices[:, np.newaxis]
    # Compute the first and second order moments
    for i in range(image_dim):
        self.m1[i] = np.sum(pixel_indices[:, i] * pixel_values)
        for j in range(image_dim):
            self.m2[i][j] = np.sum(pixel_indices[:, i] * pixel_indices[:, j] * pixel_values)
    # Compute the centroid
    self.cg = np.divide(self.m1, self.m0)
    # Compute the central moments
    for i in range(image_dim):
        for j in range(image_dim):
            self.cm[i][j] = self.m2[i][j] - self.m1[i] * self.m1[j] / self.m0
    # Compute the principal moments and axes
    eigenvalues, eigenvectors = np.linalg.eig(self.cm)
    eigenvectors = eigenvectors.T
    self.pm = eigenvalues * self.m0
    self.pa = eigenvectors
    # Add a final reflection if needed for a proper rotation,
    # by multiplying the last row by the determinant
    det = np.linalg.det(self.pa)
    self.pa[-1] = self.pa[-1] * np.real(det)

















def calculate_moments(img):
    # Convert the image to grayscale and normalize the pixel values
    max_value = max(img)
    if max_value != 0: gray = img.astype(float) / max(img)
    else: gray = img.astype(float)
    
    # Calculate the moments of the image
    num_dims = len(img.shape)
    coords = indices(img.shape, dtype=float)
    coords_flat = coords.reshape(num_dims, -1)
    w = gray.reshape(-1)
    coords_shifted = coords_flat - mean(coords_flat, axis=1, keepdims=True)
    coords_outer = einsum('ik,jk->ijk', coords_shifted, coords_shifted)
    moments = einsum('i,j,ijk->ij', w, w, coords_outer)
    for p in range(num_dims+1):
        for q in range(num_dims+1):
            if p + q > 1:
                moments[p, q] = moments[p, q] / moments[0, 0]**(1 + (p + q)/2)
    
    # Return the moments as a dictionary
    moments_dict = {}
    for p, q in ndindex(moments.shape):
        key = f'm{p}{q}'
        moments_dict[key] = moments[p, q]
    return moments_dict
    
def calculate_center_of_gravity(moments):
    # Calculate the center of gravity using the moments
    num_dims = int(sqrt(len(moments))) - 1
    coords = [moments[f'm10'] / moments['m00'], moments[f'm01'] / moments['m00']]
    for i in range(2, num_dims):
        p = str(i) + '0'
        q = '0' + str(i)
        coords.append(moments[p] / moments['m00'])
        coords.append(moments[q] / moments['m00'])
    return tuple(coords)

#---------------------end testing--------------------------------------