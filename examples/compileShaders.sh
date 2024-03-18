
platform=$1
profile=$2

src=../../shaders
dest=../shaders

compSh(){
	if [ $1 == v ]; then
		typeExt=vert
	elif [ $1 == f ]; then
		typeExt=frag
	else
		echo "Bad shader type in $2: $1" 1>&2
		exit 1
	fi
	
	shaderc --type $1 --platform $platform --profile $profile -f $src/$2.$typeExt -o $dest/$2.$typeExt.bin $3
	retVal=$?
	if [ $retVal -ne 0 ]; then
		echo "Error in: "$src"/"$2"."$typeExt
		exit $retVal
	fi
}

compSh v passPos
compSh v passPosCol
compSh v passPosColTex
compSh f passCol
compSh f uniformCol
