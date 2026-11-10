# Overclock

Shooter sci-fi en 3D low-poly pour Android, en vue à la troisième personne. Tu affrontes des vagues de robots dans une arène. Fait avec [Godot](https://godotengine.org) 4.5.

## Tester le jeu

https://mariusortiz.github.io/overclock-builds/

Cette version web est mise à jour à chaque push sur `main`. Elle s'ouvre aussi dans le navigateur d'un téléphone.

La compilation de l'APK Android est désactivée pour l'instant. Le preset d'export Android (`export_presets.cfg`) et la clé de debug (`ci/debug.keystore`) restent en place pour la réactiver plus tard.

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

## Caisses d'armes

À chaque vague, une caisse tombe du ciel sous un parachute, à quelques mètres de toi. Un faisceau orange la signale une fois posée, et elle apparaît en orange sur la mini-carte. Marche dessus : tu reçois une arme au hasard pour trois chargeurs, puis ton arme revient. Une caisse disparaît au bout de 40 s.

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

| 25 | Titan (boss final, dans la ville) | Robot géant en trois phases : tirs en éventail, bombardement, invocations, puis une onde de choc au sol à esquiver en sautant ou depuis une passerelle |

Battre le Titan termine la partie : un trophée apparaît, tu gagnes le skin Champion et tu reviens au menu.

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

## Passe de combat

Chaque partie rapporte de l'XP (un dixième du score). Le passe compte 30 paliers, permanents et gratuits. Chaque palier débloque un personnage, une arme, une arme de corps à corps ou un skin d'arme. Le Soldat, le Blaster, le Couteau et le skin Standard sont disponibles dès le départ. L'ordre des récompenses est dans `scripts/battle_pass.gd`.

## Arsenal

L'arsenal, accessible depuis l'accueil, a quatre onglets : personnage, arme, corps à corps et skin. Un élément verrouillé peut être prévisualisé, mais pas équipé. Dans les onglets d'armes et de skins, l'arme est montrée seule : elle flotte et tourne sur elle-même.

| Arme | Cadence | Dégâts | Chargeur |
|---|---|---|---|
| Pistolet | 4/s | 2 | 12 |
| Fusil d'assaut | 10/s | 1 | 30 |
| Fusil de précision (zoom plus fort) | 1/s | 8 | 5 |
| Pistolet-mitrailleur | 14/s | 1 | 40 |
| Lance-roquettes (explosion de 4 m) | 0,8/s | 10 | 1 |

Un tir dans la tête fait le double de dégâts : le marqueur de touche devient jaune.

| Corps à corps | Délai | Dégâts | Portée |
|---|---|---|---|
| Couteau (une cible) | 0,5 s | 4 | 2,2 m |
| Lance (transperce les ennemis alignés) | 0,8 s | 6 | 4,5 m |
| Hache (tous les ennemis devant soi) | 1,1 s | 10 | 2,6 m |
| Masse (repousse l'ennemi) | 1 s | 8 | 2,4 m |

Les skins d'armes sont des finitions : ils gardent la forme de l'arme et la repeignent d'un motif (néon, camouflage, fibre de carbone, lave…), certains la font briller ou lui ajoutent une lunette ou un silencieux, et chacun change la couleur du tir. Les statistiques ne changent pas. Le skin décide aussi de la façon dont meurent les ennemis abattus : ils fondent en flaque (Toxique, Océan), gèlent puis éclatent (Glace, Or), se consument (Lave, Solaire), se dissipent en rayon de lumière (Néon, Royal) ou explosent en morceaux (Sakura, Champion). Le skin Champion ne s'obtient qu'en battant le boss final. Il y a 13 personnages, purement visuels.

## Développer en local (optionnel)

1. Installe Godot 4.5.1 (la version standard, pas .NET).
2. Ouvre `project.godot`, puis lance le jeu avec F5.

## Structure

- `scenes/` : scènes Godot (`.tscn`)
- `scripts/` : code GDScript
- `assets/` : modèles 3D, sons et musique CC0 (voir `CREDITS.md`), plus les textures générées par les scripts de `tools/`
- `tools/` : scripts Python qui génèrent les arènes (`scenes/arenas/`), les textures et les sons
- `ci/debug.keystore` : clé de debug publique (mot de passe `android`), utilisée uniquement pour les APK de test. La clé de release ne sera jamais commitée.
- `.github/workflows/build.yml` : contrôles automatiques et compilation de la version web

## Licence des assets

Tous les modèles, sons et musiques externes sont en CC0. Le détail est dans [CREDITS.md](CREDITS.md).
