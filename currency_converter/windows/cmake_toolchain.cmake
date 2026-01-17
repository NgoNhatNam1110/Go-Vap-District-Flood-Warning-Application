# CMake toolchain to handle Firebase SDK's older CMake requirements
# This allows the project to work with CMake 3.14+ while handling dependencies that require 3.1

# Override cmake_minimum_required for subdirectories
macro(cmake_minimum_required)
  if(${ARGC} GREATER 0)
    set(CMAKE_MINIMUM_REQUIRED_VERSION ${ARGV0})
    set(CMAKE_MINIMUM_REQUIRED_VERSION_FOUND TRUE)
  endif()
endmacro()

# Set the policy to allow older CMake minimum requirements in dependencies
if(POLICY CMP0089)
  cmake_policy(SET CMP0089 NEW)
endif()
