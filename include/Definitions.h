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

typedef itk::Image<short, 3>                                  ImageType;
typedef ImageType::Pointer                                    ImagePointerType;
typedef itk::Point<double,3>                                  PhysicalPointType;
typedef ImageType::IndexType 	                              VoxelPointType;
typedef itk::ImageFileReader< ImageType >                     ImageReaderType;
typedef itk::ImageMomentsCalculator<ImageType>                CalculatorType;
typedef ImageType::SizeType                                   SizeType;
typedef ImageType::RegionType 	              	              RegionType;
typedef ImageType::SpacingType                                SpacingType;
typedef itk::RegionOfInterestImageFilter<ImageType,ImageType> FilterType;

const double MAX_VALUE =  3.402823466e+38F;

// Angles for the trajectory reconstruction
//const static double MAX_ANGLE = 0,990268069   // otto gradi
static const double MAX_ANGLE = 0.978147601;  // dodici gradi
// const static double MAX_ANGLE = 0.984807753; // dieci gradi
// const static double MAX_ANGLE = 0.996194698; // cinque gradi



#endif
