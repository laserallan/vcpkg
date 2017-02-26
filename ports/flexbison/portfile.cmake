
include(vcpkg_common_functions)
find_program(GIT git)

set(GIT_URL "https://github.com/AaronNGray/winflexbison.git")
set(GIT_REF "6e111ff")

if(NOT EXISTS "${DOWNLOADS}/winflexbison.git")
    message(STATUS "Cloning")
    vcpkg_execute_required_process(
        COMMAND ${GIT} clone --bare ${GIT_URL} ${DOWNLOADS}/winflexbison.git
        WORKING_DIRECTORY ${DOWNLOADS}
        LOGNAME clone
    )
endif(NOT EXISTS "${DOWNLOADS}/winflexbison.git")
message(STATUS "Cloning done")

if(NOT EXISTS "${CURRENT_BUILDTREES_DIR}/src/.git")
    message(STATUS "Adding worktree")
    file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR})
    vcpkg_execute_required_process(
        COMMAND ${GIT} worktree add -f --detach ${CURRENT_BUILDTREES_DIR}/src ${GIT_REF}
        WORKING_DIRECTORY ${DOWNLOADS}/winflexbison.git
        LOGNAME worktree
    )
endif(NOT EXISTS "${CURRENT_BUILDTREES_DIR}/src/.git")
message(STATUS "Adding worktree done")
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

#vcpkg_apply_patches(
#    SOURCE_PATH ${SOURCE_PATH}
#    PATCHES
#        ${CMAKE_CURRENT_LIST_DIR}/fix-import-export-macros.patch)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH} )

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(COPY ${SOURCE_PATH}/README.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/flexbison)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/flexbison/README.md ${CURRENT_PACKAGES_DIR}/share/flexbison/copyright)
