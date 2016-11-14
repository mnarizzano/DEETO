cmake_minimum_required(VERSION 2.6)
project(DEETO)

# search for ITK
# set(ITK_DIR /home/massimo/Local/ITK-4.8.1/build/)
MESSAGE(STATUS ${ITK_DIR})
find_package(ITK REQUIRED)
if(ITK_FOUND)
  include(${ITK_USE_FILE})
  MESSAGE(STATUS ${ITK_USE_FILE})
endif(ITK_FOUND)

#Check pkg-config
find_package(PkgConfig)
#TODO error if not found

## add a target to generate API documentation with Doxygen
find_package(Doxygen)
if(DOXYGEN_FOUND)
	configure_file(${CMAKE_CURRENT_SOURCE_DIR}/Doxyfile.in ${CMAKE_CURRENT_BINARY_DIR}/Doxyfile @ONLY)
	add_custom_target(doc
		${DOXYGEN_EXECUTABLE} ${CMAKE_CURRENT_BINARY_DIR}/Doxyfile
		WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
		COMMENT "Generating API documentation with Doxygen" VERBATIM
		)
endif(DOXYGEN_FOUND)

set(LINK_LIBRARIES ${ITK_LIBRARIES})
set(SRC src/main.cpp)

include_directories(include/)
add_definitions(${ITK_DEFINITIONS})

add_executable(deeto ${SRC})
target_link_libraries(deeto ${LINK_LIBRARIES})

#install(TARGETS deeto RUNTIME DESTINATION bin)





