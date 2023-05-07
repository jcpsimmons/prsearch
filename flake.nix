{
  description = "A simple flake to search GH PRs by title and body";

  inputs = { flake-utils.url = "github:numtide/flake-utils"; };


  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system}; in
      {
        packages = rec {
          # import prsearch.sh from sources/ folder, set output as a pkgs.writeShellSriptBin of that file
          prsearch = pkgs.writeShellScriptBin "prsearch" ''
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

            FULL_QUERY="$AUTHOR is:pr sort:updated $TITLE_QUERY in:title"

            ${pkgs.gh}/bin/gh api -XGET search/issues -f q="$FULL_QUERY" --template \
              '{{printf "%v PRs found" .total_count}}

            {{range .items}}{{printf "%v" .updated_at | timeago}}{{printf " (%v)" .user.login | autocolor "magenta"}}{{(printf " %v - " .title | autocolor "green+b+h")}}{{(printf "%v\n" .html_url | autocolor "cyan+u")}}{{end}}
            '
          '';
          default = prsearch;
        };
        # apps = rec {
        #   hello = flake-utils.lib.mkApp { drv = self.packages.${system}.hello; };
        #   default = hello;
        # };
      }
    );
}
