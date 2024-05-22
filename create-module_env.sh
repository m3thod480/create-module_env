#!/bin/bash
printHelp(){
    echo "Creates a module file from a provided path which can be loaded for environment modules tasks"
    echo ""
    echo "Usage: $0 [-h|--help] -d "path" -f "file" [--default]"
    echo ""
    echo ""
    echo "	-d      --directory	Directory path where the software is located."
    echo "	-h      --help		Shows information about the script."
    echo "	-f      --file		Name of the file that will be created."
    echo "	-c      --color		Use a desired color(auto|none|always)."
    echo "		--default	Makes app version the default version."
    echo ""
    echo "Example:"
    echo "      ./script.sh -d /etc/movie/thing -f test"
}

echoerr() { echo "$*" >&2; }
echowar() { echo "$*" >&2; }
echoinf() { echo "$*"; }
echook() { echo "$*"; }
echodev() {
  if [[ "$DEBUG" == "1" ]]; then
    echo "DEBUG: $*"
  fi
}

[ $# -eq 0 ] && echoerr "ERROR: missing parameters. Try --help for more information" && exit 1

flag_default=0
p_color="auto"

for arg in "$@"; do
  if [[ $arg == "-h" || $arg == "--help" ]]; then
    printHelp
    exit 0
  fi
done

while [[ $# -gt 0 ]]; do
  case $1 in
    -d|--directory)
      dir="$2"
      shift
      shift
      ;;
    -f|--file)
      file="$2"
      shift
      shift
      ;;
    -c|--color)
      p_color="$2"
      shift
      shift
      ;;
    --default)
      flag_default=1
      shift
      ;;
    -*)
      echoerr "ERROR: Unknown option $1, use --help"
      exit 1
      ;;
    *)
      echoerr "ERROR: missing parameters"
      echo "Try --help for more information."
      exit 1
      ;;
  esac
done

      case $dir in
	-*|"")
          echoerr "ERROR: missing --directory parameter"
          exit 1
          ;;
      esac

      case $file in
        -*|"")
          echoerr "ERROR: missing --file parameter"
          exit 1
          ;;
      esac

      case $p_color in
        -*|"")
          echoerr "ERROR: missing --color parameter"
          exit 1
          ;;
      esac


p_color=$(echo "$p_color" | awk '{print tolower($0)}')
case $p_color in
  always|none)  #Full Override
    ;;
  auto)
    case "$TERM" in
      xterm*)
        p_color="always"
        ;;

      *)
        p_color="none"
        ;;
    esac
    if [ "$TERM" == "xterm-256color" ]; then
      p_color="always"
    else
      p_color="none"
    fi
    ;;
  *)
    echoerr "ERROR: parameter --color with value '$p_color' si not possible."
    exit 1
    ;;
esac

if [ "$p_color" == "always" ]; then
  RED='\033[0;31m'
  BLUE='\033[0;36m'
  YELL='\033[0;33m'
  PURP='\033[0;35m'
  GREE='\033[0;32m'
  NC='\033[0m' # No Color

  #echoerr() { cat <<< "$@" 1>&2; }
  echoerr() { printf "${RED}%s${NC}\n" "$*" >&2; }
  #echoerr() { echo "$*" >&2; }
  echowar() { printf "${YELL}%s${NC}\n" "$*" >&2; }
  echoinf() { printf "${BLUE}%s${NC}\n" "$*"; }
  echook() { printf "${GREE}%s${NC}\n" "$*"; }
  #echook() { echo "$*"; }
  echodev() {
    if [[ "$DEBUG" == "1" ]]; then
      printf "${PURP}DEBUG: %s${NC}\n" "$*"
    fi
  }
fi

[ ! -d $dir ] && echoerr "ERROR: path provided does not exists" && exit 1
[ -z $dir ] && echoerr "ERROR: path is empty" && exit 1

realdir=$(realpath "$dir")
rutaabsoluta=$(realpath $0)
ruta=$(dirname $rutaabsoluta) 


[[ "$file" == */ ]] || [ -d "$ruta/$file" ] && echoerr "ERROR: File parameter must be a file" && exit 1
[ -e "$ruta/$file" ] && echoerr "ERROR: File already exists" && exit 1

# Verificar y crear directorio del archivo si no existe

get_file_dir=$(dirname "$file")

if [ ! -d "$ruta/$get_file_dir" ]; then
    mkdir -p "$ruta/$get_file_dir"
fi

cat <<EOF > $ruta/$file
#%Module1.0#####################################################################
##
## $(basename "$dir") modulefile
##
proc ModulesHelp { } {
        puts stderr "\tAdds $(basename "$dir") to your PATH environment variable\n"
}

module-whatis   "Adds $(basename "$dir") to your PATH."

# Software common path
set componentroot "$realdir"
EOF


# Variables para almacenar las líneas
bin=""
l1b=""
l1b64=""
lbr64=""
lbr=""
include=""
man=""
pkg=""

# Comprobar si existen los directorios y construir las líneas correspondientes
if [ -d "$realdir/lib" ]; then
    l1b+="\n# For executions\n"
    l1b+="prepend-path LD_LIBRARY_PATH \"\$componentroot/lib\"\n"
fi

if [ -d "$realdir/bin" ]; then
        bin+="prepend-path PATH \"\$componentroot/bin\"\n"
fi

if [ -d "$realdir/lib64" ]; then
    l1b64+="prepend-path LD_LIBRARY_PATH \"\$componentroot/lib64\"\n"
fi

if [ -d "$realdir/include" ]; then
    include+="\n# For compilations\n"
    include+="prepend-path INCLUDE \"\$componentroot/include\"\n"
    include+="prepend-path CPATH \"\$componentroot/include\"\n"
fi

if [ -d "$realdir/lib" ]; then
    lbr+="prepend-path LIBRARY_PATH \"\$componentroot/lib\"\n"

fi

if [ -d "$realdir/lib64" ]; then
    lbr64+="prepend-path LIBRARY_PATH \"\$componentroot/lib64\"\n"
fi

if [ -d "$realdir/share/man" ]; then
    man+="\n# Manuals Path\n"
    man+="prepend-path MANPATH \"\$componentroot/share/man\"\n"
fi

if [ -d "$realdir/lib64/pkgconfig" ]; then
    pkg+="\n# PKG Info path\n"
    pkg+='prepend-path PKG_CONFIG_PATH "$componentroot/lib64/pkgconfig"\n'
fi
# Agregar todas las líneas al final del archivo
echo -e "$l1b$bin$l1b64$include$lbr$lbr64$man$pkg" >> $ruta/$file

echo -e "\nModule has been created successfully"


aux_dir_file=$(realpath "$ruta/$file")
dir_file=$(dirname $aux_dir_file)


if [ $flag_default -eq 1 ]; then

	if [ "$ruta" != "$dir_file" ]; then
	
		cat <<EOF > $(dirname "$ruta/$file")/.version
#%Module
set ModulesVersion "$(basename "$file")"	
EOF
	
		echo "$(basename "$file") module has been also established as the default version"

	else

		echowar "WARNING: Version can't be established as default on this path"
	
	fi


fi

echo -e "\nOK!"

exit 0

