# Overclock

Shooter sci-fi en 3D low-poly pour Android, en vue à la troisième personne. Tu affrontes des vagues de robots dans une arène. Fait avec [Godot](https://godotengine.org) 4.5.

## Tester sur ton téléphone

Chaque push sur `main` compile un APK et le publie dans la release **latest-debug** du dépôt public [overclock-builds](https://github.com/mariusortiz/overclock-builds). Aucune connexion n'est nécessaire :

https://github.com/mariusortiz/overclock-builds/releases/download/latest-debug/overclock-debug.apk

Ouvre ce lien sur le téléphone, puis installe l'APK. Il faut autoriser le navigateur à installer des applications inconnues. Les mises à jour s'installent par-dessus l'ancienne version, car elles sont toutes signées avec la même clé de debug.

Les APK des autres branches sont dans l'onglet **Actions**, en artefact de chaque build.

## Développer en local (optionnel)

1. Installe Godot 4.5.1 (la version standard, pas .NET).
2. Ouvre `project.godot`, puis lance le jeu avec F5.

## Structure

- `scenes/` : scènes Godot (`.tscn`)
- `scripts/` : code GDScript
- `ci/debug.keystore` : clé de debug publique (mot de passe `android`), utilisée uniquement pour les APK de test. La clé de release ne sera jamais commitée.
- `.github/workflows/android.yml` : compilation de l'APK

## Licence des assets

Voir `CREDITS.md` (à venir quand les premiers assets seront ajoutés).
