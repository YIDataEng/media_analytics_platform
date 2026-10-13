#!/usr/bin/env bash
# Refuse un commit ou un push dont l'auteur n'est pas l'identité prévue pour ce dépôt.
# Appelé par pre-commit (voir .pre-commit-config.yaml) :
#   verifier_identite.sh commit   avant chaque commit
#   verifier_identite.sh push     avant chaque push
set -euo pipefail

NOM_ATTENDU="YIDataEng"
EMAIL_ATTENDU="342095592+YIDataEng@users.noreply.github.com"

mode="${1:-commit}"
erreurs=0

# Compare une identité "Nom <email>" à l'identité attendue.
verifier() {
    local origine="$1" nom="$2" email="$3"
    if [[ "$nom" != "$NOM_ATTENDU" || "$email" != "$EMAIL_ATTENDU" ]]; then
        echo "  $origine : $nom <$email>"
        erreurs=$((erreurs + 1))
    fi
}

case "$mode" in
    commit)
        # Identité que git s'apprête à écrire dans le commit.
        for role in AUTHOR COMMITTER; do
            ident="$(git var "GIT_${role}_IDENT")"
            nom="${ident%% <*}"
            email="${ident#*<}"
            email="${email%%>*}"
            verifier "réglage actuel ($role)" "$nom" "$email"
        done
        ;;
    push)
        # Commits sur le point de partir : ceux qui ne sont pas encore sur le dépôt distant.
        ref="${PRE_COMMIT_TO_REF:-HEAD}"
        if git rev-parse --verify --quiet "$ref" >/dev/null; then
            while IFS='|' read -r sha an ae cn ce; do
                [[ -z "$sha" ]] && continue
                verifier "commit $sha (auteur)" "$an" "$ae"
                verifier "commit $sha (committer)" "$cn" "$ce"
            done < <(git log --format='%h|%an|%ae|%cn|%ce' "$ref" --not --remotes)
        fi
        ;;
    *)
        echo "Usage : $0 commit|push" >&2
        exit 2
        ;;
esac

if (( erreurs > 0 )); then
    echo
    echo "Identité attendue : $NOM_ATTENDU <$EMAIL_ATTENDU>"
    echo "Pour corriger le réglage de ce dépôt :"
    echo "  git config user.name \"$NOM_ATTENDU\""
    echo "  git config user.email \"$EMAIL_ATTENDU\""
    if [[ "$mode" == "push" ]]; then
        echo "Puis réécrire l'auteur du dernier commit :"
        echo "  git commit --amend --reset-author --no-edit"
    fi
    exit 1
fi
