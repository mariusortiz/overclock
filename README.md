# Overclock

Shooter sci-fi en 3D low-poly pour Android, en vue à la troisième personne. Tu affrontes des vagues de robots dans une arène. Fait avec [Godot](https://godotengine.org) 4.5.

## Tester le jeu

https://mariusortiz.github.io/overclock-builds/

Cette version web est mise à jour à chaque push sur `main`. Elle s'ouvre aussi dans le navigateur d'un téléphone.

Sur téléphone, elle s'installe comme une application : menu du navigateur, « Ajouter à l'écran d'accueil » (Chrome sur Android) ou Partager puis « Sur l'écran d'accueil » (Safari sur iPhone). Elle s'ouvre alors en plein écran, à l'horizontale, avec l'icône du jeu. Après une mise à jour, la nouvelle version peut demander d'ouvrir le jeu deux fois : la première ouverture la télécharge, la seconde l'affiche.

La compilation de l'APK Android est désactivée pour l'instant. Le preset d'export Android (`export_presets.cfg`) et la clé de debug (`ci/debug.keystore`) restent en place pour la réactiver plus tard.

## Contrôles

| Action | Téléphone | Clavier / souris |
|---|---|---|
| Bouger | Joystick : poser le pouce n'importe où sur la moitié gauche | ZQSD (AZERTY) ou WASD (QWERTY), flèches |
| Caméra | Glisser sur la moitié droite | Souris (clic dans le jeu pour la capturer) |
| Tirer | Bouton TIR en bas à droite (on peut viser en gardant le doigt dessus) | Clic gauche |
| Viser (zoom) | Bouton VISER : un appui l'active, un autre le désactive | Maintenir le clic droit |
| Corps à corps | Bouton COUP | F |
| Ulti | Bouton ULTI, quand la jauge est pleine | E |
| Inspecter son arme | Bouton INSP. (un 2e appui pendant l'inspection montre l'arme de mêlée) | Y |
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

La toute première partie affiche quelques conseils, un à la fois : se déplacer, tirer, frapper au corps à corps, puis lancer l'ulti quand sa jauge est pleine. Chacun disparaît dès qu'il est fait, et ils ne reviennent plus ensuite.

Chaque jour, trois défis (abattre 60 ennemis, toucher 25 fois à la tête, battre un boss…) sont tirés au sort, les mêmes pour tout le monde. Leur progression s'additionne sur les parties de la journée, et chaque défi réussi rapporte son XP, même si la partie se termine par une mort. Le bouton DÉFIS · STATS de l'accueil les montre, à côté des statistiques de carrière : parties, temps de jeu, ennemis, boss, meilleure vague, précision, tirs à la tête, arme favorite.

Battre le Titan fait apparaître un trophée et donne le skin Champion. Tu choisis alors : rentrer au menu avec toute l'XP, ou continuer en **mode sans fin** : les arènes reviennent dans l'ordre, les boss reviennent plus forts à chaque tour, et la partie dure jusqu'à ta mort (qui ne rapporte que la moitié de l'XP, comme d'habitude) ou jusqu'à ce que tu rentres après un boss. Les dix meilleures parties jouées sur l'appareil forment un classement local, visible dans DÉFIS · STATS ; l'écran de fin indique la place obtenue.

## Arènes

Les arènes font 60 m de côté. La partie commence dans la station, et chaque boss battu t'emmène dans la suivante. Chacune a ses ennemis :

| Arène | Ennemis | Arme |
|---|---|---|
| Station | Gardes | Pistolet |
| Désert | Assassins des sables | Pistolet-mitrailleur |
| Jungle | Gobelins | Couteau : ils foncent et frappent au contact |
| Volcan | Zombies (et des flaques de lave qui blessent) | Mains nues, au contact |
| Ville | Hommes en costume | Revolver |

Dans toutes les arènes, d'autres ennemis se mêlent aux vagues. À partir de la vague 2, chaque vague (hors boss) compte un **ennemi d'élite** : plus grand, entouré d'un halo doré, trois fois plus résistant ; il lâche toujours un bonus et rapporte 400 points. À partir de la vague 4 arrivent les **tireurs d'élite** : ils restent à distance, reculent si tu t'approches, et un laser rouge te vise une seconde avant chaque tir (18 dégâts) ; sortir de leur ligne de vue suffit à l'esquiver. À partir de la vague 6, les **kamikazes**, rouges et clignotants, foncent sur toi et explosent au contact (25 dégâts dans un rayon de 3,5 m) ; ils explosent aussi quand on les abat, donc mieux vaut les toucher de loin.

À partir de la vague 3, environ un ennemi sur quatre est une chauve-souris : elle vole à 4 ou 5 m, tourne autour de toi et crache des projectiles. Elle est plus fragile que les autres.

Après chaque boss, avant de partir vers l'arène suivante, le jeu propose de rentrer au menu. Rentrer encaisse toute l'XP de la partie ; mourir plus loin n'en rapporte que la moitié.

Une mini-carte en haut à gauche montre les ennemis en rouge (les boss en plus gros) et les power-ups dans leur couleur.

## Ultis

Chaque personnage a une capacité ultime. Sa jauge, affichée au-dessus des munitions, se remplit de 10 % par ennemi abattu (et lentement avec le temps). Une fois pleine, le bouton ULTI ou la touche E la déclenche.

| Personnage | Ulti | Effet |
|---|---|---|
| Soldat | Frappe aérienne | Bombarde les 5 ennemis les plus proches |
| Cow-boy | Duel | Tire d'un coup sur les 6 ennemis les plus proches |
| Soldate | Surrégime | 8 s de tir deux fois plus rapide, sans recharger |
| Ninja | Clones | Deux clones se battent à tes côtés pendant 12 s |
| Pirate | Bordée | Tire 8 roquettes tout autour de toi |
| Chevalier | Rempart | Invulnérable pendant 6 s |
| Samouraï | Tourbillon | Tranche tous les ennemis à moins de 5 m |
| Viking | Rage | Soin, puissance et vitesse |
| Elfe | Volée de flèches | Touche tous les ennemis de l'arène |
| Cow-girl | Dynamite | Explosion de 9 m qui repousse les ennemis |
| Sorcière | Malédiction | Tous les ennemis brûlent et sont ralentis |
| Magicien | Arrêt du temps | Fige tous les ennemis pendant 5 s (2 s pour un boss) |
| Chevalier d'or | Bénédiction | Soin complet, bouclier et régénération |

## Passe de combat

Chaque partie rapporte de l'XP (un dixième du score, divisé par deux si tu meurs). Le passe compte 70 paliers, permanents et gratuits : les 30 premiers coûtent de plus en plus cher, les 40 suivants (le reste des armes à feu, puis cinq lames) 1000 XP chacun. Chaque palier débloque un personnage, une arme, une arme de corps à corps ou un skin d'arme. Le Soldat, le Blaster, le Couteau et le skin Standard sont disponibles dès le départ. L'ordre des récompenses est dans `scripts/battle_pass.gd`.

## Arsenal

L'arsenal, accessible depuis l'accueil, a cinq onglets : héros, arme, mêlée (corps à corps), skin d'arme et skin de mêlée. Un élément verrouillé peut être prévisualisé, mais pas équipé. Dans les onglets d'armes et de skins, l'arme est montrée seule : elle flotte et tourne sur elle-même.

| Arme | Cadence | Dégâts | Chargeur |
|---|---|---|---|
| Pistolet | 4/s | 2 | 12 |
| Fusil d'assaut | 10/s | 1 | 30 |
| Fusil de précision (zoom plus fort) | 1/s | 8 | 5 |
| PM (pistolet-mitrailleur) | 14/s | 1 | 40 |
| Lance-roquettes (explosion de 4 m) | 0,8/s | 10 | 1 |

Le pack d'armes complet est disponible : 40 armes en comptant ces cinq-là (pistolets, revolvers, fusils d'assaut, bullpups, fusils à pompe, pistolets-mitrailleurs, fusils de précision). Les revolvers tirent lentement mais fort, avec 6 coups. Les fusils à pompe tirent plusieurs plombs à la fois, en cône : redoutables de près, faibles de loin. Les statistiques de chaque arme sont dans l'arsenal et dans `scripts/loadout.gd`.

Un tir dans la tête fait le double de dégâts : le marqueur de touche devient jaune.

| Corps à corps | Délai | Dégâts | Portée |
|---|---|---|---|
| Kunaï (une cible) | 0,3 s | 3 | 2 m |
| Couteau papillon (une cible) | 0,4 s | 4 | 2,1 m |
| Couteau (une cible) | 0,5 s | 4 | 2,2 m |
| Karambit (tous les ennemis juste devant) | 0,5 s | 5 | 2 m |
| Katana (large balayage) | 0,7 s | 7 | 3,2 m |
| Lance (transperce les ennemis alignés) | 0,8 s | 6 | 4,5 m |
| Machette (une cible) | 0,9 s | 9 | 2,6 m |
| Masse (repousse l'ennemi) | 1 s | 8 | 2,4 m |
| Hache (tous les ennemis devant soi) | 1,1 s | 10 | 2,6 m |

L'inspection montre l'arme en gros plan devant la caméra, le temps de la regarder : une arme à feu se retourne et son chargeur sort, tourne puis se réenclenche (les revolvers, fusils à pompe et le lance-roquettes font un tonneau) ; le couteau papillon s'ouvre, tournoie et se referme ; les autres armes de mêlée tournent sur elles-mêmes. Tirer, viser, frapper, recharger ou lancer l'ulti l'interrompt.

Les modèles des armes de corps à corps sont dessinés par code (`tools/make_melee_models.py`) : lame en acier brossé, manche en bois, en caoutchouc ou tressé. Les 13 skins servent aussi à ces armes, avec un choix séparé de celui de l'arme à feu : la finition repeint la lame et garde le manche. Elle ne change que l'apparence.

Les skins d'armes sont des finitions : ils gardent la forme de l'arme et la repeignent d'un motif (néon, camouflage, fibre de carbone, lave…), certains la font briller ou lui ajoutent une lunette ou un silencieux, et chacun change la couleur du tir. Les statistiques ne changent pas. Le skin décide aussi de la façon dont meurent les ennemis abattus : ils fondent en flaque (Toxique, Océan), gèlent puis éclatent (Glace, Or), se consument (Lave, Solaire), se dissipent en rayon de lumière (Néon, Royal) ou explosent en morceaux (Sakura, Champion). Le skin Champion ne s'obtient qu'en battant le boss final. Il y a 13 personnages : ils ne diffèrent que par leur apparence et leur ulti.

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
