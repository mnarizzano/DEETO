from typing import List
from numpy.typing import NDArray
import SimpleITK as sitk
#import itk
#from itk import array_from_image,imread,US, itkImageMomentsCalculatorPython
from numpy import array,zeros,uint32,int32,float64,sum
from numpy.linalg import norm

from image_tools import *

class ElectrodeTrajectoryConstructor():
    
    MAX_VALUE = 3.402823466e+38
    MAX_ANGLE = 0.978147601         # 12 degrees
    #CONTACT_DIAMETER = 0.8
    #CONTACT_LEN = 2.5

    def _compute_threshold(self,itk_image):
        image = sitk.GetArrayFromImage(itk_image)
        image = image[image!=0].ravel()
        return sorted(image)[int(len(image)*0.45)]

    def __init__(self, nii_gz_path:str) -> None:
        try:
            #self._image = imread(nii_gz_path,US)
            #print(sitk.ReadImage(nii_gz_path,sitk.sitkUInt32).GetSize())
            image = sitk.ReadImage(nii_gz_path,sitk.sitkUInt32)
            #self._image_array = array_from_image(self._image)
        except:
            raise RuntimeError("File nii_gz error")
        self._min_region_size = 3
        self._max_region_size = 10
        self._zero_vect = zeros(len(image.GetSize()),dtype=int)
        self._size_vect = array(image.GetSize(),dtype=int)
        self._threshold = self._compute_threshold(image)
        self._image = image

    def _compute_center_of_gravity(self,image_cropped:sitk.Image,cohords_offsets: tuple[int]):
        '''
        calculates center of gravity of the image cropped in a region
        should work with images of any dimension
        '''
        orig_image = self._image
        size_vect = array(image_cropped.GetSize(),dtype=int)
        m_Cg = zeros(len(size_vect),dtype=float)
        total_mass = 0
        for pixel_index_array in region_generator(tuple(self._zero_vect),max(size_vect),(self._zero_vect,size_vect),as_np_array=True):
            pixel_index_tuple = tuple(map(int,pixel_index_array))
            pixel_value = image_cropped[pixel_index_tuple]
            # double conversion of types is due to incompatibility between simple itk and numpy 
            m_Cg += array(orig_image.TransformIndexToPhysicalPoint(tuple(map(int,pixel_index_array+cohords_offsets)))) * pixel_value
            total_mass += pixel_value
        if total_mass == 0:
            return None
        return m_Cg/total_mass

    def _get_point_with_highest_momentum(self,center_index:tuple[int],min_region_size:int,max_region_size:int):
        img = self._image
        curr_region_size = min_region_size
        borders = (zeros(len(center_index),dtype=uint32),img.GetSize())
        while curr_region_size < max_region_size:
            region = get_squared_region(center_index,curr_region_size)
            if is_valid_region(region,borders):
                center_of_gravity = self._compute_center_of_gravity(img[region],tuple([slce.start for slce in region]))
                if center_of_gravity is None:
                    curr_region_size += 1
                else:
                    return center_of_gravity
            else:
                max_region_size -= 1

        return None

    def _find_head(self,entry_point:NDArray[float64]):
        '''
        iterates over a region around the entry point, finds the first pixel value 
        with pixel intensity above the threshold and with sum of pixel values within the min region that's above the threshold for the region size

        Returns
        ---------
        The head cohordinates as a tuple of floats or None if the head is not found
        '''
        img = self._image
        pixel_intensity_threshold = self._threshold
        min_region_size = self._min_region_size
        max_region_size = self._max_region_size
        center_index = img.TransformPhysicalPointToIndex(entry_point)
        clipping_borders = (zeros(len(center_index),dtype=uint32),img.GetSize())
        for pixel_index in region_generator(center_index,max_region_size,clipping_borders):
            if img[pixel_index] > pixel_intensity_threshold and \
               sum([img[pixel_index_inner] for pixel_index_inner in region_generator(pixel_index,min_region_size,clipping_borders)]) > min_region_size * pixel_intensity_threshold :
                return self._get_point_with_highest_momentum(pixel_index,min_region_size,max_region_size)
        # should never be reached
        return None


    def _get_next_contact(self,p1:NDArray[float64],p2:NDArray[float64],p3:NDArray[float64],dist=float):
        return p2 + (p3 - p2) * (norm(p1-p2)+dist) / norm(p2-p3)

    def _find_tail(self,head_point:NDArray[float64],target_point:NDArray[float64]):
        #TODO perform intermediate checks
        dist = 3.5
        min_region_size = self._min_region_size; max_region_size = self._max_region_size
        p2 = self._get_next_contact(head_point,head_point,target_point,dist*2)
        p2 = self._get_point_with_highest_momentum(p2,min_region_size,max_region_size)
        if p2 is None:
            return None
        p3 = self._get_next_contact(p2,head_point,p2,dist)
        p3 = self._get_point_with_highest_momentum(p3,min_region_size,max_region_size)

    def _compute_trajectory(self,head_point,target_point):
        assert False, "not implemented"

    def _check_point(self,point):
        #TODO better checks
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
        if head_point is None:
            raise Exception('Cannot find head point')
        tail_point = self._find_tail(head_point,target_point)
        if tail_point is None:
            raise Exception('Cannot find tail')
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
    #for i,elem in enumerate(trajectory_points):
    #    if elem != true_values[i]:
    #        raise Exception(f"index: {i}, elem: {elem} != {true_values[i]}")

    # image is [359,541,178]
    # iterators go from left to right