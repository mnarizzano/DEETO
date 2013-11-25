cmake_minimum_required(VERSION 2.6)
project(DEETO)


find_package(VTK REQUIRED)
if(VTK_FOUND)
  include(${VTK_USE_FILE})
  message(STATUS "VTK Ok!")
endif(VTK_FOUND)


find_package(ITK REQUIRED)
if(ITK_FOUND)
  include(${ITK_USE_FILE})
  message(STATUS "ITK Ok!")
endif(ITK_FOUND)


set(VTK_LIBRARIES vtkIO vtkVolumeRendering vtkWidgets vtkHybrid QVTK) #VTK
set(LINK_LIBRARIES ${VTK_LIBRARIES} ${ITK_LIBRARIES})
set(SRC src/main.cpp)
include(${VTK_USE_FILE})
include_directories(include/)
add_definitions(${VTK_DEFINITIONS})
add_definitions(${ITK_DEFINITIONS})
add_executable(deeto ${SRC})
target_link_libraries(deeto ${LINK_LIBRARIES})





