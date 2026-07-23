# Auradio

Annuaire statique de webradios, servi localement ou depuis une Raspberry Pi.

> ⚠️ **Ce projet est 100% vibecodé** : généré par un agent IA, non relu ni
> vérifié par un humain. Vérifiez le code et les flux avant tout usage sérieux.

## Structure

- `list.json` — la source de vérité : un tableau JSON de radios, chacune avec :
  - `id` — identifiant unique (slug), utilisé comme nom de fichier dans `play/`
  - `name` — nom affiché
  - `description` — courte description
  - `icon` — chemin optionnel vers une icône dans `img/`
  - `theme` — catégorie pour le filtrage (`generaliste`, `info`, `culture`, `classique`,
    `eclectique`, `musique`, `urbain`, `humour`, `monde`, `enfants`, `detente`, `cinema`)
  - `url` — url du flux audio, **en http (pas de https) et au format mp3**
- `img/` — icônes des radios (SVG)
- `play/` — un fichier par radio, généré automatiquement à partir de `list.json`.
  Chaque fichier s'appelle `play/<id>` (sans extension) et contient un tableau
  JSON à un élément : `["<url du flux>"]`
- `index.html` — page d'accueil qui liste les radios et permet de les écouter directement
- `Makefile` — génère `play/` à partir de `list.json`

`play/` est généré par `make` au moment du déploiement ou en local — il n'est
donc pas versionné dans le dépôt.

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

## Serveur local

```sh
make serve            # sert le site sur le port 8000, accessible depuis le réseau local
make serve PORT=8080  # port custom
```

## Démarrage automatique sur Raspberry Pi

Le dépôt contient une unité `systemd` d'exemple : `auradio.service`.

Hypothèses :

- le projet est déployé dans `/home/pi/auradio`
- le service tourne avec l'utilisateur `pi`
- `python3`, `make` et `jq` sont installés sur la machine

Adaptez si besoin les champs `User`, `Group` et `WorkingDirectory` du fichier
`auradio.service`, puis installez-le :

```sh
make install-systemd
```

Par défaut, cette cible copie `auradio.service` vers `/etc/systemd/system/`
et active immédiatement le service. Vous pouvez surcharger les variables si
besoin :

```sh
make install-systemd SERVICE_NAME=auradio.service
make install-systemd SYSTEMD_DIR=/lib/systemd/system
```

Pour retirer le service proprement :

```sh
make uninstall-systemd
```

Cette cible arrête et désactive le service, supprime le fichier d'unité puis
relance `systemctl daemon-reload`.

Vérification :

```sh
systemctl status auradio.service
journalctl -u auradio.service -f
```

Le service régénère `play/` au démarrage via `make all`, puis expose le site
sur le port `8000` avec `python3 -m http.server`.

(`fetch('list.json')` nécessite un serveur HTTP — ouvrir `index.html`
directement via `file://` ne fonctionnera pas à cause des restrictions CORS
du navigateur.)
