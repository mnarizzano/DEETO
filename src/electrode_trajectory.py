from typing import Tuple,List
from numpy.typing import NDArray
import SimpleITK as sitk
from itk import array_from_image,imread,US, itkImageMomentsCalculatorPython
from numpy import subtract, array,zeros,ones,empty,uint32,float64,subtract,clip,unique,cumsum,searchsorted
#from numpy import clip, min
from time import time

from Ctopy import compute_statistics
from image_tools import region_generator,compute_center_of_gravity,get_squared_region, is_valid_region,get_region_size


class ElectrodeTrajectoryConstructor():
    
    MAX_VALUE = 3.402823466e+38
    MAX_ANGLE = 0.978147601         # 12 degrees
    #CONTACT_DIAMETER = 0.8
    #CONTACT_LEN = 2.5

    def _compute_threshold(self):
        image = sitk.GetArrayFromImage(self._image)
        self._image_array = image
        # [NOTE] in original code valuesVector iteration that creates statistics vector
        # starts from 1 instead of from 0 but i think it's a bug
        # because it cuts a legitimate value since it's never pushed a 0 value in valuesVector
        #_,counts = unique(image[image != 0][1:], return_counts=True)
        _,counts = unique(image[image != 0], return_counts=True)
        cdf = cumsum(counts,dtype=float)
        return searchsorted(cdf, 0.45*cdf[-1],side='right') # + 1  
        # [NOTE] in original code when computing cumulative sums
        # index of statistics starts from 1 because statistics[0] is always 0 
        # due to the fact that pixel/voxel values = 0 are filtered by the if condition
        # so the indices are shifted by one and returned incorrectly
        # checked with debug enabled and inspection of cdf 

    def __init__(self, nii_gz_path:str) -> None:
        try:
            self._image = sitk.ReadImage(nii_gz_path)
            #self._image2 = array_from_image(imread(nii_gz_path))
            # [NOTE] chiedere come mai sono unsigned short
        except:
            raise RuntimeError("File nii_gz error")
        self._min_region_size = 3
        self._max_region_size = 10
        self._threshold = self._compute_threshold()

    def _get_point_with_highest_momentum(self,center_index:tuple,min_region_size:int,max_region_size:int):
        img = self._image_array
        curr_region_size = min_region_size
        borders = (zeros(len(center_index),dtype=uint32),img.shape)
        while curr_region_size < max_region_size:
            region = get_squared_region(center_index,curr_region_size)
            if is_valid_region(region,borders):
                zero_mass_flag, center_of_gravity = compute_center_of_gravity(img[region],self._image.GetSpacing())
                if not zero_mass_flag:
                    return center_of_gravity
                curr_region_size+=1
            else:
                max_region_size -= 1
            
        return (self.MAX_VALUE,self.MAX_VALUE,self.MAX_VALUE)

    def _find_head(self,entry_point:tuple):
        img = self._image
        pixel_intensity_threshold = self._threshold+1
        min_region_size = self._min_region_size
        max_region_size = self._max_region_size
        center_index = img.TransformPhysicalPointToIndex(entry_point)
        clipping_borders = (zeros(len(center_index),dtype=uint32),img.GetSize())
        #spacing = img.GetSpacing()
        ##region = ones(len(entry_point),dtype=uint32) * (2*self._max_region_size+1)
        for pixel_index in region_generator(center_index,max_region_size,clipping_borders):
            # then there seems to be a double conversion fromIndxToPhysPoint and then back to index
            # just to check if it's inside the region and then get the pixel value
            # point = img.TransformIndexToPhysicalPoint(index)
            #point_index = I2P(pixel_index)
            if img[pixel_index] > pixel_intensity_threshold and \
               sum([img[pixel_index_inner] for pixel_index_inner in region_generator(pixel_index,min_region_size,clipping_borders)]) > min_region_size * pixel_intensity_threshold :
                return self._get_point_with_highest_momentum(pixel_index,min_region_size,max_region_size)
        # should never be reached
        return tuple(ones(len(center_index),dtype=float) * self.MAX_VALUE)
                

    def _find_tail(self,head_point:Tuple[float,float,float],target_point:Tuple[float,float,float]):
        assert False, "not implemented"

    def _compute_trajectory(self,head_point,target_point):
        assert False, "not implemented"

    def _check_point(self,point):
        return point.shape[0] == 3 and (point != self.MAX_VALUE).all()

    def process_electrode(  self,
                            entry_point:NDArray or None=None,
                            target_point:NDArray or None=None,
                            contact_len:float = 2.0,
                            contact_radius:float = 0.8,
                            distances:List[float]=None):   # list of distances between every electrode
        '''
        The update() function in ElectrodeTrajectoryConstructor
        '''
        assert entry_point is not None and target_point is not None and distances is not None
        if not self._check_point(entry_point) or not self._check_point(target_point):
            raise Exception("Wrongly formatted points")
        
        head_point = self._find_head(entry_point)
        tail_point = self._find_tail(head_point, target_point)
        self._compute_trajectory(head_point,tail_point)



        trajectory_points = zeros((len(distances),len(entry_point)))

        ##################
        # TODO implement #
        ##################

        return trajectory_points

    

if __name__ == '__main__':
# command:
# ./deeto -ct /home/gagg/Desktop/deeto/DEETO/res/r_oarm_seeg_cleaned.nii.gz -e 61.8454 -19.8803 10.6827 -t 5.34427 -16.6807 8.2421 -m 18 2.0 0.8 1.5 1.5 1.5 1.5 1.5 1.5 1.5 1.5 1.5 1.5 1.5 1.5 1.5 1.5 1.5 1.5 1.5 
    sample_input = (array((61.8454, -19.8803, 10.6827)),
                    array((5.34427, -16.6807, 8.2421)),
                    2.0, 
                    0.8, 
                    [1.5, 1.5, 1.5, 1.5, 1.5, 1.5, 1.5, 1.5, 1.5, 1.5, 1.5, 1.5, 1.5, 1.5, 1.5, 1.5, 1.5])
                    
    deeto_obj = ElectrodeTrajectoryConstructor('res/ct.nii.gz')
   
    true_values = [(-7.69635,16.6547,8.58488),
                   (-11.1888,16.8029,8.7768),
                   (-14.6808,16.9743,8.9406),
                   (-18.1727,17.1457,9.1044),
                   (-21.6647,17.3171,9.26819),
                   (-25.1566,17.4885,9.43199),
                   (-28.6486,17.6598,9.59578),
                   (-32.1406,17.8312,9.75958),
                   (-35.6325,18.0026,9.92338),
                   (-39.1245,18.174,10.0872),
                   (-42.6164,18.3454,10.251),
                   (-46.1084,18.5168,10.4148),
                   (-49.6004,18.6881,10.5786),
                   (-53.0923,18.8595,10.7424),
                   (-56.5843,19.0309,10.9062),
                   (-60.0763,19.2023,11.07),
                   (-63.5682,19.3737,11.2337),
                   (-67.0602,19.5451,11.3975)]
    trajectory_points = deeto_obj.process_electrode(*sample_input)
    exit(0)
    #for i,elem in enumerate(trajectory_points):
    #    if elem != true_values[i]:
    #        raise Exception(f"index: {i}, elem: {elem} != {true_values[i]}")