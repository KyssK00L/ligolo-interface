# ligolo-interface

Script utilitaire pour créer une interface TUN dédiée à partir d'un fichier
JSON décrivant les routes à annoncer à Ligolo. Il permet également de générer
un exemple de configuration et de supprimer une interface existante.

## Prérequis

- bash
- [jq](https://jqlang.github.io/jq/) pour lire les fichiers JSON
- Droits root pour manipuler les interfaces réseau

## Utilisation

```bash
sudo ./ligolo-interface.sh [options] <fichier>.json
```

Options disponibles :

- `-g`, `--gen-example` : génère un fichier `example_interface.json` prêt à
  l'emploi.
- `-c`, `--clean` : supprime l'interface dérivée du nom de fichier JSON.
- `--user <nom>` : définit le propriétaire UNIX de l'interface TUN (défaut
  `kali`).

Le nom de l'interface créée correspond au nom du fichier JSON sans extension.
Chaque élément du tableau JSON doit être une route au format CIDR.

## Exemple

```bash
# Génération d'un exemple
./ligolo-interface.sh --gen-example

# Création d'une interface à partir d'un fichier
sudo ./ligolo-interface.sh routes.json

# Suppression de l'interface créée
sudo ./ligolo-interface.sh --clean routes.json
```
