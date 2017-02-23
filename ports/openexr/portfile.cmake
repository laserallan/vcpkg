include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/openexr-2.2.0)
vcpkg_download_distfile(ARCHIVE
    URLS "http://download.savannah.nongnu.org/releases/openexr/openexr-2.2.0.tar.gz"
    FILENAME "openexr-2.2.0.tar.gz"
    SHA512 017abbeeb6b814508180721bc8e8940094965c4c55b135a198c6bcb109a04bf7f72e4aee81ee72cb2185fe818a41d892b383e8d2d59f40c673198948cb79279a
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES 
        ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt.patch
)


# CURRENT_PACKAGES_DIR is not set here but we need it to
# Get the path to half.h into the includes
# and the path to the binaries dir to include half.dll for the build to work

set(PRE_PACKAGES_DIR ${CURRENT_PACKAGES_DIR}/../../installed/${TARGET_TRIPLET})
set(ENV{PATH} "$ENV{PATH};${PRE_PACKAGES_DIR}/bin")
vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS -DILMBASE_PACKAGE_PREFIX=${PRE_PACKAGES_DIR}
    #OPTIONS_RELEASE -DCMAKE_EXE_LINKER_FLAGS=/LIBPATH:"${PRE_PACKAGES_DIR}/lib"
    OPTIONS_DEBUG -DILMBASE_LIB_DIR="${PRE_PACKAGES_DIR}/debug/lib"
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/openexr)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/openexr/LICENSE ${CURRENT_PACKAGES_DIR}/share/openexr/copyright)

# If building dll, make sure the dll files are copied to the bin directory 
set(LIB_ROOT_RELEASE ${CURRENT_PACKAGES_DIR}/lib) 
set(LIB_ROOT_DEBUG ${CURRENT_PACKAGES_DIR}/debug/lib) 
set(BIN_ROOT_RELEASE ${CURRENT_PACKAGES_DIR}/bin) 
set(BIN_ROOT_DEBUG ${CURRENT_PACKAGES_DIR}/debug/bin) 
set(SHARE_ROOT_DEBUG ${CURRENT_PACKAGES_DIR}/debug/share) 

if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
	file(MAKE_DIRECTORY ${BIN_ROOT_RELEASE})
	file(MAKE_DIRECTORY ${BIN_ROOT_DEBUG})
	file(GLOB RELEASE_DLLS ${LIB_ROOT_RELEASE}/*.dll)
	file(GLOB DEBUG_DLLS ${LIB_ROOT_DEBUG}/*.dll)
	file(GLOB BINS ${BIN_ROOT_RELEASE}/*.exe ${BIN_ROOT_DEBUG}/*.exe)

	foreach(DLL_FILE ${RELEASE_DLLS})
		get_filename_component(DLL_ONLY ${DLL_FILE} NAME)
		file(RENAME ${DLL_FILE} ${BIN_ROOT_RELEASE}/${DLL_ONLY})
	endforeach(DLL_FILE)

	foreach(DLL_FILE ${DEBUG_DLLS})
		get_filename_component(DLL_ONLY ${DLL_FILE} NAME)
		file(RENAME ${DLL_FILE} ${BIN_ROOT_DEBUG}/${DLL_ONLY})
	endforeach(DLL_FILE)

	# Remove exe's
	foreach(BIN_FILE ${BINS})
		file(REMOVE ${BIN_FILE})
	endforeach(BIN_FILE)

else()

	file(REMOVE_RECURSE ${BIN_ROOT_RELEASE})
	file(REMOVE_RECURSE ${BIN_ROOT_DEBUG})
	
endif()

# Remove Share in the debug build
file(REMOVE_RECURSE ${SHARE_ROOT_DEBUG})

vcpkg_copy_pdbs()
