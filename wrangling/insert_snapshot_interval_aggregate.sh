#!/usr/bin/env bash

declare -A IMPL_NAMES
IMPL_NAMES["fdr"]="FDR"
IMPL_NAMES["fdr+fro"]="FDR"
IMPL_NAMES["fdr+kro"]="FDR"
IMPL_NAMES["fdr+co"]="FDR"
IMPL_NAMES["kuafu"]="KuaFu"
IMPL_NAMES["kuafu+kro"]="KuaFu"
IMPL_NAMES["kuafu+co"]="KuaFu"

declare -A ROIMPL_NAMES
ROIMPL_NAMES["none"]=""
ROIMPL_NAMES["fro"]="+fRO"
ROIMPL_NAMES["kro"]="+kRO"
ROIMPL_NAMES["co"]="+CO"
ROIMPL_NAMES["kro"]="+kRO"

logsdir=""
outfile=""

print_usage() {
    echo "Usage: $0 -i logsdir -o outfile"
    exit 1
}

while getopts 'i:o:' flag; do
    case "${flag}" in
	      i) logsdir="${OPTARG}" ;;
	      o) outfile="${OPTARG}" ;;
	      *) print_usage ;;
    esac
done

if [[ -z $logsdir || -z $outfile ]]; then
    print_usage
fi

logsdir=$(realpath $logsdir)
outfile=$(realpath $outfile)

echo "impl,n_clients,n_workers,snap_interval,server,total_time_ms,n_commits,commit_rate_tps,relative_commit_rate" > $outfile

for dir in $(find $logsdir -maxdepth 1 -mindepth 1 -type d -printf '%f\n'); do
    impl=$(echo "$dir" | sed -e 's/\([^_]\+\)_.*/\1/g')
    roimpl=$(echo "$dir" | sed -e 's/[^_]\+_\([^_]\+\)_.*/\1/g')
    nclients=$(echo "$dir" | sed -e 's/\([^_]\+_\)\+\([0-9]\+\)c_.*/\2/g')
    nworkers=$(echo "$dir" | sed -e 's/\([^_]\+_\)\+\([0-9]\+\)w_.*/\2/g')
    snapinterval=$(echo "$dir" | sed -e 's/\([^_]\+_\)\+\([0-9]\+\)s_.*/\2/g')

    if [[ -v "IMPL_NAMES[$impl]" ]]; then
	      impl=${IMPL_NAMES[$impl]}
    fi

    if [[ -v "ROIMPL_NAMES[$roimpl]" ]]; then
	      roimpl=${ROIMPL_NAMES[$roimpl]}
    fi

    primary_csv=$(cat $logsdir/$dir/commit_rate.primary.csv)
    backup_csv=$(cat $logsdir/$dir/commit_rate.backup.csv)

    primary_cr=$(echo "$primary_csv" | awk -F',' '/primary/{ gsub("\r", "", $4); print $4 }')
    backup_cr=$(echo "$backup_csv" | awk -F',' '/backup/{ gsub("\r", "", $4); print $4 }')

    primary_rcr=$(echo "$primary_cr / $primary_cr" | bc -l)
    backup_rcr=$(echo "$backup_cr / $primary_cr" | bc -l)

    echo "$primary_csv" | \
	      sed -e '/server/d' \
	          -e 's/\r//' \
	          -e "s/^primary/${impl}${roimpl},$nclients,$nworkers,$snapinterval,Primary/" \
	          -e "s/$/,${primary_rcr}/" \
	          >> $outfile

    echo "$backup_csv" | \
	      sed -e '/server/d' \
	          -e 's/\r//' \
	          -e "s/^backup/${impl}${roimpl},$nclients,$nworkers,$snapinterval,$impl${roimpl}/" \
	          -e "s/$/,${backup_rcr}/" \
	          >> $outfile
done
