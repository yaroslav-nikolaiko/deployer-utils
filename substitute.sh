#!/bin/bash
pattern={{property}}

sourceFile=${PWD}/"$1"
appProperties=${PWD}/"$2"

cp ${sourceFile} substitution.src.tmp

while IFS="=" read -r key value; do
    case "$key" in
      '#'*) ;;
      '') ;;
      *)
        eval "$key=\"$value\""	
		whatToReplace=${pattern/property/${key}}
		sed "s^${whatToReplace}^${value}^g" 'substitution.src.tmp' > 'substitution.dst.tmp'
		mv substitution.dst.tmp substitution.src.tmp
    esac
done < "$appProperties"



[ -f 'substitution.src.tmp' ] &&{
	cat 'substitution.src.tmp'
	rm 'substitution.src.tmp'
}

[ -f 'substitution.dst.tmp' ] &&{
	rm 'substitution.dst.tmp'
}
