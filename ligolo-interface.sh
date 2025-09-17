#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: $0 [ -g | --gen-example ] [ -c | --clean ] [ --user <name> ] <file>.json

Options:
  -g, --gen-example   Génère un fichier JSON exemple
  -c, --clean         Supprime l'interface nommée d'après le fichier JSON
      --user <name>   Définit l'utilisateur propriétaire de l'interface (défaut: kali)
USAGE
}

ensure_jq() {
  if command -v jq >/dev/null 2>&1; then
    return
  fi

  echo "ℹ️ L'outil 'jq' est requis mais n'est pas installé."

  if ! command -v apt-get >/dev/null 2>&1; then
    echo "❌ Impossible d'installer automatiquement 'jq' : 'apt-get' introuvable."
    exit 1
  fi

  if (( EUID != 0 )); then
    echo "❌ Exécutez ce script en tant que root pour installer automatiquement 'jq'."
    exit 1
  fi

  echo "🔄 Installation de 'jq' via apt-get..."
  apt-get update
  apt-get install -y jq

  if ! command -v jq >/dev/null 2>&1; then
    echo "❌ L'installation de 'jq' a échoué."
    exit 1
  fi
}

GEN_EXAMPLE=0
CLEAN=0
INTERFACE_USER="kali"
FILE=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    -g|--gen-example)
      GEN_EXAMPLE=1
      shift
      ;;
    -c|--clean)
      CLEAN=1
      shift
      ;;
    --user)
      [[ $# -ge 2 ]] || { echo "❌ L'option --user requiert un argument."; usage; exit 1; }
      INTERFACE_USER="$2"
      shift 2
      ;;
    -*)
      echo "❌ Option inconnue : $1"
      usage
      exit 1
      ;;
    *)
      FILE="$1"
      shift
      ;;
  esac
done

if (( GEN_EXAMPLE )); then
  example_file="example_interface.json"
  cat >"$example_file" <<'JSON'
[
  "240.0.0.1/32",
  "172.16.95.0/24"
]
JSON
  echo "✅ Fichier exemple créé : $example_file"
  exit 0
fi

if [[ -z "$FILE" || "${FILE##*.}" != "json" || ! -f "$FILE" ]]; then
  echo "❌ Spécifiez un fichier .json valide"
  usage
  exit 1
fi

ensure_jq

IFNAME="${FILE##*/}"
IFNAME="${IFNAME%.*}"

if [[ -z "$IFNAME" ]]; then
  echo "❌ Impossible de déduire le nom d'interface depuis '$FILE'"
  exit 1
fi

(( EUID == 0 )) || { echo "⚠️ Ce script doit être exécuté en root."; exit 2; }

if (( CLEAN )); then
  echo "🧹 Suppression de l'interface : $IFNAME"
  ip link set dev "$IFNAME" down || true
  ip link delete dev "$IFNAME" || true
  echo "✅ Interface $IFNAME supprimée."
  exit 0
fi

mapfile -t ROUTES < <(jq -r '.[]' "$FILE")

if (( ${#ROUTES[@]} == 0 )); then
  echo "⚠️ Aucune route n'a été trouvée dans '$FILE'."
fi

if ip link show "$IFNAME" &>/dev/null; then
  echo "ℹ️ L'interface '$IFNAME' existe déjà. Ajout des routes uniquement."
else
  echo "🔧 Création de l'interface : $IFNAME (user: $INTERFACE_USER)"
  ip tuntap add dev "$IFNAME" mode tun user "$INTERFACE_USER"
  ip link set dev "$IFNAME" up
  echo "🟢 Interface $IFNAME activée"
fi

echo "🔀 Ajout des routes :"
for r in "${ROUTES[@]}"; do
  [[ -n "$r" ]] || continue
  if ip route show "$r" 2>/dev/null | grep -q "dev $IFNAME"; then
    echo "⚠️ Route '$r' déjà associée à $IFNAME"
    continue
  fi
  if ip route add "$r" dev "$IFNAME" 2>/dev/null; then
    echo "- $r via $IFNAME"
  else
    echo "⚠️ Échec lors de l'ajout de la route '$r'"
  fi
done

echo "✅ Fin du traitement pour '$IFNAME'."
