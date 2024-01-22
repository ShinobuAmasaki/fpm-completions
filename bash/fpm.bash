
#
# fpm-completions for Bash
#
# Copyright 2024, Amasaki Shinobu
#
# This script is distributed under the MIT license.

echo_if_exist() {
	type "$1" > /dev/null 2>&1 && echo "$1"
}

get_fortran_compilers() {
	local -a fc_list
	fc_list=( "gfortran" "ifort" "ifx" "pgfortran" "nvfortran" "flang" \
				 "lfortran" "lfc" "nagfor" "crayftn" "xlf90" "ftn95"      \
				 "mpifort" "mpif90" "mpif77" "caf" \
	)
	for element in "${fc_list[@]}"; do
		echo_if_exist "$element"
	done
}

get_c_compilers() {
	local -a cc_list
	cc_list=( "gcc" "icc" "icx" "clang" "craycc" "lcc"  \
				 "mpicc" \
	) 
	for element in "${cc_list[@]}"; do
		echo_if_exist "$element"
	done
}

get_cxx_compilers() {
	local -a cxx_list
	cxx_list=( "g++" "icx" "clang++" "mpic++")
	for element in "${cxx_list[@]}"; do
		echo_if_exist "$element"
	done
}

get_archivers() {
	local -a ar_list
	ar_list=( "ar" )
	for element in "${ar_list[@]}"; do
		echo_if_exist "$element"
	done
}

get_runner_commands() {
	local -a runners
	runners=( "cafrun" "mpiexec" "mpirun" "gdb" "valgrind" )
	for element in "${runners[@]}"; do
		echo_if_exist "$element"
	done
}

find_manifest_dir() {
	current=$(pwd)

	while [ "$current" != "/" ]; do
		# Is fpm.toml exist?
		if [ -e "$current/fpm.toml" ]; then
			echo "$current"
			return 0
		else
			current=$(dirname "$current")
		fi
	done

	return 1
}

build_dir_analysis() {
	local -a proj_dir
	proj_dir=$( find_manifest_dir )

	if [ $? -eq 1 ]; then
		return 1
	fi

	local build_dir="$proj_dir/build"

	if [ ! -e "$build_dir" ]; then
		return 
	fi
	
	local -a app_dirs
	app_dirs=($(find "$build_dir" -type d -name app))

	local -a executables
	for dir in "${app_dirs[@]}"; do
		executables+=($(find "$dir" -type f -executable))
	done
	
	if [[ -z "${executables[*]}" ]]; then
		return
	fi

	for element in "${executables[@]}"; do 
	 	echo "$(basename $element)"
	done

}

build_dir_analysis_test() {
	local -a proj_dir
	proj_dir=$(find_manifest_dir)

	if [ $? -eq 1 ]; then
		return 1
	fi

	local build_dir="$proj_dir/build"

	if [ ! -e "$build_dir" ]; then
		return 
	fi

	local -a test_dir
	test_dir=($(find "$build_dir" -type d -name test))

	local -a tests
	for dir in "${test_dir[@]}"; do
		tests=( $(find "$dir" -type f -executable) "${tests[@]}" )
	done 
	
	if [[ -z "${tests[*]}" ]]; then
		return
	fi

	for element in "${tests[@]}"; do 
	 	echo $(basename $element)
	done

}

build_dir_analysis_example() {
	local proj_dir=$(find_manifest_dir)

	if [ $? -eq 1 ]; then
		return 1
	fi

	local build_dir="$proj_dir/build"

	if [ ! -e "$build_dir" ]; then
		return
	fi

	local -a expls_dir
	expls_dir=($(find "$build_dir" -type d -name example))

	local -a expls
	for dir in "${expls_dir[@]}"; do
		expls+=($(find "$dir" -type f -executable))
	done 

	if [[ -z "${expls[*]}" ]]; then
		return
	fi

	for element in "${expls[@]}"; do 
	 	echo $(basename "$element" )
	done

}



_fpm() {
   local cur prev words cword split
   _init_completion || return

   local defaultIFS=$' \t\n'
   local IFS=$defaultIFS

	local profs=( "debug" "release" )

   case $cword in
      1)
		 if [[ "$prev" == "fpm" && "$cur" == "@"* ]]; then
			commands=$(grep "^@" ./fpm.rsp 2>/dev/null | cut -c 1-)
			COMPREPLY=( $(compgen -W "$commands" -- "$cur") )
		 else
         	COMPREPLY=( $(compgen -W 'build clean help install list new publish run test' -- "$cur") )
		 fi
         ;;
      *)
         case ${words[1]} in
            build)
					local all_opts=("--profile" "--no-prune" "--compiler" "--c-compiler" "--cxx-compiler" "--archiver" "--flag" "--c-flag" "--cxx-flag" \
								 "--link-flag"	"--list" "--tests" "--show-model" "--help" "--version" )
					case $prev in
						build)
							targets=($(build_dir_analysis))
							COMPREPLY=( $(compgen -W '${targets[@]} ${all_opts[@]}' -- "$cur" ))
							return
							;;
						--profile)
                     COMPREPLY=( $(compgen -W '${profs[*]}' -- "$cur") )
                     return
                     ;;
                  --no-prune)
                     COMPREPLY=( $(compgen -W '--profile --flag --c-flag --cxx-flag --link-flag --no-rebuild --prefix --bindir --libdir --includedir' -- "$cur") )
                     return
                     ;;
						--compiler)
							compilers=($(get_fortran_compilers))
							COMPREPLY=( $(compgen -W '${compilers[@]}' -- "$cur") )
							return
							;;
						--c-compiler)
							compilers=($(get_c_compilers))
							COMPREPLY=( $(compgen -W '${compilers[@]}' -- "$cur") )
							return
							;;
						--cxx-compiler)
							compilers=($(get_cxx_compilers))
							COMPREPLY=( $(compgen -W '${compilers[@]}' -- "$cur") )
							return
							;;
						--archiver)
							archivers=($(get_archivers))
							COMPREPLY=( $(compgen -W '${archivers[@]}' -- "$cur") )
							return 
							;;
                  --flag)
                     return
                     ;;
                  --c-flag)
                     return
                     ;;
                  --cxx-flag)
                     return
                     ;;
                  --link-flag)
                     return
                     ;;
						*)
							local opts=()
							for opt in "${all_opts[@]}"; do
								if [[ ! "${words[@]}" =~ "$opt" ]]; then
									opts+=( "$opt" )
								fi
							done
                     COMPREPLY=( $(compgen -W '${opts[*]}' -- "$cur") )
							return
							;;
					esac
               ;;
            clean)
               COMPREPLY=( $(compgen -W '--skip --all' -- "$cur") )
               ;;
            help)
               COMPREPLY=( $(compgen -W 'fpm build clean help install list new publish run test runner version manual' -- "$cur") )
               ;;
            install)
               case $prev in
                  install)
                     COMPREPLY=( $(compgen -W '--profile --no-prune --flag --c-flag --cxx-flag --link-flag --no-rebuild --prefix --bindir --libdir --includedir' -- "$cur") )
                     return 
                     ;;
                  --profile)
                     COMPREPLY=( $(compgen -W '$profs[*]' -- "$cur") )
                     return
                     ;;
                  --flag|--c-flag|--cxx-flag|--link-flag)
                     return
                     ;;
                  --no-rebuild)
                     COMPREPLY=( $(compgen -W '--profile --no-prune --flag --c-flag --cxx-flag --link-flag --prefix --bindir --libdir --includedir' -- "$cur") )
                     return
                     ;;
                  --prefix)
                     _filedir -d
                     return
                     ;;
                  --bindir)
                     _filedir -d
                     return
                     ;;
                  --libdir)
                     _filedir -d
                     return
                     ;;
                  --includedir)
                     _filedir -d
                     return
                     ;;
                  *)
                     local all_opts=("--profile" "--no-prune" "--flag" "--c-flag" "--cxx-flag" "--link-flag" "--no-rebuild" "--prefix" "--bindir" "--libdir" "--includedir" )
							local opts=()
							for opt in "${all_opts[@]}"; do
								if [[ ! "${words[@]}" =~ "$opt" ]]; then
									opts+=( "$opt" )
								fi
							done
                     COMPREPLY=( $(compgen -W '${opts[*]}' -- "$cur") )
                     return 
                     ;;

               esac
               ;;
            list)
					COMPREPLY=( $(compgen -W '--help --version' -- "$cur") )
               return
               ;;
            new)
					all_opts=("--lib" "--src" "--app" "--test" "--example" "--backfill" "--full" "--bare" "--help" "--version" )
					case $prev in
						new)
							_filedir -d
							;;
						*)
							local opts=()
							for opt in "${all_opts[@]}"; do
								if [[ ! "${words[@]}" =~ "$opt" ]]; then

									# When --src is specified, remove --lib from completion candidates.
									if [[ "$opt" =~ "--lib" ]]; then
										if [[ "${words[@]}" =~ "--src" ]]; then
										 	 continue
										fi
									fi

									# When --lib is specified, remove --src from completion candidates.
									if [[ "$opt" == "--src" ]]; then
										if [[ "${words[@]}" =~ "--lib" ]]; then
											continue
										fi
									fi

									# When --bare is specified, remove --full from completion candidates.
									if [[ "$opt" == "--full" ]]; then
										if [[ "${words[@]}" =~ "--bare" ]]; then
											continue
										fi
									fi
									
									# When --full is specified, remove --bare from completion candidates.
									if [[ "$opt" == "--bare" ]]; then
										if [[ "${words[@]}" =~ "--full" ]]; then
											continue
										fi
									fi
									
									opts+=( "$opt" )
								fi
							done

                     COMPREPLY=( $(compgen -W '${opts[*]}' -- "$cur") )
                     return
							;;
					esac
               ;;
            publish)
					# Completion for the sub-command publish is not yet provided.
					return
               ;;
            run)
					local all_opts=("--target" "--all" "--example" "--profile" "--no-prune" "--compiler" "--c-compiler" "--cxx-compiler" "--archiver" "--flag" "--c-flag" "--cxx-flag" \
										 "--link-flag" "--list" "--show-model" "--help" "--version" "--runner" "--runner-args" "--" )
					case $prev in
						run)
							local targets=($(build_dir_analysis))
							COMPREPLY=( $(compgen -W '${targets[*]} ${all_opts[*]}' -- "$cur"))
							return 
							;;
						--target)
							local targets=($(build_dir_analysis))
							COMPREPLY=( $(compgen -W '${targets[*]}' -- "$cur" ))
							return 
							;;
						--example)
							local targets=( $(build_dir_analysis_example))
							COMPREPLY=( $(compgen -W '${targets[*]}' -- "$cur" ))
							return
							;;
						--profile)
							COMPREPLY=( $(compgen -W '${profs[*]}' -- "$cur" ))
							return
							;;
						--compiler)
							local compilers=( $(get_fortran_compilers))
							COMPREPLY=( $(compgen -W '${compilers[*]}' -- "$cur" ))
							return
							;;
						--c-compiler)
							local compilers=( $(get_c_compilers) )
							COMPREPLY=( $(compgen -W '${compilers[*]}' -- "$cur" ))
							return
							;; 
						--cxx-compiler)
							local compilers=( $(get_cxx_compilers) )
							COMPREPLY=( $(compgen -W '${compilers[*]}' -- "$cur" ))
							return
							;;
						--archiver)
							local archivers=( $(get_archivers) )
							COMPREPLY=( $(compgen -W '${archivers[*]}' -- "$cur" ))
							return
							;;
						--flag|--c-flag|--cxx-flag|--link-flag)
							return 
							;;
						--runner)
							local runners=($(get_runner_commands))
							COMPREPLY=( $(compgen -W '${runners[*]}' -- "$cur" ))
							return
							;; 
						--runner-args)
							return
							;;
						*)
							local opts=()
							for opt in "${all_opts[@]}"; do
								if [[ ! "${words[@]}" =~ "$opt" ]]; then								
									opts+=( "$opt" )
								fi
							done

							COMPREPLY=( $(compgen -W '${opts[*]}' -- "$cur" ))
							return
							;;
					esac
               ;;
            test)
					local all_opts=("--target" "--profile" "--no-prune" "--compiler" "--c-compiler" "--cxx-compiler" "--archiver" "--flag" "--c-flag" "--cxx-flag" \
										 "--link-flag" "--list" "--help" "--version" "--runner" "--runner-args" "--" )
               case $prev in
						run)
							local targets=($(build_dir_ analysis_test))
							COMPREPLY=( $(compgen -W '${targets[*]} ${all_opts[*]}' -- "$cur"))
							return
							;;
						--target)
							local targets=($(build_dir_analysis_test))
							COMPREPLY=( $(compgen -W '${targets[*]}' -- "$cur" ))
							return 
							;;
						--profile)
							COMPREPLY=( $(compgen -W '${profs[*]}' -- "$cur" ))
							return
							;;
						--compiler)
							local compilers=( $(get_fortran_compilers))
							COMPREPLY=( $(compgen -W '${compilers[*]}' -- "$cur" ))
							return
							;;
						--c-compiler)
							local compilers=( $(get_c_compilers) )
							COMPREPLY=( $(compgen -W '${compilers[*]}' -- "$cur" ))
							return
							;; 
						--cxx-compiler)
							local compilers=( $(get_cxx_compilers) )
							COMPREPLY=( $(compgen -W '${compilers[*]}' -- "$cur" ))
							return
							;;
						--archiver)
							local archivers=( $(get_archivers) )
							COMPREPLY=( $(compgen -W '${archivers[*]}' -- "$cur" ))
							return
							;;
						--flag|--c-flag|--cxx-flag|--link-flag)
							return 
							;;
						--runner)
							local runners=($(get_runner_commands))
							COMPREPLY=( $(compgen -W '${runners[*]}' -- "$cur" ))
							return
							;; 
						--runner-args)
							return
							;;
						*)
							local opts=()
							for opt in "${all_opts[@]}"; do
								if [[ ! "${words[@]}" =~ "$opt" ]]; then								
									opts+=( "$opt" )
								fi
							done

							COMPREPLY=( $(compgen -W '${opts[*]}' -- "$cur" ))
							return
							;;
					esac
					;;
         esac
         ;;
   esac
}


complete -F _fpm fpm