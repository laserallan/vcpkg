include(vcpkg_common_functions)
find_program(GIT git)

set(GIT_URL "https://github.com/llvm-mirror/llvm.git")
set(GIT_REF "a4cf325")

if(NOT EXISTS "${DOWNLOADS}/llvm.git")
    message(STATUS "Cloning")
    vcpkg_execute_required_process(
        COMMAND ${GIT} clone --bare ${GIT_URL} ${DOWNLOADS}/llvm.git
        WORKING_DIRECTORY ${DOWNLOADS}
        LOGNAME clone
    )
endif(NOT EXISTS "${DOWNLOADS}/llvm.git")
message(STATUS "Cloning done")

if(NOT EXISTS "${CURRENT_BUILDTREES_DIR}/src/.git")
    message(STATUS "Adding worktree")
    file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR})
    vcpkg_execute_required_process(
        COMMAND ${GIT} worktree add -f --detach ${CURRENT_BUILDTREES_DIR}/src ${GIT_REF}
        WORKING_DIRECTORY ${DOWNLOADS}/llvm.git
        LOGNAME worktree
    )
endif(NOT EXISTS "${CURRENT_BUILDTREES_DIR}/src/.git")
message(STATUS "Adding worktree done")

set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/)

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES 
        ${CMAKE_CURRENT_LIST_DIR}/Math.h.patch
        ${CMAKE_CURRENT_LIST_DIR}/InstrProfReader.h.patch
        ${CMAKE_CURRENT_LIST_DIR}/CostAllocator.h.patch
)


# CURRENT_PACKAGES_DIR is not set here but we need it to
# Get the path to half.h into the includes
# and the path to the binaries dir to include half.dll for the build to work

# set(PRE_PACKAGES_DIR ${CURRENT_PACKAGES_DIR}/../../installed/${TARGET_TRIPLET})
# set(ENV{PATH} "$ENV{PATH};${PRE_PACKAGES_DIR}/bin")
vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS -DLLVM_BUILD_LLVM_DYLIB:BOOL=ON
    #OPTIONS_RELEASE 
    #OPTIONS_DEBUG 
)

vcpkg_install_cmake()


file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
# Remove LTO.dll which for some reason is always built as a DLL
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/intrinsics_gen)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/intrinsics_gen)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/llvm/IR/x64)

file(COPY ${SOURCE_PATH}/LICENSE.TXT DESTINATION ${CURRENT_PACKAGES_DIR}/share/llvm)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/llvm/LICENSE.TXT ${CURRENT_PACKAGES_DIR}/share/llvm/copyright)

set(BIN_ROOT_RELEASE ${CURRENT_PACKAGES_DIR}/bin) 
set(BIN_ROOT_DEBUG ${CURRENT_PACKAGES_DIR}/debug/bin) 

file(GLOB BINS ${BIN_ROOT_RELEASE}/*.exe ${BIN_ROOT_DEBUG}/*.exe)


# Remove exe's
foreach(BIN_FILE ${BINS})
	file(REMOVE ${BIN_FILE})
endforeach(BIN_FILE)
	
vcpkg_copy_pdbs()
