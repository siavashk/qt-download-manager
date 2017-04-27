cmake_minimum_required(VERSION 2.8.11)

project(download)

# Find includes in the build directories
set(CMAKE_INCLUDE_CURRENT_DIR ON)

# Turn on automatic invocation of the MOC
set(CMAKE_AUTOMOC ON)

# Add a compiler flag
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall")

# Find the QtWidgets library
find_package(Qt5 COMPONENTS Network)

# Tell CMake to create the helloworld executable
add_executable(download main.cpp)

include("DoQtMess.cmake")

# Add the Qt5 Widgets for linking
target_link_libraries(download Qt5::Network ${QT_LIBRARIES})
