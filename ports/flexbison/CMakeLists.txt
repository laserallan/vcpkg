cmake_minimum_required(VERSION 3.0)
project(flexbison)

#if(CMAKE_BUILD_TYPE STREQUAL Debug)
#    add_definitions(-DBZ_DEBUG) # enable extra assertions
#endif()

file(GLOB_RECURSE COMMON_SOURCES common/*.c)
list(REMOVE_ITEM COMMON_SOURCES ${CMAKE_CURRENT_SOURCE_DIR}/common/m4/lib/regcomp.c)
list(REMOVE_ITEM COMMON_SOURCES ${CMAKE_CURRENT_SOURCE_DIR}/common/m4/lib/regexec.c)
add_library(common STATIC ${COMMON_SOURCES})
target_include_directories(common PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/common/m4 ${CMAKE_CURRENT_SOURCE_DIR}/common/m4/lib ${CMAKE_CURRENT_SOURCE_DIR}/common/misc)

file(GLOB_RECURSE FLEX_SOURCES flex/*.c)
add_executable(flex ${FLEX_SOURCES})
target_include_directories(flex PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/flex)
target_link_libraries(flex common)

file(GLOB_RECURSE BISON_SOURCES bison/src/*.c)
add_executable(bison ${BISON_SOURCES})
target_include_directories(bison PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/bison/src ${CMAKE_CURRENT_SOURCE_DIR}/common/m4 ${CMAKE_CURRENT_SOURCE_DIR}/common/m4/lib ${CMAKE_CURRENT_SOURCE_DIR}/common/misc)
target_link_libraries(bison common)

#set_target_properties(common PROPERTIES ARCHIVE_OUTPUT_NAME bz2) # reqiured for FindBzip2 to work
#if(BUILD_SHARED_LIBS)
#    target_compile_definitions(libbz2 PRIVATE -DBZ_BUILD_DLL)
#endif()

#if(MSVC)
#    add_definitions(-D_CRT_SECURE_NO_WARNINGS)
#    add_definitions(-D_CRT_SECURE_NO_DEPRECATE)
#    add_definitions(-D_CRT_NONSTDC_NO_DEPRECATE)
#endif()

install(TARGETS common
    RUNTIME DESTINATION bin
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib)

#if(NOT BZIP2_SKIP_TOOLS)
#    add_executable(bzip2 bzip2.c ${LIBBZ2_SOURCES})
#    add_executable(bzip2recover bzip2recover.c ${LIBBZ2_SOURCES})
#    install(TARGETS bzip2 bzip2recover DESTINATION tools)
#endif()

#if(NOT BZIP2_SKIP_HEADERS)
#    install(FILES bzlib.h DESTINATION include)
#endif()
