# Overclock

Shooter sci-fi en 3D low-poly pour Android, en vue à la troisième personne. Tu affrontes des vagues de robots dans une arène. Fait avec [Godot](https://godotengine.org) 4.5.

## Tester le jeu

https://overclock.randomlabs.dev/

Cette version web est mise à jour à chaque push sur `main`. Elle s'ouvre aussi dans le navigateur d'un téléphone.

Elle se charge toujours depuis le réseau : chaque mise à jour s'affiche à la prochaine ouverture du lien. Pour une vraie application sur téléphone, il y a l'APK (ci-dessous).

### APK Android

Chaque push sur `main` compile aussi un APK et le publie dans la release **latest-debug** du dépôt public [overclock-builds](https://github.com/mariusortiz/overclock-builds). Le lien ne change jamais :

https://github.com/mariusortiz/overclock-builds/releases/download/latest-debug/overclock-debug.apk

Ouvre-le sur le téléphone, puis installe l'APK (il faut autoriser le navigateur à installer des applications inconnues). Les mises à jour s'installent par-dessus l'ancienne version, car elles sont toutes signées avec la même clé de debug. L'APK utilise le moteur de rendu complet (Vulkan) : le rendu et les FPS y sont meilleurs que dans le navigateur.

### Site

Page de présentation (trailer, anime, liens pour jouer et pour l'APK) : https://overclock.randomlabs.dev/site/

Sa source est dans `site/`, publiée avec chaque build web. Godot l'ignore (`site/.gdignore`).

### Vidéos

- Trailer (2 min 30) : https://overclock.randomlabs.dev/trailer.html
- Anime, épisode 1 « L'escouade » (2 min) : https://overclock.randomlabs.dev/anime.html
- Anime, saison 2 « Le Créateur » (épisodes 11 à 20) : https://overclock.randomlabs.dev/anime11.html (puis anime12 … anime20). Un virus corrompt le monde du jeu ; le Créateur, l'homme à tête de vache qui l'a écrit, guide l'escouade jusqu'au redémarrage. Les épisodes de la saison 2 partagent `scripts/anime/season2.gd` (glitchs, ennemis corrompus, apparitions) : le modifier rend les saisons 2 et 3.
- Anime, saison 3 « Le Portail » (épisodes 21 à 30) : https://overclock.randomlabs.dev/anime21.html (puis anime22 … anime30). Un portail emmène l'escouade dans une galaxie inconnue ; pour rentrer, il faut résoudre ses mystères : le chant des cristaux, l'archive de la version 0, la lune qui boucle, l'énigme du Gardien. Les épisodes de la saison 3 partagent `scripts/anime/season3.gd` (portail, planètes, Gardien, golems) : le modifier ne rend que la saison 3.

Les deux sont jouées par le moteur avec les modèles du jeu (`scripts/trailer.gd`, `scripts/anime.gd`) et rendues par leur propre workflow GitHub Actions quand ces fichiers changent. L'anime ajoute un rendu en cel-shading (aplats de lumière et contours à l'encre), des bulles façon manga, des lignes de vitesse et des images d'impact.

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
| Danser | Bouton DANSE en haut à droite, puis choisir parmi 6 danses (plus celles achetées à la boutique) : la caméra passe devant le héros ; bouger, tirer ou être touché arrête la danse | B |
| Abandonner la partie | Pause, puis QUITTER : la partie compte, avec la moitié de l'XP | Échap |
| Sauter | Bouton SAUT au-dessus du bouton TIR | Espace |

## Modes de jeu

JOUER propose le mode à lancer :

- **Vagues** : le mode d'origine, des vagues d'ennemis et un boss toutes les cinq vagues, jusqu'au Titan.
- **Capture de zone** : ton équipe (toi et 3 bots alliés) contre 4 bots adverses, dans une arène tirée au hasard. Trois zones, A, B et C : seul dans une zone, ton équipe la prend en 5 s (plus vite à plusieurs) ; à plusieurs camps dedans, elle est disputée et ne bouge plus. Chaque zone tenue rapporte un point par seconde ; la première équipe à 150 gagne. On réapparaît à sa base 5 s après être tombé. Le score vient des éliminations (100), des zones prises en étant dedans (250) et de la victoire (1500) ; une défaite ne rapporte que la moitié de l'XP et des crédits. Les alliés ont un losange cyan au-dessus de la tête, les adversaires un rouge ; la mini-carte montre les zones et les alliés.
- **Histoire** : la saison 1 de l'anime en 10 chapitres, un par épisode. Chaque chapitre commence par une courte scène animée (passable avec PASSER), puis une mission avec le héros de l'épisode : vagues dans l'arène de l'épisode (jusqu'à son boss), course (une place à atteindre) ou capture de zone. Une mission rapporte 1 à 3 étoiles (santé restante, place ou score adverse) ; un chapitre s'ouvre quand le précédent est gagné. Première victoire d'un chapitre : des gemmes, un booster rare et la carte de l'épisode ; le dernier donne en plus 500 gemmes et le vaisseau Écarlate, le vaisseau de Vipère. Le mode histoire a sa propre musique, et chaque circuit de course la sienne.
  - **Saison 2 : Le Créateur** (chapitres 11 à 20, onglet SAISON 2), ouverte dès le départ : le Virus, Le Créateur, les trois fragments du code source. Dans ses missions de vagues, les ennemis sont corrompus (lueur verte). Deux courses pilotées avec l'Écarlate. Première victoire : des gemmes et un booster rare (pas de carte : l'album reste à 99) ; le dernier chapitre donne en plus 1000 gemmes et un booster légendaire. Ses scènes ont leur propre musique (Cyberpunk Moonlight Sonata). On n'y joue jamais Le Créateur : il reste réservé au code.
  - **Saison 3 : Le Portail** (chapitres 21 à 30, onglet SAISON 3), ouverte dès le départ : un portail emmène l'escouade dans une galaxie inconnue (la Planète de cristal, les Ruines stellaires, une lune où le temps boucle), Le Créateur y perd ses pouvoirs, l'Escouade Écarlate revient, et le Gardien attend au cœur de la galaxie. Missions de vagues sur les nouvelles arènes (avec leur propre boss : reine des sentinelles, golem, chauve-souris des météores, le Gardien), captures, et deux courses, dont la revanche promise à Vipère. Première victoire : des gemmes, un booster rare et la carte de l'épisode ; le dernier chapitre donne en plus 1500 gemmes et un booster légendaire. Musique : Alien World.
- **Course de vaisseaux** : 3 tours d'un circuit dans l'espace contre 5 pilotes. Avant la course, on choisit l'un des 5 circuits (ou au hasard) : Anneau d'Orion, Nébuleuse (brume rose, gros dénivelés), Ceinture d'astéroïdes (rochers tout près de la piste), Soleil rouge (longues courbes rapides) et Labyrinthe de glace (virages serrés). En multijoueur, le circuit est tiré au sort. Des caisses lumineuses, par rangées de trois, donnent un objet à utiliser avec OBJET (touche F) : turbo, missile (deux tirs sur le vaisseau devant), bouclier, mines, onde EMP ou fantôme (invisible et intouchable 3 s). Les derniers reçoivent plus souvent les objets d'attaque. Le vaisseau avance tout seul ; on le dirige dans le tube du circuit (joystick ou ZQSD). Les plaques cyan donnent un boost ; chaque anneau traversé remplit la jauge de la capacité spéciale du vaisseau, à lancer avec CAPACITÉ (touche E). TIR (clic ou espace) envoie un laser droit devant : le vaisseau touché ralentit, et explose au troisième tir avant de repartir. L'XP et les crédits dépendent de la place (3000 points pour la 1re, 600 pour la 6e). Les vaisseaux sont faits de formes simples en attendant un modèle 3D : un fichier .glb, .gltf ou .fbx déposé dans `assets/models/ships/` (nez vers -Z) le remplace automatiquement.
- **Vagues de Noël** (du 1er décembre au 6 janvier, selon la date de l'appareil ; le code de test l'active à tout moment) : 10 vagues dans le **Village enneigé** (chalets au toit accessible, lac gelé, pont de glace, grand sapin illuminé, neige qui tombe), contre des lutins, avec le **Père Glaçon** aux vagues 5 et 10 (un squelette géant de glace au bonnet rouge : éclats de glace en éventail et stalactites qui tombent). La victoire rapporte 300 gemmes et un booster rare la première fois chaque année. Pendant l'événement : neige et musique de Noël à l'accueil, un **cadeau du jour** (un booster, rare les 24 et 25), des défis du jour de Noël mieux payés, la boutique de Noël (skins Sucre d'orge, Flocon et Guirlande avec leurs effets d'élimination : bonbons, neige, ampoules ; danses Bonhomme de neige et Traîneau), le village en capture et en combat, et la série de cartes « Noël » dans les boosters. Ce qui a été acheté ou gagné reste après l'événement.
- **Coop en vagues** (Wi-Fi, depuis MULTIJOUEUR, 2 à 4 joueurs) : le mode Vagues à plusieurs. L'hôte fait tourner les vagues, les ennemis et les boss ; chaque appareil joue son héros. Les ennemis sont plus nombreux (+50 % par joueur en plus) et plus solides (+30 %) et visent le joueur le plus proche. Un joueur à terre se relève si un équipier reste 3 s près de lui, et tout le monde se relève à la vague suivante ; la partie est perdue si tous sont à terre en même temps. Pas de pause : les pouvoirs sont tirés au sort après chaque vague, et l'hôte emmène tout le monde dans l'arène suivante après un boss. Chacun gagne son XP. Une élimination compte pour le joueur qui a porté le dernier coup (score, XP, défis). À la fin, REJOUER ENSEMBLE relance une partie pour toute l'équipe (côté hôte ; les invités suivent).
- **Passe de combat saison 2 · Matrice** : 70 nouveaux paliers (onglets SAISON 1 / SAISON 2 dans l'écran du passe). Toute l'XP compte pour les deux passes à la fois : la saison 2 part de zéro à sa sortie, rien de la saison 1 n'est perdu. Entre ses objets, elle donne des crédits, des gemmes et des boosters (dont un légendaire au palier 60). Objets : 5 skins (Données, Pare-feu, Corruption, Binaire, Noyau), 2 danses (Glitch, Redémarrage), le vaisseau Pare-feu et, au palier 70, le héros **Programme** (un ninja vert lumineux, ulti Clones renforcée).
- **Succès** : 51 succès (DÉFIS · STATS → SUCCÈS), mesurés sur la carrière, les passes, les cartes, les étoiles du mode histoire et quelques exploits (battre le Titan, battre le Virus sans perdre un point de vie, finir les vagues de Noël, l'arcade, gagner contre l'IA difficile, une course, une capture). Chacun rapporte des gemmes une fois ; Platine, pour les 49 premiers, donne aussi le skin Platine ; **Éleveur** (10 animaux) donne la Couronne pour les animaux. Un succès atteint s'affiche à la fin de la partie ou en bannière à l'accueil.
- **Combat** : un contre un, de profil, sur les arènes du jeu (le décor entre les combattants et la caméra s'efface). Deux manches gagnantes de 60 s. Chaque héros se bat avec son équipement : POING (rapide), PIED (plus long), ARME (sa lame, la portée et les dégâts de la lame), et des coups spéciaux : bas + POING un uppercut (contre les sauts), bas + ARME un tir (on l'évite accroupi ou en sautant, deux tirs qui se croisent s'annulent), avant + PIED un coup de pied sauté qui fait tomber, POING ou PIED en l'air un coup de pied sauté. On garde en reculant (debout ou accroupi) : un coup gardé ne fait presque rien. La jauge SUPER se remplit en frappant et en encaissant ; pleine, SUPER lance la version combat de l'ulti du héros (frappe aérienne, duel, clones, tourbillon, arrêt du temps, accès root…). Les héros de la boutique ont un super plus fort (leur boost), Le Créateur plus de vie, plus de vitesse et Ctrl+Alt+Suppr. Chaque héros a aussi un **coup spécial** à lui (bas + PIED, 4 s de recharge) : grenade du Soldat, lasso de la Cow-girl, gel du Magicien, pas de l'ombre de la Kunoichi, Supprimer du Créateur… Mode **entraînement** : un mannequin qui ne tombe jamais (immobile, qui garde, qui saute ou qui attaque), un compteur de combo et un tutoriel en 8 étapes (la première fois : 150 gemmes et un booster). Modes : contre l'IA (facile, normal, difficile ; 20 à 70 crédits par victoire), 2 joueurs sur le même appareil (clavier ZQSD + F G H, R / flèches + J K L, I ; deux manettes ; ou l'écran tactile partagé en deux), arcade (5 combats de plus en plus durs puis le Titan Mk II dans la ville ; la première fois 300 gemmes et un booster rare) et Wi-Fi (deux appareils, depuis MULTIJOUEUR : l'hôte fait tourner le combat). Sur écran tactile : une croix à gauche, quatre boutons à droite. Code : `scripts/fight/`.

### Vaisseaux

Huit vaisseaux pour la course, choisis dans l'onglet VAISSEAU de l'arsenal. Le Dard est disponible dès le départ, les sept autres se débloquent aux paliers 71 à 77 du passe. Chacun a sa silhouette, ses attributs et une capacité spéciale, déclenchée quand la jauge des anneaux est pleine (bouton CAPACITÉ, touche E). En course, les pilotes de l'ordinateur prennent les autres vaisseaux.

| Vaisseau | Vitesse | Maniabilité | Bouclier | Cadence | Capacité |
|---|---|---|---|---|---|
| Dard | 100 % | 100 % | 3 | 100 % | Surboost : 4 s de vitesse maximale |
| Faucon | 106 % | 110 % | 2 | 100 % | Rafale : touche tous les vaisseaux devant |
| Bélier | 95 % | 80 % | 5 | 80 % | Rempart : intouchable 4 s, renverse ceux qu'il percute |
| Spectre | 100 % | 130 % | 2 | 100 % | Camouflage : invisible et intouchable 4 s |
| Comète | 104 % | 90 % | 3 | 90 % | Hyperpropulsion : bond de 70 m |
| Frelon | 100 % | 110 % | 3 | 160 % | Missile guidé : deux touches sur le vaisseau devant |
| Tempête | 98 % | 100 % | 4 | 100 % | Onde EMP : ralentit les vaisseaux à moins de 45 m |
| Nova | 102 % | 100 % | 3 | 110 % | Mines : trois mines derrière soi |
| Oméga (boutique, ULTRA) | 122 % | 135 % | 6 | 180 % | Hyperdrive : 6 s de vitesse maximale, intouchable |
| Faucheuse (boutique, ULTRA) | 118 % | 120 % | 4 | 220 % | Trou noir : touche deux fois tous les vaisseaux devant |
| Aurore (boutique, ULTRA) | 120 % | 150 % | 5 | 150 % | Chronos : ralentit tous les autres 3 s |


## Animaux de compagnie

17 compagnons qui suivent le héros (à sa droite) en vagues, en coop, en capture et en combat, sur l'accueil et dans l'arsenal (onglet ANIMAL). Chacun a un petit coup de main, actif en vagues, en coop et en capture contre les bots ; en combat et en capture contre d'autres joueurs, il n'est là que pour être vu.

| Animal | Rareté | Bonus | Obtention |
|---|---|---|---|
| Chien | Commun | Rapporte : attire les bonus à moins de 10 m | Œuf |
| Chat | Commun | Porte-bonheur : +10 % de chances de bonus par ennemi | Œuf |
| Poussin | Commun | Piou : +10 % d'XP | Œuf |
| Mouton | Commun | Laine : −10 % de dégâts reçus | Œuf |
| Renard | Rare | Vif : +6 % de vitesse | Œuf |
| Mini chauve-souris | Rare | Écho : une onde toutes les 3 s (2 dégâts) | Œuf |
| Cochon | Rare | Tirelire : +10 % de crédits | Boutique |
| Lama | Rare | Crachat : ralentit un ennemi toutes les 5 s | Boutique |
| Carlin | Rare | Câlin : 1 PV par élimination | Palier 16 du passe saison 2 |
| Loup | Épique | Morsure : 3 dégâts au contact toutes les 3 s | Œuf |
| Mini slime | Épique | Gelée : 1 PV toutes les 3 s | Boutique |
| Aigle | Épique | Piqué : 4 dégâts à 20 m toutes les 6 s | Palier 33 du passe saison 2 |
| Drone | Épique | Tourelle : 1 dégât toutes les 1,5 s | Boutique |
| Dragonnet | Légendaire | Souffle : enflamme un ennemi toutes les 5 s | Œuf |
| Mini-Titan | Légendaire | Bouclier : annule un coup toutes les 20 s | Palier 57 du passe saison 2 |
| Veau | Légendaire | Petit créateur : ulti 15 % plus rapide | Œuf |
| Éclat de cristal | Légendaire | Chant : ralentit les ennemis proches toutes les 8 s | Œuf |
| Capybara | Hacker | Mode dieu (voir Le Créateur) | Code du Créateur |

**Œufs** : un par boss vaincu (vagues et coop) et un quand les trois défis du jour sont réussis, trois au plus en attente. Le premier éclôt après 10 vagues terminées (FAIRE ÉCLORE dans l'onglet ANIMAL) : 60 % commun, 28 % rare, 10 % épique, 2 % légendaire ; un animal déjà eu rapporte 100 gemmes. En boutique : 4000 crédits ou 300 gemmes. Chaque animal a sa carte (série Compagnons de l'extension). L'épisode hors-série 31 de l'anime les présente.

**Accessoires** (onglet ACCESSOIRE de l'arsenal) : un accessoire se porte sur l'animal équipé, quel qu'il soit, et ne change que l'apparence. Boutique (1500 crédits ou 110 gemmes) : Lunettes de soleil, Nœud papillon, Haut-de-forme, et pendant Noël le Bonnet de Noël, l'Écharpe de Noël et les Bois de renne. Œufs (un œuf sur trois donne un accessoire, un doublon rapporte 60 gemmes) : Casque de pilote, Auréole, Cornes de diable, Casque à antennes. Passe saison 2, palier 40 : Chapeau de cowboy. Succès Éleveur : Couronne. Chacun a sa carte (série Accessoires de l'extension ; celles de Noël ne sortent des boosters que pendant l'événement).

## Cartes à collectionner

99 cartes en 10 séries : héros, ennemis (dont le tireur d'élite et le kamikaze), boss, vaisseaux, armes, armes de mêlée, skins, arènes, épisodes de l'anime et mythiques. Chaque carte a son nom, sa puissance, son illustration, un encadré de capacité (l'ulti du héros, la capacité du vaisseau, les stats de l'arme…), son numéro (012/099) et son symbole de rareté. Cinq raretés : commune (62 % des tirages), rare (26 %), épique (10 %, cadre or), légendaire (1,5 %, cadre or qui scintille, pleine illustration) et mythique (0,3 %, pleine illustration, cadre arc-en-ciel). La dernière carte d'un booster rare est rare ou mieux (légendaire ou mythique environ une fois sur vingt) ; celle d'un booster légendaire est légendaire ou mieux une fois sur deux. À partir de rare, toute la carte est holographique (reflets arc-en-ciel et paillettes, plus forts avec la rareté), et le reflet bouge quand on incline le téléphone, ou sous la souris.

**Extension Saison 2** : 80 cartes de plus, numérotées à part (S01/S80) et hors des 99 de l'album, dans les mêmes boosters (environ une carte sur quatre) : **Matrice** (l'arène, le programme corrompu, le pare-feu, la pluie de code, le Virus, le Virus déchaîné), **Anime S2** (les épisodes 11 à 20), **Combat** (un contre un, uppercut, coup de pied sauté, garde, supers Clones et Arrêt du temps, le Titan d'arcade) **Boutique** (les 6 danses, l'Annihilateur, le Pistolet d'or), **Noël** (6 cartes, seulement pendant l'événement) **Passe S2** (les skins, danses, vaisseau et héros du passe saison 2, et le skin Platine des succès), **Portail** (la Planète de cristal, les Ruines stellaires, la sentinelle, le pillard, le Gardien, le Portail) **Anime S3** (les épisodes 21 à 30) **Compagnons** (les 17 animaux de compagnie) et **Accessoires** (les 12 accessoires des animaux). Chaque série complète rapporte sa récompense ; elles se recyclent, se fabriquent et s'échangent comme les autres.

Les cartes arrivent en boosters (3 cartes, 5 pour un rare, 7 pour un légendaire), à ouvrir dans CARTES (accueil) : on déchire le haut du booster en glissant le doigt le long du pointillé (ou d'un simple toucher), les cartes en sortent en pile, face cachée, la plus rare en dessous. Un toucher retourne la carte du dessus, un autre la met de côté ; à la fin, toutes s'affichent côte à côte. Une carte légendaire ou mythique a droit à un spectacle : elle tremble et s'illumine, des colonnes de lumière montent derrière elle, puis flash, confettis et fanfare (deux fanfares différentes, la plus grande pour les mythiques). Les boosters s'obtiennent :
- un booster à chaque fin de partie (tous les modes), un deuxième au-delà de 8000 points ;
- un booster rare (sa troisième carte au moins rare) tous les 5 paliers du passe, et quand les trois défis du jour sont réussis ;
- à la boutique, onglet CARTES : booster 400 crédits ou 30 gemmes, booster rare (5 cartes) 1200 crédits ou 90 gemmes, booster légendaire (7 cartes) 20 000 crédits ou 1500 gemmes (sa dernière carte est légendaire ou mieux une fois sur deux, sinon rare ou épique).

Les doublons se recyclent en poussière (5 à 500 selon la rareté), qui sert à fabriquer une carte manquante (40 à 4000). Une série complète rapporte des crédits et des gemmes (bouton RÉCUPÉRER), l'album entier le skin Collectionneur. Les illustrations sont dans `assets/cards/` : les modèles sont rendus par `tools/make_card_art.gd` (scène `scenes/tools/card_art.tscn`, à lancer avec un affichage), les arènes et les épisodes sont des images des vidéos.

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
| 25 | Le Virus (Matrice) | Disparaît dans un grésillement pour réapparaître près de toi, et se copie une fois blessé |
| 30 | Le Gardien (Planète de cristal) | Un magicien de cristal géant, couronné d'éclats. Il chante : une couronne d'éclats part tout autour de lui, de plus en plus souvent ; à partir de sa deuxième phase des cristaux jaillissent sous tes pieds (un cercle au sol les annonce), puis des sentinelles viennent l'aider |
| 35 | Titan (boss final, dans la ville) | Robot géant en trois phases : tirs en éventail, bombardement, invocations, puis une onde de choc au sol à esquiver en sautant ou depuis une passerelle |

La toute première partie affiche quelques conseils, un à la fois : se déplacer, tirer, frapper au corps à corps, puis lancer l'ulti quand sa jauge est pleine. Chacun disparaît dès qu'il est fait, et ils ne reviennent plus ensuite.

Le héros saute bras écartés et genoux repliés, s'écrase un instant en atterrissant (avec un nuage de poussière, plus fort après une grande chute) et se penche en avant quand il court. Les personnages n'ayant pas ces animations, elles sont faites par code (`scripts/pose_layer.gd`, `scripts/dances.gd`), comme les six danses : Robot, Disco, Vague, Bras en l'air, Pas chassé et Fête. Six autres se vendent à la boutique (onglet DANSES, 1500 crédits ou 110 gemmes) : Loser (la main au front, la tête qui secoue), Tout doux (paumes vers le sol, balancement des hanches), Dab, Poulet, Moulinet et Toupie ; une danse achetée s'ajoute à la roue des danses. Ce sont des danses originales : aucune n'est la copie d'une danse d'un autre jeu.

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
| Matrice | à l'intérieur du code : un noyau surélevé (rampe et deux ponts de données depuis des plateformes latérales), des tours où tombe une pluie de code verte, des pare-feu rouges pour se couvrir, des blocs qui grésillent et sautent dans les airs. Son boss est le Virus (le Titan noir de l'anime saison 2) : il disparaît dans un grésillement pour réapparaître près de toi, et se copie (ennemis corrompus) une fois blessé. Musique : Digital Acid |
| Planète de cristal | une mesa au centre, deux plateaux rocheux reliés à elle par des ponts de pierre, des grappes de cristaux bleus et roses qui brillent (les petites servent de couvert), un bassin lumineux, des flèches de cristal géantes à l'horizon, des éclats qui flottent dans l'air. Son boss est le Gardien (anime saison 3). Musique : Crystal Cave |
| Ville | carrefour sous un pont routier, immeubles au toit accessible par un escalier extérieur, voitures, feux et lampadaires |
| Ruines stellaires | hors des Vagues (histoire, capture, combat) : une grande arche de portail surmontée d'une statue, une galerie en hauteur (deux salles et une terrasse reliées par des ponts), des colonnes debout, brisées ou tombées, des pierres gravées qui brillent d'or, des blocs qui flottent autour du portail. Musique : Galactic Temple |

Les boss apparaissent au sol, dans un espace dégagé. La CI vérifie que chaque étage de chaque arène est accessible à pied aux ennemis.

Chaque arène a ses ennemis :

| Arène | Ennemis | Arme |
|---|---|---|
| Station | Gardes | Pistolet |
| Désert | Assassins des sables | Pistolet-mitrailleur |
| Jungle | Gobelins | Couteau : ils foncent et frappent au contact |
| Volcan | Zombies (et des flaques de lave qui blessent) | Mains nues, au contact |
| Matrice | Programmes corrompus (lueur verte) | Laser |
| Planète de cristal | Sentinelles de cristal (lueur bleue) | Fusil d'assaut |
| Ville | Hommes en costume | Revolver |
| Ruines stellaires | Pillards stellaires | Fusil à pompe |

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

Chaque partie rapporte de l'XP (un dixième du score, divisé par deux si tu meurs). Le passe compte 77 paliers, permanents et gratuits : les 30 premiers coûtent de plus en plus cher, les 47 suivants (le reste des armes à feu, cinq lames, puis sept vaisseaux) 1000 XP chacun. Chaque palier débloque un personnage, une arme, une arme de corps à corps ou un skin d'arme. Le Soldat, le Blaster, le Couteau et le skin Standard sont disponibles dès le départ. L'ordre des récompenses est dans `scripts/battle_pass.gd`.

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

**Du jour** montre quatre offres, les mêmes pour tous les joueurs, renouvelées à minuit ; la première est à -30 %. **Héros**, **Armes**, **Skins** et **Vaisseaux** forment le catalogue permanent ; **Cartes** vend des boosters. **Gemmes** vend des packs de gemmes contre de l'argent réel (Android uniquement, voir « Paiements » plus bas).

Deux monnaies :
- les **crédits** se gagnent en jouant : un dixième du score à chaque partie (divisé par deux si tu meurs ou quittes) ;
- les **gemmes** s'achètent, et se gagnent aussi en petite quantité : 3 par boss vaincu, 10 quand les trois défis du jour sont réussis.

Chaque article se paie au choix en crédits ou en gemmes : personnage 6000 crédits ou 450 gemmes, arme 3500 ou 260, skin 2500 ou 180, vaisseau 8000 ou 600.

**Articles ULTRA** (en magenta dans la boutique) : nettement plus forts que tout le reste, et trois fois plus chers. En multijoueur, les héros, armes et vaisseaux ULTRA reviennent au niveau des autres, pour qu'un achat ne décide pas du match.

| Article ULTRA | Type | Ce qu'il a de plus |
|---|---|---|
| Le Directeur | héros | Arrêt du temps boosté ×3 |
| Commandant | héros | Frappe aérienne boostée ×3 |
| Annihilateur | arme | 12 dégâts, 5 tirs/s, explosion de 5 m, finition Plasma |
| Pistolet d'or | arme | 99 dégâts (un tir, un ennemi), transperce, finition Or |
| Foudre | skin | éclairs animés |
| Trou noir | skin | anneau de feu qui tourbillonne sur fond noir |
| Oméga, Faucheuse, Aurore | vaisseaux | voir « Course de vaisseaux » |

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

## Échanger des cartes

Sans serveur, par codes. Dans CARTES, touche une carte que tu possèdes, puis ENVOYER : la carte quitte ta collection et le jeu donne un code (`OC-XXXX-XXXX-XXXXX`) et le lien de sa page web (`site/carte.html#OC-…`), qui montre la carte en holographique. Celui qui tape le code dans CODE, sur l'accueil, reçoit la carte. Un code ne sert qu'une fois par appareil et jamais sur celui qui l'a créé ; il contient la carte, une partie aléatoire et un contrôle qui attrape les fautes de frappe (`scripts/trade.gd`). Limite assumée : sans serveur, un joueur qui lit le code source peut fabriquer de faux codes, et un même code peut servir sur plusieurs appareils. La page web lit le catalogue exporté par `scenes/tools/export_cards.tscn` (fait par la CI à chaque publication).

## Le Créateur

Le personnage du créateur du jeu, à tête de vache, et le plus puissant de tous : 300 PV, 30 % plus rapide, et l'ulti **Accès root** (×3) qui efface tous les ennemis, entame les boss d'un tiers et rend toute la vie. Il vient avec son arme à feu (**Code source** : 40 dégâts, 8 tirs/s, rayon qui transperce, chargeur 200), sa lame (**Ctrl+Alt+Suppr**, une épée longue : 99 dégâts, 4 m, large balayage), son skin **Matrice** (pluie de code verte, pour l'arme et la lame), son vaisseau **Mainframe** (vitesse 140 %, maniabilité 170 %, bouclier 10, tir ×3, capacité **Accès admin**), son animal, le **Capybara** (rareté Hacker, une mandarine sur la tête, bonus **Mode dieu** : tout ennemi ordinaire à moins de 10 m est éliminé, les boss à moins de 25 m perdent 1,5 % de leurs PV toutes les 0,5 s, la foudre frappe 3 ennemis pour 20 dégâts chaque seconde, rend 5 PV par seconde, dégâts reçus −90 %, +25 % de vitesse, +50 % d'ulti, d'XP, de crédits et de bonus, actif partout) et une série de cartes à part, **Hacker** (6 cartes de rareté Hacker, au-dessus de mythique : Le Créateur, Code source, Ctrl+Alt+Suppr, Matrice, Mainframe, Capybara, numérotées H01 à H06). Ceux qui avaient déjà le code reçoivent le Capybara et sa carte à l'ouverture du jeu. Elles ne sortent jamais d'un booster, ne se fabriquent pas et ne comptent pas dans les 99 de l'album ; le code les donne toutes. Il reste à pleine puissance partout, multijoueur compris. On ne l'obtient qu'avec un code secret (ni boutique, ni passe, ni code de test).

## Codes

Le bouton CODE de l'accueil ouvre un champ : un code valide donne des récompenses (gemmes, crédits, héros, armes et skins de la boutique, cartes, boosters, passe de combat). Chaque code ne sert qu'une fois par sauvegarde, sauf le code de test. Majuscules et espaces ne comptent pas.

Les codes ne sont pas écrits dans le dépôt (il est public) : `scripts/promo_codes.gd` ne garde que leur empreinte SHA-256, avec la récompense. Pour en ajouter un, calculer l'empreinte du code en majuscules sans espaces :

```bash
python3 -c "import hashlib; print(hashlib.sha256('MONCODE'.encode()).hexdigest())"
```

puis ajouter une ligne à `CODES` avec la récompense (`gems`, `credits`, `items`, `cards`, `boosters`, `pass_complete`). Le code reste valable tant que la ligne existe : la retirer le désactive à la prochaine version. Tout se passe sur le téléphone, sans serveur : un code partagé publiquement peut être utilisé par tout le monde, une fois chacun.

## Boutique du site (produits dérivés)

La page `site/boutique.html` (publiée sur https://overclock.randomlabs.dev/site/boutique.html) présente 7 articles : deux t-shirts, un sweat, une affiche, un mug, une planche d'autocollants et un tote bag. Le site ne vend rien lui-même : chaque bouton mène vers un service d'impression à la demande, qui gère paiement, fabrication et livraison. Tant qu'aucun lien n'est renseigné, les boutons affichent « Bientôt disponible ».

Pour ouvrir la boutique :

1. Créer un compte sur un service d'impression à la demande (Spreadshop, gratuit, livre en Europe ; Printful ou Redbubble marchent aussi).
2. Y créer les 7 produits avec les fichiers d'impression de `merch/` : `logo.png` (t-shirt bleu nuit), `escouade.png` (t-shirt blanc), `rivaux.png` (sweat), `affiche_titan.png` (affiche, 1600 × 2400), `bulle.png` (mug), `sticker_*.png` (autocollants), `flotte.png` (tote bag). Les PNG sont transparents ; `logo.svg` et `bulle.svg` sont vectoriels.
3. Coller l'adresse de chaque produit dans `site/boutique.json` (clé du produit) et celle de la boutique dans `shop_url`, puis pousser : le bouton devient « Acheter ».

Les images de la page (`site/img/merch/`) sont de simples aperçus, refaits par `python3 tools/make_merch_mockups.py`. Les fichiers d'impression sont rendus par la scène `scenes/tools/merch.tscn` (`tools/make_merch.gd`, même style que l'anime).

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
