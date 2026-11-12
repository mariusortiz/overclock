# Overclock

Shooter sci-fi en 3D low-poly pour Android, en vue à la troisième personne. Tu affrontes des vagues de robots dans une arène. Fait avec [Godot](https://godotengine.org) 4.5.

## Tester le jeu

https://mariusortiz.github.io/overclock-builds/

Cette version web est mise à jour à chaque push sur `main`. Elle s'ouvre aussi dans le navigateur d'un téléphone.

Elle se charge toujours depuis le réseau : chaque mise à jour s'affiche à la prochaine ouverture du lien. Pour une vraie application sur téléphone, il y a l'APK (ci-dessous).

### APK Android

Chaque push sur `main` compile aussi un APK et le publie dans la release **latest-debug** du dépôt public [overclock-builds](https://github.com/mariusortiz/overclock-builds). Le lien ne change jamais :

https://github.com/mariusortiz/overclock-builds/releases/download/latest-debug/overclock-debug.apk

Ouvre-le sur le téléphone, puis installe l'APK (il faut autoriser le navigateur à installer des applications inconnues). Les mises à jour s'installent par-dessus l'ancienne version, car elles sont toutes signées avec la même clé de debug. L'APK utilise le moteur de rendu complet (Vulkan) : le rendu et les FPS y sont meilleurs que dans le navigateur.

## Contrôles

| Action | Téléphone | Clavier / souris |
|---|---|---|
| Bouger | Joystick : poser le pouce n'importe où sur la moitié gauche | ZQSD (AZERTY) ou WASD (QWERTY), flèches |
| Caméra | Glisser sur la moitié droite | Souris (clic dans le jeu pour la capturer) |
| Tirer | Bouton TIR en bas à droite (on peut viser en gardant le doigt dessus) | Clic gauche |
| Viser (zoom) | Bouton VISER : un appui l'active, un autre le désactive | Maintenir le clic droit |
| Corps à corps | Bouton COUP | F |
| Ulti | Bouton ULTI : sa jauge se remplit autour de lui, il devient doré quand elle est pleine | E |
| Inspecter son arme | Bouton INSPECTER sous le bouton pause (un 2e appui pendant l'inspection montre l'arme de mêlée) | Y |
| Recharger | Bouton RECHARGER à gauche du bouton TIR (automatique quand le chargeur est vide) | R |
| Pause et réglages | Bouton II en haut à droite, ou bouton retour d'Android | Échap |
| Danser | Bouton DANSE en haut à droite, puis choisir parmi 6 danses : la caméra passe devant le héros ; bouger, tirer ou être touché arrête la danse | B |
| Abandonner la partie | Pause, puis QUITTER : la partie compte, avec la moitié de l'XP | Échap |
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

Le héros saute bras écartés et genoux repliés, s'écrase un instant en atterrissant (avec un nuage de poussière, plus fort après une grande chute) et se penche en avant quand il court. Les personnages n'ayant pas ces animations, elles sont faites par code (`scripts/pose_layer.gd`, `scripts/dances.gd`), comme les six danses : Robot, Disco, Vague, Bras en l'air, Pas chassé et Fête.

Chaque jour, trois défis (abattre 60 ennemis, toucher 25 fois à la tête, battre un boss…) sont tirés au sort, les mêmes pour tout le monde. Leur progression s'additionne sur les parties de la journée, et chaque défi réussi rapporte son XP, même si la partie se termine par une mort. Le bouton DÉFIS · STATS de l'accueil les montre, à côté des statistiques de carrière : parties, temps de jeu, ennemis, boss, meilleure vague, précision, tirs à la tête, arme favorite.

Battre le Titan fait apparaître un trophée et donne le skin Champion. Tu choisis alors : rentrer au menu avec toute l'XP, ou continuer en **mode sans fin** : les arènes reviennent dans l'ordre, les boss reviennent plus forts à chaque tour, et la partie dure jusqu'à ta mort (qui ne rapporte que la moitié de l'XP, comme d'habitude) ou jusqu'à ce que tu rentres après un boss. Les dix meilleures parties jouées sur l'appareil forment un classement local, visible dans DÉFIS · STATS ; l'écran de fin indique la place obtenue.

## Arènes

Les arènes font 60 m de côté, sur plusieurs niveaux : ponts, passerelles, étages et toits accessibles, avec des passages dessous. La partie commence dans la station, et chaque boss battu t'emmène dans la suivante.

| Arène | Ce qu'on y trouve |
|---|---|
| Station | tour de contrôle à deux étages, reliée par des passerelles aux plateformes le long des murs ; quai de chargement, conteneurs, machines |
| Désert | temple à gradins, plateau rocheux relié par un pont de pierre, tour en ruine, murs écroulés, oasis |
| Jungle | cabanes dans les arbres reliées par des ponts de corde, rivière avec passerelle et gué, ruines de temple |
| Volcan | rivière de lave franchie par deux ponts de pierre, plateaux sur deux hauteurs, cratère |
| Ville | carrefour sous un pont routier, immeubles au toit accessible par un escalier extérieur, voitures, feux et lampadaires |

Les boss apparaissent au sol, dans un espace dégagé. La CI vérifie que chaque étage de chaque arène est accessible à pied aux ennemis.

Chaque arène a ses ennemis :

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

L'inspection montre l'arme en gros plan devant la caméra, le temps de la regarder : une arme à feu se présente de profil, bascule d'un côté puis de l'autre et se retourne ; le couteau papillon s'ouvre, tournoie et se referme ; les autres armes de mêlée tournent sur elles-mêmes. Tirer, viser, frapper, recharger ou lancer l'ulti l'interrompt.

Les modèles des armes de corps à corps sont dessinés par code (`tools/make_melee_models.py`) : lame en acier brossé, manche en bois, en caoutchouc ou tressé. Les 13 skins servent aussi à ces armes, avec un choix séparé de celui de l'arme à feu : la finition repeint la lame et garde le manche. Elle ne change que l'apparence.

Les skins d'armes sont des finitions : ils gardent la forme de l'arme et la repeignent d'un motif (néon, camouflage, fibre de carbone, lave…), certains la font briller ou lui ajoutent une lunette ou un silencieux, et chacun change la couleur du tir. Les statistiques ne changent pas. Chaque skin a aussi sa propre façon d'éliminer les ennemis :

| Skin | Élimination |
|---|---|
| Standard | projeté en arrière en tournoyant, disparaît dans un nuage de fumée |
| Néon | s'étire en rayon de lumière |
| Glace | gèle puis éclate |
| Lave | se consume en braises |
| Camouflage | se défait en feuilles qui tombent |
| Toxique | fond en flaque verte |
| Royal | s'élève en tournant, couronné d'étincelles violettes |
| Carbone | se pixelise en cubes noirs |
| Sakura | éclate en pétales roses |
| Océan | éclate en gerbe d'eau et s'affaisse |
| Solaire | flash aveuglant et rayons de soleil |
| Or | se change en statue dorée qui s'effondre |
| Champion | explosion de confettis et éclair de lumière |

Les boss gardent leur propre chute. Le skin Champion ne s'obtient qu'en battant le boss final. Il y a 13 personnages dans le passe et 6 de plus à la boutique : ils ne diffèrent que par leur apparence et leur ulti.

## Boutique

La boutique, accessible depuis l'accueil, vend du contenu qu'on ne trouve pas dans le passe de combat : 6 armes exotiques, 5 skins à finition animée et 6 personnages à ulti boostée. Un achat est équipé tout de suite et reste dans l'arsenal.

Elle a cinq onglets. **Du jour** montre quatre offres, les mêmes pour tous les joueurs, renouvelées à minuit ; la première est à -30 %. **Héros**, **Armes** et **Skins** forment le catalogue permanent. **Gemmes** vend des packs de gemmes contre de l'argent réel (Android uniquement, voir « Paiements » plus bas).

Deux monnaies :
- les **crédits** se gagnent en jouant : un dixième du score à chaque partie (divisé par deux si tu meurs ou quittes) ;
- les **gemmes** s'achètent, et se gagnent aussi en petite quantité : 3 par boss vaincu, 10 quand les trois défis du jour sont réussis.

Chaque article se paie au choix en crédits ou en gemmes : personnage 6000 crédits ou 450 gemmes, arme 3500 ou 260, skin 2500 ou 180.

| Arme exotique | Particularité | Cadence | Dégâts | Chargeur |
|---|---|---|---|---|
| Laser | rayon continu | 15/s | 1 | 80 |
| Fusil à rail | rayon qui transperce tous les ennemis alignés | 1,1/s | 9 | 4 |
| Canon plasma | boule qui explose (3 m) | 2,2/s | 5 | 8 |
| Lance-flammes | portée 11 m, enflamme | 8/s | 1 ×2 | 60 |
| Lance-fléchettes | 5 fléchettes qui transpercent | 3/s | 2 ×5 | 10 |
| Minigun | cadence extrême, longue recharge | 24/s | 1 | 150 |

| Skin animé | Finition | Élimination |
|---|---|---|
| Hologramme | lignes lumineuses qui défilent | rayon de lumière |
| Galaxie | étoiles qui scintillent sur une nébuleuse | envol |
| Plasma | vagues orange et magenta | braises |
| Glitch | blocs de couleur qui sautent | pixels |
| Prisme | arc-en-ciel qui défile | confettis |

| Personnage | Ulti boostée |
|---|---|
| Kunoichi | Clones ×1,6 : trois clones au lieu de deux |
| Capitaine | Bordée ×1,75 : 14 roquettes, plus fortes |
| Ronin | Tourbillon ×1,6 : 8 m, 48 dégâts |
| Paladine d'or | Bénédiction ×1,5 : plus 4,5 s d'invulnérabilité |
| Le Parrain | Duel ×2 : 12 ennemis, double dégâts |
| Ombre des sables | Arrêt du temps ×1,6 : 8 s |

### Paiements (gemmes contre de l'argent réel)

Le code est prêt (`scripts/billing.gd`), mais l'achat de gemmes reste inactif tant que ces étapes ne sont pas faites. D'ici là, le bouton indique « bientôt sur Android » ; la version web n'aura jamais de paiement.

1. Créer un compte Google Play Console (frais unique de 25 $) et un profil de paiement marchand.
2. Créer l'application avec le nom de paquet de l'APK, et l'envoyer au moins une fois en test interne : Google Play Billing ne fonctionne qu'avec une version distribuée par le Play Store.
3. Dans « Produits intégrés », créer trois produits gérés : `gems_100`, `gems_550` et `gems_1200`, avec leur prix.
4. Installer le plugin [Godot Google Play Billing](https://github.com/godot-sdk-integrations/godot-google-play-billing) (version 3.x) dans `addons/GodotGooglePlayBilling/` et l'activer dans les réglages du projet.
5. Dans le preset d'export Android, activer `gradle_build/use_gradle_build` ; la CI doit alors installer le modèle de build Android. Signer avec une clé de publication (stockée en secret GitHub), pas la clé de debug.
6. Ajouter des testeurs de licence dans la Play Console pour acheter sans être débité.

Limite : les achats sont vérifiés par Google sur le téléphone, sans serveur de vérification. C'est suffisant pour un jeu solo, mais un joueur déterminé peut tricher sur sa propre sauvegarde.

## Développer en local (optionnel)

1. Installe Godot 4.5.1 (la version standard, pas .NET).
2. Ouvre `project.godot`, puis lance le jeu avec F5.

## Structure

- `scenes/` : scènes Godot (`.tscn`)
- `scripts/` : code GDScript
- `assets/` : modèles 3D, sons et musique CC0 (voir `CREDITS.md`), plus les textures générées par les scripts de `tools/`
- `tools/` : scripts Python qui génèrent les arènes (`scenes/arenas/`), les textures et les sons
- `ci/debug.keystore` : clé de debug publique (mot de passe `android`), utilisée uniquement pour les APK de test. La clé de release ne sera jamais commitée.
- `.github/workflows/build.yml` : contrôles automatiques, compilation de la version web et de l'APK

## Licence des assets

Tous les modèles, sons et musiques externes sont en CC0. Le détail est dans [CREDITS.md](CREDITS.md).
