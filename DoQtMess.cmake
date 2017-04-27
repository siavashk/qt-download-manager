function(Clarius_CLEAN_PATHS)
  foreach(_path_group ${ARGN})
    foreach(_path ${${_path_group}})
      get_filename_component(_path_cleaned ${_path} REALPATH)
      file(TO_NATIVE_PATH ${_path_cleaned} _path_cleaned)
      set(_path_group_cleaned ${_path_group_cleaned} ${_path_cleaned})
    endforeach()
    set(${_path_group} ${_path_group_cleaned} PARENT_SCOPE)
  endforeach()
endfunction()

macro(Clarius_HANDLE_CYCLICAL_LINKING LIBS)
    if(CMAKE_COMPILER_IS_GNUCC OR CMAKE_COMPILER_IS_GNUCXX OR (CMAKE_CXX_COMPILER_ID STREQUAL "Clang" AND NOT APPLE))
        set(${LIBS} -Wl,--start-group ${${LIBS}} -Wl,--end-group)
    endif()
endmacro()

# let's not be picky, just throw all the available static libraries at the linker and let it figure out which ones are actually needed
# a 'foreach' is used because 'target_link_libraries' doesn't handle lists correctly (the ; messes it up and nothing actually gets linked against)
if(Clarius_TARGET_IS_WINDOWS)
    set(_DEBUG_SUFFIX d)
elseif(Clarius_TARGET_IS_IOS OR Clarius_TARGET_IS_MAC)
    set(_DEBUG_SUFFIX _debug)
else()
    set(_DEBUG_SUFFIX)
endif()

set(_LIBS_BASE_DIR "${Qt5_DIR}/../../../lib")
Clarius_CLEAN_PATHS(_LIBS_BASE_DIR)
file(GLOB_RECURSE _QT_LIBS "${_LIBS_BASE_DIR}/*${CMAKE_STATIC_LIBRARY_SUFFIX}")
foreach(_QT_LIB ${_QT_LIBS})
    string(REGEX MATCH ".*${_DEBUG_SUFFIX}${CMAKE_STATIC_LIBRARY_SUFFIX}$" _IS_DEBUG_LIB ${_QT_LIB})
    string(REGEX MATCH ".*_iphonesimulator${_DEBUG_SUFFIX}${CMAKE_STATIC_LIBRARY_SUFFIX}$" _IS_DEBUG_SIM_LIB ${_QT_LIB})
    string(REGEX MATCH ".*_iphonesimulator${CMAKE_STATIC_LIBRARY_SUFFIX}$" _IS_SIM_LIB ${_QT_LIB})
    string(REGEX MATCH ".*Qt5Bootstrap.*" _IS_BOOTSTRAP ${_QT_LIB})
    string(REGEX MATCH ".*Qt5QmlDevTools.*" _IS_DEVTOOLS ${_QT_LIB})

    if(NOT _IS_BOOTSTRAP AND NOT _IS_DEVTOOLS AND NOT _IS_DEBUG_SIM_LIB AND NOT _IS_SIM_LIB)
        if(_IS_DEBUG_LIB OR NOT _DEBUG_SUFFIX)
            set(QT_EXTRA_LIBS ${QT_EXTRA_LIBS} debug "${_QT_LIB}")
        endif()
        if(NOT _IS_DEBUG_LIB OR NOT _DEBUG_SUFFIX)
            set(QT_EXTRA_LIBS ${QT_EXTRA_LIBS} optimized "${_QT_LIB}")
        endif()
    endif()
endforeach()

set(_QML_BASE_DIR "${Qt5_DIR}/../../../qml")
Clarius_CLEAN_PATHS(_QML_BASE_DIR)
file(GLOB_RECURSE _QML_PLUGINS "${_QML_BASE_DIR}/*${CMAKE_STATIC_LIBRARY_SUFFIX}")
foreach(_QML_PLUGIN ${_QML_PLUGINS})
    string(REGEX MATCH ".*${_DEBUG_SUFFIX}${CMAKE_STATIC_LIBRARY_SUFFIX}$" _IS_DEBUG_LIB ${_QML_PLUGIN})
    string(REGEX MATCH ".*_iphonesimulator${_DEBUG_SUFFIX}${CMAKE_STATIC_LIBRARY_SUFFIX}$" _IS_DEBUG_SIM_LIB ${_QML_PLUGIN})
    string(REGEX MATCH ".*_iphonesimulator${CMAKE_STATIC_LIBRARY_SUFFIX}$" _IS_SIM_LIB ${_QML_PLUGIN})

    if(NOT _IS_DEBUG_SIM_LIB AND NOT _IS_SIM_LIB)
        if(_IS_DEBUG_LIB OR NOT _DEBUG_SUFFIX)
            set(QT_EXTRA_LIBS ${QT_EXTRA_LIBS} debug "${_QML_PLUGIN}")
        endif()
        if(NOT _IS_DEBUG_LIB OR NOT _DEBUG_SUFFIX)
            set(QT_EXTRA_LIBS ${QT_EXTRA_LIBS} optimized "${_QML_PLUGIN}")
        endif()
    endif()
endforeach()

set(_PLUGINS_BASE_DIR "${Qt5_DIR}/../../../plugins")
Clarius_CLEAN_PATHS(_PLUGINS_BASE_DIR)
file(GLOB_RECURSE _QT_PLUGINS "${_PLUGINS_BASE_DIR}/*${CMAKE_STATIC_LIBRARY_SUFFIX}")
foreach(_QT_PLUGIN ${_QT_PLUGINS})
    string(REGEX MATCH ".*${_DEBUG_SUFFIX}${CMAKE_STATIC_LIBRARY_SUFFIX}$" _IS_DEBUG_LIB ${_QT_PLUGIN})
    string(REGEX MATCH ".*_iphonesimulator${_DEBUG_SUFFIX}${CMAKE_STATIC_LIBRARY_SUFFIX}$" _IS_DEBUG_SIM_LIB ${_QT_PLUGIN})
    string(REGEX MATCH ".*_iphonesimulator${CMAKE_STATIC_LIBRARY_SUFFIX}$" _IS_SIM_LIB ${_QT_PLUGIN})

    if(NOT _IS_DEBUG_SIM_LIB AND NOT _IS_SIM_LIB)
        if(_IS_DEBUG_LIB OR NOT _DEBUG_SUFFIX)
            set(QT_EXTRA_LIBS ${QT_EXTRA_LIBS} debug "${_QT_PLUGIN}")
        endif()
        if(NOT _IS_DEBUG_LIB OR NOT _DEBUG_SUFFIX)
            set(QT_EXTRA_LIBS ${QT_EXTRA_LIBS} optimized "${_QT_PLUGIN}")
        endif()
    endif()
endforeach()

set(QT_EXTRA_LIBS ${QT_EXTRA_LIBS}
    "-framework Foundation -framework CoreWLAN -framework ApplicationServices -framework AGL \
-framework DiskArbitration -framework CoreServices -framework Cocoa -framework IOKit -framework SystemConfiguration \
-framework OpenGL -framework Carbon -framework CoreText -framework QuartzCore -framework CoreGraphics \
-framework CoreVideo -framework CoreMedia -framework AVFoundation -framework CoreFoundation -framework AudioUnit \
-framework AppKit -framework AudioToolbox \
-framework Security -framework CFNetwork -framework CoreBluetooth -framework IOBluetooth -framework CoreLocation -lz -lcups"
)

# static linking
set(QT_LIBRARIES ${QT_LIBRARIES} ${QT_EXTRA_LIBS})
Clarius_HANDLE_CYCLICAL_LINKING(QT_LIBRARIES)
