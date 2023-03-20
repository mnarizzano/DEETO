from typing import Tuple,List
from itk import xarray_from_image, imread,UC

from numpy import count_nonzero, max, min, nonzero, zeros

from Ctopy import float_to_unsigned_long, compute_statistics


class DEETO():
    
    MAX_VALUE = 3.402823466e+38
    MAX_ANGLE = 0.978147601         # 12 degrees
    CONTACT_DIAMETER = 0.8
    CONTACT_LEN = 2.5

    def __init__(self, nii_gz_path:str) -> None:
        try:
            self._image = xarray_from_image(imread(nii_gz_path,UC))
        except:
            raise RuntimeError("File nii_gz error")
        self._threshold = self._compute_threshold()

    def _compute_threshold(self):
        image = self._image
        non_zero_voxels_count = count_nonzero(image)
        values_array = image[nonzero(image)]
        max_value = float_to_unsigned_long(max(image))
        min_value = float_to_unsigned_long(min(image))
        statistics = zeros(max_value + 1,dtype=int)
        for value in values_array:
            statistics[float_to_unsigned_long(value)] +=1
        return compute_statistics(statistics,len(statistics),non_zero_voxels_count)
        

    def process_electrode(self,
                      e:Tuple[float,float,float] or None=None,
                      t:Tuple[float,float,float] or None=None,
                      m:List[float] or None=None):

        return

        #return p * array([-1,-1,1])

    

if __name__ == '__main__':
# command:
# ./deeto -ct /home/gagg/Desktop/deeto/DEETO/res/r_oarm_seeg_cleaned.nii.gz -e 61.8454 -19.8803 10.6827 -t 5.34427 -16.6807 8.2421 -m 18 2.0 0.8 1.5 1.5 1.5 1.5 1.5 1.5 1.5 1.5 1.5 1.5 1.5 1.5 1.5 1.5 1.5 1.5 1.5 
    sample_input = ((61.8454, -19.8803, 10.6827),
                    (5.34427, -16.6807, 8.2421),
                    [2.0, 0.8, 1.5, 1.5, 1.5, 1.5, 1.5, 1.5, 1.5, 1.5, 1.5, 1.5, 1.5, 1.5, 1.5, 1.5, 1.5, 1.5, 1.5])
                    
    deeto_obj = DEETO('res/ct.nii.gz')
    deeto_obj.process_electrode(*sample_input)
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
    #for i,elem in enumerate(returned):
    #    if elem != true_values[i]:
    #        raise Exception(f"index: {i}, elem: {elem} != {true_values[i]}")