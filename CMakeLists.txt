cmake_minimum_required(VERSION 3.20)

project("hide_motd" NONE)

set(SOURCEMOD_DIR "" CACHE PATH "Root directory of SourceMod installation (should include addons and cfg folders)")

cmake_path(IS_ABSOLUTE SOURCEMOD_DIR SOURCEMOD_DIR_IS_ABSOLUTE)
if(NOT ${SOURCEMOD_DIR_IS_ABSOLUTE})
    message(FATAL_ERROR "SOURCEMOD_DIR cache variable is not set correctly.")
endif()

set(THIRDPARTY_DIR ${CMAKE_CURRENT_SOURCE_DIR}/thirdparty/)
set(INCLUDE_DIR ${CMAKE_CURRENT_BINARY_DIR}/include/)
set(SCRIPTING_DIR ${CMAKE_CURRENT_SOURCE_DIR}/addons/sourcemod/scripting/)
set(PLUGINS_DIR ${CMAKE_CURRENT_SOURCE_DIR}/addons/sourcemod/plugins/)

set(THIRDPARTY_SUBDIRS
    ${SOURCEMOD_DIR}/addons/sourcemod/scripting/include/
    ${CMAKE_CURRENT_SOURCE_DIR}/include/
)

set(INCLUDE_SUBDIRS
    ${INCLUDE_DIR}
    ${INCLUDE_DIR}
)

file(GLOB_RECURSE SRC_RELATIVE
    LIST_DIRECTORIES false
    RELATIVE ${SCRIPTING_DIR}
    CONFIGURE_DEPENDS
    ${SCRIPTING_DIR}/*.sp
)

set(OUTPUTS "")
foreach(s IN LISTS SRC_RELATIVE)
    get_filename_component(s_STEM ${s} NAME_WE)
    get_filename_component(s_DIR ${s} DIRECTORY)
    list(APPEND OUTPUTS ${CMAKE_CURRENT_BINARY_DIR}/plugins/${s_DIR}/${s_STEM}.smx)
endforeach()

file(MAKE_DIRECTORY ${INCLUDE_DIR})
foreach(t i IN ZIP_LISTS THIRDPARTY_SUBDIRS INCLUDE_SUBDIRS)
    if(EXISTS ${t})
        file(COPY ${t} DESTINATION ${i})
    endif()
endforeach()

add_custom_target(${PROJECT_NAME} ALL
     ${SOURCEMOD_ARGS})

foreach(sr o IN ZIP_LISTS SRC_RELATIVE OUTPUTS)
    cmake_path(GET sr PARENT_PATH ppr)
    file(MAKE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/plugins/${ppr})

    add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD
        COMMAND ${SOURCEMOD_DIR}/addons/sourcemod/scripting/spcomp
        ARGS ${SCRIPTING_DIR}/${sr} -o ${o} -i ${INCLUDE_DIR}
        BYPRODUCTS ${o})

    unset(ppr)
endforeach()

install(FILES ${OUTPUTS} DESTINATION ${PLUGINS_DIR})
