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
| Recharger | Bouton RECH. à gauche du bouton TIR (automatique quand le chargeur est vide) | R |
| Sauter | Bouton SAUT au-dessus du bouton TIR | Espace |

## Power-ups

Un robot détruit laisse parfois un cube lumineux au sol. Marche dessus pour le ramasser.

| Couleur | Effet |
|---|---|
| Vert | Régénération : +5 PV par seconde pendant 8 s |
| Orange | Puissance : dégâts doublés pendant 10 s |
| Jaune | Vitesse : déplacement +40 % pendant 10 s |
| Bleu | Bouclier : dégâts reçus divisés par deux pendant 10 s |

## Développer en local (optionnel)

1. Installe Godot 4.5.1 (la version standard, pas .NET).
2. Ouvre `project.godot`, puis lance le jeu avec F5.

## Structure

- `scenes/` : scènes Godot (`.tscn`)
- `scripts/` : code GDScript
- `assets/` : modèles 3D, sons et musique CC0 (voir `CREDITS.md`), plus les textures générées par les scripts de `tools/`
- `tools/` : scripts Python qui génèrent l'arène de test, les textures et les sons
- `ci/debug.keystore` : clé de debug publique (mot de passe `android`), utilisée uniquement pour les APK de test. La clé de release ne sera jamais commitée.
- `.github/workflows/build.yml` : compilation de l'APK et de la version web

## Licence des assets

Tous les modèles, sons et musiques externes sont en CC0. Le détail est dans [CREDITS.md](CREDITS.md).
