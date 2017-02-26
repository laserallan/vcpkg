include(vcpkg_common_functions)
find_program(GIT git)

set(GIT_URL "https://github.com/imageworks/OpenShadingLanguage.git")
set(GIT_REF "085ceb3")

if(NOT EXISTS "${DOWNLOADS}/OpenShadingLanguage.git")
    message(STATUS "Cloning")
    vcpkg_execute_required_process(
        COMMAND ${GIT} clone --bare ${GIT_URL} ${DOWNLOADS}/OpenShadingLanguage.git
        WORKING_DIRECTORY ${DOWNLOADS}
        LOGNAME clone
    )
endif(NOT EXISTS "${DOWNLOADS}/OpenShadingLanguage.git")
message(STATUS "Cloning done")

if(NOT EXISTS "${CURRENT_BUILDTREES_DIR}/src/.git")
    message(STATUS "Adding worktree")
    file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR})
    vcpkg_execute_required_process(
        COMMAND ${GIT} worktree add -f --detach ${CURRENT_BUILDTREES_DIR}/src ${GIT_REF}
        WORKING_DIRECTORY ${DOWNLOADS}/OpenShadingLanguage.git
        LOGNAME worktree
    )
endif(NOT EXISTS "${CURRENT_BUILDTREES_DIR}/src/.git")
message(STATUS "Adding worktree done")

set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/)

# Download flex and bison

vcpkg_download_distfile(ARCHIVE
    URLS "https://sourceforge.net/projects/winflexbison/files/win_flex_bison-latest.zip/download"
    FILENAME "win_flex_bison-latest.zip"
    SHA512 1a6c1fa3b7603df4db2efbb88c31b28ff1a641d4607afdb89e65e76aedf8da821979f1a9f5a1d291149a567c68346321dcbcffe0d517a836e7099b41dc6d9538
)

set(WIN_FLEX_BISON_PATH ${CURRENT_BUILDTREES_DIR}/winflexbison)
vcpkg_extract_source_archive(${ARCHIVE} ${WIN_FLEX_BISON_PATH})



#vcpkg_apply_patches(
#    SOURCE_PATH ${SOURCE_PATH}
#    PATCHES 
#        ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt.patch
#        ${CMAKE_CURRENT_LIST_DIR}/externalpackages.cmake.patch
#        ${CMAKE_CURRENT_LIST_DIR}/CMakeLists_txreader.txt.patch
#        ${CMAKE_CURRENT_LIST_DIR}/CMakeLists_txwriter.txt.patch
#)

# CURRENT_PACKAGES_DIR is not set here but we need it to
# Get the path to half.h into the includes
# and the path to the binaries dir to include half.dll for the build to work
#set(PRE_PACKAGES_DIR ${CURRENT_PACKAGES_DIR}/../../installed/${TARGET_TRIPLET})
set(PRE_PACKAGES_DIR C:/work/code/vcpkg/installed/x64-windows-static)
message(${PRE_PACKAGES_DIR})

# set(ENV{PATH} "$ENV{PATH};${PRE_PACKAGES_DIR}/bin")
#if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    # CYGWIN set to force cmake not to add lib prefix to boost libraries when linkin static 
#    set(BOOST_OPTIONS -DLINKSTATIC:BOOL=ON -DCYGWIN:BOOL=ON -DBoost_DEBUG:BOOL=ON)
#else (VCPKG_LIBRARY_LINKAGE STREQUAL static)
#    set(BOOST_OPTIONS -DOPENEXR_DLL)
#endif (VCPKG_LIBRARY_LINKAGE STREQUAL static)
vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS 
        -DFLEX_EXECUTABLE=${WIN_FLEX_BISON_PATH}/win_flex.exe 
        -DBISON_EXECUTABLE=${WIN_FLEX_BISON_PATH}/win_bison.exe 
        -DLLVM_LIBRARIES=llvmcore 
        -DLLVM_SYSTEM_LIBRARIES=apa 
        -DVERBOSE=1 
        -DLLVM_FIND_QUIETLY=0 
        -DLLVM_DIRECTORY:PATH=C:/work/code/vcpkg/installed/x64-windows-static 
        -DLLVM_STATIC:BOOL=ON 
        -DLLVM_LIB_DIR=C:/work/code/vcpkg/installed/x64-windows-static/lib 
        -DLLVM_INCLUDES=C:/work/code/vcpkg/installed/x64-windows-static/include 
        -DLLVM_VERSION=3.5.2 ${BOOST_OPTIONS} 
        -DVERBOSE=ON
        -DLINKSTATIC=ON
        -DBUILDSTATIC=ON
        -DCYGWIN=ON
    #OPTIONS_RELEASE -DOPENEXR_CUSTOM_LIB_DIR:PATH=${PRE_PACKAGES_DIR}/lib
    #OPTIONS_DEBUG -DOPENEXR_CUSTOM_LIB_DIR:PATH=${PRE_PACKAGES_DIR}/debug/lib
)


vcpkg_install_cmake()


file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/oiio)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/oiio/LICENSE ${CURRENT_PACKAGES_DIR}/share/oiio/copyright)

set(BIN_ROOT_RELEASE ${CURRENT_PACKAGES_DIR}/bin) 
set(BIN_ROOT_DEBUG ${CURRENT_PACKAGES_DIR}/debug/bin) 

file(GLOB BINS ${BIN_ROOT_RELEASE}/*.exe ${BIN_ROOT_DEBUG}/*.exe)


# Remove exe's
foreach(BIN_FILE ${BINS})
	file(REMOVE ${BIN_FILE})
endforeach(BIN_FILE)

if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin)
endif (VCPKG_LIBRARY_LINKAGE STREQUAL static)

	
vcpkg_copy_pdbs()
