include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/ilmbase-2.2.0)
vcpkg_download_distfile(ARCHIVE
    URLS "http://download.savannah.nongnu.org/releases/openexr/ilmbase-2.2.0.tar.gz"
    FILENAME "ilmbase-2.2.0.tar.gz"
    SHA512 0bbad14ed2bd286dff3987b16ef8631470211da54f822cb3e29b7931807216845ded81c9bf41fd2d22a8b362e8b9904a5450f61f5a242e460083e86b846513f1
)
vcpkg_extract_source_archive(${ARCHIVE})


vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    # OPTIONS -DUSE_THIS_IN_ALL_BUILDS=1
    # OPTIONS_RELEASE -DOPTIMIZE=1
    # OPTIONS_DEBUG -DDEBUGGABLE=1
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/ilmbase)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/ilmbase/LICENSE ${CURRENT_PACKAGES_DIR}/share/ilmbase/copyright)

# If building dll, make sure the dll files are copied to the bin directory 
set(LIB_ROOT_RELEASE ${CURRENT_PACKAGES_DIR}/lib) 
set(LIB_ROOT_DEBUG ${CURRENT_PACKAGES_DIR}/debug/lib) 
set(BIN_ROOT_RELEASE ${CURRENT_PACKAGES_DIR}/bin) 
set(BIN_ROOT_DEBUG ${CURRENT_PACKAGES_DIR}/debug/bin) 

if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
	file(MAKE_DIRECTORY ${BIN_ROOT_RELEASE})
	file(MAKE_DIRECTORY ${BIN_ROOT_DEBUG})
	file(GLOB RELEASE_DLLS ${LIB_ROOT_RELEASE}/*.dll)
	file(GLOB DEBUG_DLLS ${LIB_ROOT_DEBUG}/*.dll)

foreach(DLL_FILE ${RELEASE_DLLS})
	get_filename_component(DLL_ONLY ${DLL_FILE} NAME)
	file(RENAME ${DLL_FILE} ${BIN_ROOT_RELEASE}/${DLL_ONLY})
endforeach(DLL_FILE)

foreach(DLL_FILE ${DEBUG_DLLS})
	get_filename_component(DLL_ONLY ${DLL_FILE} NAME)
	file(RENAME ${DLL_FILE} ${BIN_ROOT_DEBUG}/${DLL_ONLY})
endforeach(DLL_FILE)
	
endif()

vcpkg_copy_pdbs()
