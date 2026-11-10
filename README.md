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
| Caméra | Glisser sur la moitié droite | Souris (clic dans le jeu pour la capturer) |
| Tirer | Bouton TIR en bas à droite (on peut viser en gardant le doigt dessus) | Clic gauche |
| Viser (zoom) | Bouton VISER : un appui l'active, un autre le désactive | Maintenir le clic droit |
| Corps à corps | Bouton COUP | F |
| Recharger | Bouton RECH. à gauche du bouton TIR (automatique quand le chargeur est vide) | R |
| Pause et réglages | Bouton II en haut à droite, ou bouton retour d'Android | Échap |
| Sauter | Bouton SAUT au-dessus du bouton TIR | Espace |

## Power-ups

Un robot détruit laisse parfois un cube lumineux au sol. Marche dessus pour le ramasser.

| Couleur | Effet |
|---|---|
| Vert | Régénération : +5 PV par seconde pendant 8 s |
| Orange | Puissance : dégâts doublés pendant 10 s |
| Jaune | Vitesse : déplacement +40 % pendant 10 s |
| Bleu | Bouclier : dégâts reçus divisés par deux pendant 10 s |

## Pouvoirs

À la fin de chaque vague, le jeu se met en pause et propose 3 pouvoirs au hasard. Celui que tu choisis dure jusqu'à la fin de la partie, et le reprendre augmente son niveau.

| Famille | Pouvoirs |
|---|---|
| Éléments | Feu (les robots touchés brûlent), Glace (ils sont ralentis), Foudre (le tir rebondit sur un voisin) |
| Arme | Cadence (+20 %), Chargeur (+50 %), Explosif (dégâts de zone) |
| Survie | Vitalité (+25 PV max), Vol de vie (+3 PV par robot détruit), Agilité (+10 % de vitesse) |

## Boss

Toutes les 5 vagues, un monstre arrive avec trois ennemis. Sa barre de vie s'affiche en haut de l'écran et la musique change. Le battre rapporte 1000 points et un power-up.

| Vague | Boss | Comportement |
|---|---|---|
| 5 | Dragon | Lent, crache 5 projectiles en éventail |
| 10 | Squelette géant | Fonce sur toi et frappe au contact |
| 15 | Chauve-souris géante | Reste loin et bombarde : un cercle rouge au sol annonce l'explosion |
| 20 | Slime royal | Fait apparaître des ennemis et s'entoure d'un bouclier par moments |

Après la vague 20, les quatre boss reviennent, plus résistants.

## Arènes

Les arènes font 60 m de côté. La partie commence dans la station, et chaque boss battu t'emmène dans la suivante. Chacune a ses ennemis :

| Arène | Ennemis |
|---|---|
| Station | Gardes |
| Désert | Assassins des sables |
| Jungle | Gobelins |
| Volcan | Zombies (et des flaques de lave qui blessent) |
| Ville | Hommes en costume |

Une mini-carte en haut à gauche montre les ennemis en rouge (les boss en plus gros) et les power-ups dans leur couleur.

## Personnages et armes

Ils se choisissent dans le menu et se débloquent avec le record.

| Arme | Cadence | Dégâts | Chargeur | Record requis |
|---|---|---|---|---|
| Blaster | 8/s | 1 | 24 | 0 |
| Fusil lourd | 2/s | 5 | 8 | 1500 |
| Sniper (zoom plus fort) | 1/s | 8 | 5 | 2500 |
| Mitraillette | 14/s | 1 | 40 | 4000 |
| Bazooka (roquette, explosion de 4 m) | 0,8/s | 10 | 1 | 6000 |

| Corps à corps | Délai | Dégâts | Portée | Record requis |
|---|---|---|---|---|
| Couteau (une cible) | 0,5 s | 4 | 2,2 m | 0 |
| Hache (tous les robots devant soi) | 1,1 s | 10 | 2,6 m | 3000 |

Personnages (visuel seulement) : Soldat (0), Cow-boy (1000), Pirate (2500), Viking (5000), Chevalier d'or (8000).

## Développer en local (optionnel)

1. Installe Godot 4.5.1 (la version standard, pas .NET).
2. Ouvre `project.godot`, puis lance le jeu avec F5.

## Structure

- `scenes/` : scènes Godot (`.tscn`)
- `scripts/` : code GDScript
- `assets/` : modèles 3D, sons et musique CC0 (voir `CREDITS.md`), plus les textures générées par les scripts de `tools/`
- `tools/` : scripts Python qui génèrent les arènes (`scenes/arenas/`), les textures et les sons
- `ci/debug.keystore` : clé de debug publique (mot de passe `android`), utilisée uniquement pour les APK de test. La clé de release ne sera jamais commitée.
- `.github/workflows/build.yml` : compilation de l'APK et de la version web

## Licence des assets

Tous les modèles, sons et musiques externes sont en CC0. Le détail est dans [CREDITS.md](CREDITS.md).
