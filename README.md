# Overclock

Shooter sci-fi en 3D low-poly pour Android, en vue à la troisième personne. Tu affrontes des vagues de robots dans une arène. Fait avec [Godot](https://godotengine.org) 4.5.

## Tester sur ton téléphone

Chaque push sur `main` compile un APK et le publie dans la release **latest-debug** du dépôt public [overclock-builds](https://github.com/mariusortiz/overclock-builds). Aucune connexion n'est nécessaire :

https://github.com/mariusortiz/overclock-builds/releases/download/latest-debug/overclock-debug.apk

Ouvre ce lien sur le téléphone, puis installe l'APK. Il faut autoriser le navigateur à installer des applications inconnues. Les mises à jour s'installent par-dessus l'ancienne version, car elles sont toutes signées avec la même clé de debug.

Les APK des autres branches sont dans l'onglet **Actions**, en artefact de chaque build.

## Tester dans le navigateur (Mac, PC)

https://mariusortiz.github.io/overclock-builds/

Cette version web est mise à jour à chaque push sur `main`. Elle utilise un moteur de rendu plus simple que sur téléphone (WebGL 2) : le rendu et les FPS diffèrent un peu. Le téléphone reste la référence.

## Contrôles

| Action | Téléphone | Clavier / souris |
|---|---|---|
| Bouger | Joystick : poser le pouce n'importe où sur la moitié gauche | ZQSD (AZERTY) ou WASD (QWERTY), flèches |
| Caméra | Glisser sur la moitié droite | Souris (clic dans le jeu pour la capturer, Échap pour la libérer) |
| Tirer | Bouton TIR en bas à droite (on peut viser en gardant le doigt dessus) | Clic gauche |
| Sauter | Bouton SAUT au-dessus du bouton TIR | Espace |

## Développer en local (optionnel)

1. Installe Godot 4.5.1 (la version standard, pas .NET).
2. Ouvre `project.godot`, puis lance le jeu avec F5.

## Structure

- `scenes/` : scènes Godot (`.tscn`)
- `scripts/` : code GDScript
- `assets/` : textures et sons provisoires, générés par les scripts de `tools/`
- `tools/` : scripts Python qui génèrent l'arène de test, les textures et les sons
- `ci/debug.keystore` : clé de debug publique (mot de passe `android`), utilisée uniquement pour les APK de test. La clé de release ne sera jamais commitée.
- `.github/workflows/build.yml` : compilation de l'APK et de la version web

## Licence des assets

Voir `CREDITS.md` (à venir quand les premiers assets seront ajoutés).
