# Tiles Creator — Piano Tiles

Petit projet Godot pour jouer/synchroniser des tuiles avec une musique (type "piano tiles").

**But**
- Charger une musique, afficher des tuiles/clés, et cliquer/activer les tuiles au bon moment.
- Interface avec menu, choix de morceau, scène de jeu et écran d'enregistrement.

**Exécuter le projet**
- Ouvrir le projet dans l'éditeur Godot en chargeant [project.godot](project.godot).
- Lancer la scène principale via l'éditeur (`scenes/menu.tscn`).

**Arborescence et rôle des fichiers**
- **Projet**: [project.godot](project.godot)
- **Scènes**:
  - [scenes/menu.tscn](scenes/menu.tscn) — menu principal
  - [scenes/choose.tscn](scenes/choose.tscn) — sélection de morceau/tuiles
  - [scenes/game_scene.tscn](scenes/game_scene.tscn) — scène de jeu principale
  - [scenes/tile.tscn](scenes/tile.tscn) — prefab/scene d'une tuile
  - [scenes/record.tscn](scenes/record.tscn) — écran d'enregistrement/résultats
- **Scripts (GDScript)** (logique de jeu)
  - [scripts/game_scene.gd](scripts/game_scene.gd) — logique de la partie
  - [scripts/tile.gd](scripts/tile.gd) — comportement d'une tuile
  - [scripts/global_data.gd](scripts/global_data.gd) — état global/variables partagées
  - [scripts/menu.gd](scripts/menu.gd), [scripts/choose.gd](scripts/choose.gd), [scripts/record.gd](scripts/record.gd)
- **Assets / Sons**:
  - `assets/` — images importées
  - `musiques/` — fichiers audio importés
  - `sounds_data/M2LT.json` — métadonnées JSON pour un morceau

**Fonctionnalités attendues**
- Charger un fichier audio et sa timeline de tuiles.
- Afficher les tuiles qui descendent/arrivent et détecter les clics ou pressions.
- Gestion du score, feedback visuel et écran d'enregistrement.

**Développement & contributions**
- Ouvrir le projet dans Godot et éditer les scènes/scripts listés ci-dessus.
- Pour ajouter un morceau, déposer l'audio dans `musiques/` et ajouter ses métadonnées dans `sounds_data/`.
---
