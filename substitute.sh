#!/bin/bash
set -e

pattern={{property}}

sourceFile=${PWD}/"$1"
appProperties=${PWD}/"$2"

cp ${sourceFile} substitution.src.tmp

while IFS="=" read -r key value; do
    case "$key" in
      '#'*) ;;
      '') ;;
      *)
		whatToReplace=${pattern/property/${key}}
		sed -e "s^${whatToReplace}^${value}^g" -e "s^${key}=.*^${key}=${value}^" 'substitution.src.tmp' > 'substitution.dst.tmp'
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

exit 0
