
#!/usr/bin/env bash
set -e

usage() {
  cat <<EOF
Usage: $0 [ -g | --gen-example ] [ -c | --clean ] <file>.json

Options:
  -g, --gen-example   Génère un fichier JSON exemple
  -c, --clean         Supprime l'interface nommée d'après le fichier JSON
EOF
}

GEN_EXAMPLE=0
CLEAN=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    -g|--gen-example) GEN_EXAMPLE=1; shift ;;
    -c|--clean) CLEAN=1; shift ;;
    -*)
      echo "Option inconnue : $1"
      usage
      exit 1 ;;
    *)
      FILE="$1"; shift ;;
  esac
done

if (( GEN_EXAMPLE )); then
  cat > subxx.json <<EOF
[
  "240.0.0.1/32",
  "172.16.95.0/24"
]
EOF
  echo "✅ Fichier exemple créé : example_interface.json"
  exit 0
fi

if [[ -z "$FILE" || "${FILE##*.}" != "json" || ! -f "$FILE" ]]; then
  echo "❌ Spécifiez un fichier .json valide"
  usage
  exit 1
fi

IFNAME="${FILE##*/}"
IFNAME="${IFNAME%.*}"
USER="kali"

(( EUID == 0 )) || { echo "⚠️ Ce script doit être exécuté en root."; exit 2; }

if (( CLEAN )); then
  echo "🧹 Suppression de l'interface : $IFNAME"
  ip link set dev "$IFNAME" down || true
  ip link delete dev "$IFNAME" || true
  echo "✅ Interface $IFNAME supprimée."
  exit 0
fi

ROUTES=()
while IFS= read -r line; do
  [[ $line =~ \"([0-9./]+)\" ]] && ROUTES+=("${BASH_REMATCH[1]}")
done < "$FILE"

if ip link show "$IFNAME" &>/dev/null; then
  echo "ℹ️ L'interface '$IFNAME' existe déjà. Ajout des routes uniquement."
else
  echo "🔧 Création de l'interface : $IFNAME (user: $USER)"
  ip tuntap add dev "$IFNAME" mode tun user "$USER"
  ip link set dev "$IFNAME" up
  echo "🟢 Interface $IFNAME activée"
fi

echo "🔀 Ajout des routes :"
for r in "${ROUTES[@]}"; do
  ip route add "$r" dev "$IFNAME" 2>/dev/null \
    && echo "- $r via $IFNAME" \
    || echo "⚠️ Route '$r' existe ou erreur"
done

echo "✅ Fin du traitement pour '$IFNAME'."

╭─      ~/Documents ───────────────────────────────────────────────────────── ✔  NORMAL  at 22:02:36   ─╮
╰─ cat /usr/local/bin/ligolo-interface                                                                           ─╯
#!/usr/bin/env bash
set -e

usage() {
  cat <<EOF
Usage: $0 [ -g | --gen-example ] [ -c | --clean ] <file>.json

Options:
  -g, --gen-example   Génère un fichier JSON exemple
  -c, --clean         Supprime l'interface nommée d'après le fichier JSON
EOF
}

GEN_EXAMPLE=0
CLEAN=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    -g|--gen-example) GEN_EXAMPLE=1; shift ;;
    -c|--clean) CLEAN=1; shift ;;
    -*)
      echo "Option inconnue : $1"
      usage
      exit 1 ;;
    *)
      FILE="$1"; shift ;;
  esac
done

if (( GEN_EXAMPLE )); then
  cat > subxx.json <<EOF
[
  "240.0.0.1/32",
  "172.16.95.0/24"
]
EOF
  echo "✅ Fichier exemple créé : example_interface.json"
  exit 0
fi

if [[ -z "$FILE" || "${FILE##*.}" != "json" || ! -f "$FILE" ]]; then
  echo "❌ Spécifiez un fichier .json valide"
  usage
  exit 1
fi

IFNAME="${FILE##*/}"
IFNAME="${IFNAME%.*}"
USER="kali"

(( EUID == 0 )) || { echo "⚠️ Ce script doit être exécuté en root."; exit 2; }

if (( CLEAN )); then
  echo "🧹 Suppression de l'interface : $IFNAME"
  ip link set dev "$IFNAME" down || true
  ip link delete dev "$IFNAME" || true
  echo "✅ Interface $IFNAME supprimée."
  exit 0
fi

ROUTES=()
while IFS= read -r line; do
  [[ $line =~ \"([0-9./]+)\" ]] && ROUTES+=("${BASH_REMATCH[1]}")
done < "$FILE"

if ip link show "$IFNAME" &>/dev/null; then
  echo "ℹ️ L'interface '$IFNAME' existe déjà. Ajout des routes uniquement."
else
  echo "🔧 Création de l'interface : $IFNAME (user: $USER)"
  ip tuntap add dev "$IFNAME" mode tun user "$USER"
  ip link set dev "$IFNAME" up
  echo "🟢 Interface $IFNAME activée"
fi

echo "🔀 Ajout des routes :"
for r in "${ROUTES[@]}"; do
  ip route add "$r" dev "$IFNAME" 2>/dev/null \
    && echo "- $r via $IFNAME" \
    || echo "⚠️ Route '$r' existe ou erreur"
done

echo "✅ Fin du traitement pour '$IFNAME'."

