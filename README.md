# Auradio

Annuaire statique de webradios, hébergé sur GitHub Pages.

## Structure

- `list.json` — la source de vérité : un tableau JSON de radios, chacune avec :
  - `id` — identifiant unique (slug), utilisé comme nom de fichier dans `play/`
  - `name` — nom affiché
  - `description` — courte description
  - `icon` — chemin optionnel vers une icône dans `img/`
  - `url` — url du flux audio, **au format mp3**
- `img/` — icônes des radios (SVG)
- `play/` — un fichier par radio, généré automatiquement à partir de `list.json`.
  Chaque fichier s'appelle `play/<id>` (sans extension) et contient un tableau
  JSON à un élément : `["<url du flux>"]`
- `index.html` — page d'accueil qui liste les radios et permet de les écouter directement
- `Makefile` — génère `play/` à partir de `list.json`

`play/` est généré (par `make` en local, ou automatiquement par la CI au moment
du déploiement) — il n'est donc pas versionné dans le dépôt.

## Ajouter une radio

1. Ajouter une entrée dans `list.json` (avec un `id` unique et un flux en mp3)
2. Ajouter une icône dans `img/` si besoin
3. Lancer `make` pour régénérer `play/`

## Générer les fichiers `play/`

```sh
make        # génère play/<id> pour chaque radio de list.json
make clean  # supprime le dossier play/
```

Nécessite [`jq`](https://jqlang.org/).

## Déploiement

Le workflow `.github/workflows/deploy.yml` régénère `play/` via `make` puis
publie l'ensemble du dossier sur GitHub Pages à chaque push sur `main`.

Pour l'activer : dans les paramètres du dépôt GitHub, section **Pages**,
choisir la source **GitHub Actions**.

## Prévisualiser en local

```sh
make
python3 -m http.server 8000
# puis ouvrir http://localhost:8000
```

(`fetch('list.json')` nécessite un serveur HTTP — ouvrir `index.html`
directement via `file://` ne fonctionnera pas à cause des restrictions CORS
du navigateur.)
