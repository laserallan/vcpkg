include(vcpkg_common_functions)
find_program(GIT git)

set(GIT_URL "https://github.com/OpenImageIO/oiio.git")
set(GIT_REF "7f26ccd")

if(NOT EXISTS "${DOWNLOADS}/oiio.git")
    message(STATUS "Cloning")
    vcpkg_execute_required_process(
        COMMAND ${GIT} clone --bare ${GIT_URL} ${DOWNLOADS}/oiio.git
        WORKING_DIRECTORY ${DOWNLOADS}
        LOGNAME clone
    )
endif(NOT EXISTS "${DOWNLOADS}/oiio.git")
message(STATUS "Cloning done")

if(NOT EXISTS "${CURRENT_BUILDTREES_DIR}/src/.git")
    message(STATUS "Adding worktree")
    file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR})
    vcpkg_execute_required_process(
        COMMAND ${GIT} worktree add -f --detach ${CURRENT_BUILDTREES_DIR}/src ${GIT_REF}
        WORKING_DIRECTORY ${DOWNLOADS}/oiio.git
        LOGNAME worktree
    )
endif(NOT EXISTS "${CURRENT_BUILDTREES_DIR}/src/.git")
message(STATUS "Adding worktree done")

set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/)

# CURRENT_PACKAGES_DIR is not set here but we need it to
# Get the path to half.h into the includes
# and the path to the binaries dir to include half.dll for the build to work

# set(PRE_PACKAGES_DIR ${CURRENT_PACKAGES_DIR}/../../installed/${TARGET_TRIPLET})
# set(ENV{PATH} "$ENV{PATH};${PRE_PACKAGES_DIR}/bin")
vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS -DILMBASE_PACKAGE_PREFIX=${PRE_PACKAGES_DIR}
    #OPTIONS_RELEASE -DCMAKE_EXE_LINKER_FLAGS=/LIBPATH:"${PRE_PACKAGES_DIR}/lib"
    #OPTIONS_DEBUG -DCMAKE_EXE_LINKER_FLAGS=/LIBPATH:"${PRE_PACKAGES_DIR}/debug/lib"
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
	
vcpkg_copy_pdbs()
