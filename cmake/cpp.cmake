string(REGEX MATCH "Clang" CMAKE_COMPILER_IS_CLANG "${CMAKE_C_COMPILER_ID}")
string(REGEX MATCH "GNU" CMAKE_COMPILER_IS_GNU "${CMAKE_C_COMPILER_ID}")
string(REGEX MATCH "IAR" CMAKE_COMPILER_IS_IAR "${CMAKE_C_COMPILER_ID}")
string(REGEX MATCH "MSVC" CMAKE_COMPILER_IS_MSVC "${CMAKE_C_COMPILER_ID}")

if(CMAKE_COMPILER_IS_GNU)
    # some warnings we want are not available with old GCC versions
    # note: starting with CMake 2.8 we could use CMAKE_C_COMPILER_VERSION
    execute_process(COMMAND ${CMAKE_C_COMPILER} -dumpversion
                    OUTPUT_VARIABLE GCC_VERSION)
    if (GCC_VERSION VERSION_GREATER 4.5 OR GCC_VERSION VERSION_EQUAL 4.5)
        set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wlogical-op")
    endif()
    if (GCC_VERSION VERSION_GREATER 4.8 OR GCC_VERSION VERSION_EQUAL 4.8)
        set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wshadow")
    endif()
endif(CMAKE_COMPILER_IS_GNU)


if(CMAKE_COMPILER_IS_GNU OR CMAKE_COMPILER_IS_CLANG)

	#set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -Wextra -Wpedantic -Wconversion -Wold-style-cast")
	set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -Wextra -W -Wpedantic -Wconversion -Wold-style-cast -Wwrite-strings")
	#set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wall -Wextra -Wpedantic -Wconversion")
	set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wall -Wextra -W -Wpedantic -Wconversion -Wdeclaration-after-statement -Wwrite-strings")
	if(ASAN)
		set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fsanitize=address -fsanitize=undefined")
		set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fsanitize=address -fsanitize=undefined")
		#list( APPEND LIBRARIES asan ubsan )
		set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -lasan -lubsan")
		set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -lasan -lubsan")
	elseif(TSAN)
		set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fsanitize=thread")
		set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fsanitize=thread")
		#list( APPEND LIBRARIES tsan )
		set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -ltsan")
	endif()

	# None Debug Release Coverage ASan ASanDbg MemSan MemSanDbg TSan TSanDbg"
	if(CMAKE_BUILD_TYPE STREQUAL "Coverage")
		if(CMAKE_COMPILER_IS_GNU OR CMAKE_COMPILER_IS_CLANG)
			set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} --coverage")
			set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} --coverage")
			set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} --coverage")
		endif(CMAKE_COMPILER_IS_GNU OR CMAKE_COMPILER_IS_CLANG)
	endif(CMAKE_BUILD_TYPE STREQUAL "Coverage")

	if(CMAKE_BUILD_TYPE STREQUAL "ASan")
		set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fsanitize=address -fsanitize=undefined -fno-common")
		set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fsanitize=address -fsanitize=undefined -fno-common")
		set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -lasan -lubsan")
		set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -lasan -lubsan")
	endif(CMAKE_BUILD_TYPE STREQUAL "ASan")

	if(CMAKE_BUILD_TYPE STREQUAL "ASanDbg")
		set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${CMAKE_CXX_FLAGS_DEBUG} -fsanitize=address -fsanitize=undefined -fno-common -fno-omit-frame-pointer -fno-optimize-sibling-calls -O0")
		set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${CMAKE_C_FLAGS_DEBUG} -fsanitize=address -fsanitize=undefined -fno-common -fno-omit-frame-pointer -fno-optimize-sibling-calls -O0")
		#list( APPEND LIBRARIES asan ubsan )
		set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -lasan -lubsan")
		set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -lasan -lubsan")
		set(DEBUGINFO ON)
	endif(CMAKE_BUILD_TYPE STREQUAL "ASanDbg")

	if(CMAKE_BUILD_TYPE STREQUAL "Debug")
		set(DEBUGINFO ON)
		set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -O0")
		set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -O0")
	endif(CMAKE_BUILD_TYPE STREQUAL "Debug")

	if(DEBUGINFO)
		string(FIND CMAKE_CXX_FLAGS  " -g" res)
		if(res EQUAL -1) 
		    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -g")
		endif(res EQUAL -1)
		string(FIND CMAKE_C_FLAGS  " -g" res)
		if(res EQUAL -1) 
		    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -g")
		endif(res EQUAL -1)
	endif()

endif(CMAKE_COMPILER_IS_GNU OR CMAKE_COMPILER_IS_CLANG)
