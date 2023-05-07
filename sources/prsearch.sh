AUTHOR=""
TITLE_QUERY=""
REPO=""

while getopts ":a:q:r:" option; do
  case $option in
  a)
    AUTHOR="author:$OPTARG "
    ;;
  q)
    TITLE_QUERY="$OPTARG"
    ;;
  r)
    REPO="$OPTARG"
    ;;
  esac
done

FULL_QUERY="${AUTHOR}is:pr sort:updated ${TITLE_QUERY} in:title"

gh api -XGET search/issues -f q="$FULL_QUERY" --template \
  '{{printf "%v PRs found" .total_count}}

{{range .items}}{{printf "%v" .updated_at | timeago}}{{printf " (%v)" .user.login | autocolor "magenta"}}{{(printf " %v - " .title | autocolor "green+b+h")}}{{(printf "%v\n" .html_url | autocolor "cyan+u")}}{{end}}
'

