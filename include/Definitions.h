#ifndef DEFINITIONS_H
#define DEFINITIONS_H

#include <vector>
#include <string>
#include <sstream>
#include <fstream>
#include <cmath>

#include <itkImage.h>
#include <itkNiftiImageIO.h>
#include <itkSmartPointer.h>
#include <itkImageFileReader.h>
#include <itkPolyLineParametricPath.h>
#include <itkNeighborhoodIterator.h>
#include <itkImageToImageFilter.h>
#include <itkPathIterator.h>
#include <itkImageRegionIterator.h>
#include <itkImageMomentsCalculator.h>
#include <itkRegionOfInterestImageFilter.h>
#include <itkPoint.h>
#include <itkTranslationTransform.h>
#include <itkOrientImageFilter.h>
#include <itkNeighborhoodIterator.h>
#include <itkNeighborhoodInnerProduct.h>
#include <itkDerivativeOperator.h>
#include <itkNiftiImageIO.h>

using namespace std;

typedef typename itk::Image<short, 3>           ImageType;
typedef typename ImageType::Pointer             ImagePointerType;
typedef typename itk::Point<double,3>           PhysicalPointType;  
typedef typename ImageType::IndexType 	        VoxelPointType;
typedef itk::ImageFileReader< ImageType >       ImageReaderType;
typedef itk::ImageMomentsCalculator<ImageType>  CalculatorType;
typedef typename ImageType::SizeType                     SizeType;
typedef typename ImageType::RegionType 		              RegionType;
typedef ImageType::SpacingType                                SpacingType;
typedef itk::RegionOfInterestImageFilter<ImageType,ImageType> FilterType;

#endif
