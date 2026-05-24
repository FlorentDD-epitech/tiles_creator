# 🎹 Piano Tiles — Godot 4

Un clone de Piano Tiles fait en Godot 4 avec système de vies, combo et auto-mapping par BPM.

---

## Structure du projet

```
res://
├── assets/
│   ├── bleu.png          # Texture de fond
│   └── noir.png          # Texture des tiles
├── scenes/
│   ├── menu.tscn
│   ├── choose.tscn
│   ├── record.tscn
│   ├── game_scene.tscn
│   └── tile.tscn
├── scripts/
│   ├── global_data.gd    # Autoload — données partagées entre scènes
│   ├── menu.gd
│   ├── choose.gd
│   ├── record.gd
│   ├── game_scene.gd
│   └── tile.gd
└── sounds_data/          # Dossier des JSON générés (musiques mappées)
```

---

## Prérequis

- **Godot 4.x**
- Résolution de projet configurée à **1152 × 648** (le layout UI est calé sur ces dimensions)
- `global_data.gd` enregistré comme **Autoload** sous le nom `GlobalData`

---

## Autoload

Dans *Projet → Paramètres du projet → Autoload*, ajouter :

| Nom | Chemin |
|---|---|
| `GlobalData` | `res://scripts/global_data.gd` |

---

## Scènes

### `menu.tscn`
Écran d'accueil. Contient :
- `PlayButton` — navigue vers `choose.tscn`
- `RecordButton` — ouvre un `FileDialog` pour sélectionner un fichier MP3
- `FileDialog` — filtre `.mp3`, stocke le chemin dans `GlobalData.selected_music` puis navigue vers `record.tscn`

### `choose.tscn`
Liste de sélection de musique. Scanne le dossier `res://sounds_data/` et affiche tous les fichiers `.json` disponibles. Double-clic sur une entrée → stocke le chemin JSON dans `GlobalData.selected_json` et lance `game_scene.tscn`.

### `record.tscn`
Écran de création d'une map. Deux modes au choix :

**Mode Auto-map (BPM)**
1. Cliquer sur *"🎵 Auto-map par BPM"*
2. Entrer le BPM de la musique (voir hints affichés à l'écran)
3. Cliquer *"Générer les notes ✓"*
4. Le script génère une note par beat, réparties sur les 4 lanes selon un pattern prédéfini, puis sauvegarde le JSON automatiquement

**Mode Manuel**
1. Cliquer sur *"🎹 Enregistrement manuel"*
2. Compte à rebours de 3 secondes, puis la musique démarre
3. Appuyer sur les touches pendant la lecture pour placer les notes :

| Touche | Lane |
|---|---|
| `&` (touche 1 AZERTY) | Lane 1 (gauche) |
| `2` | Lane 2 |
| `"` (touche 3 AZERTY) | Lane 3 |
| `'` (touche 4 AZERTY) | Lane 4 (droite) |

4. La musique se termine → le JSON est sauvegardé dans `res://sounds_data/`

> **Format du JSON sauvegardé :**
> ```json
> {
>   "background-texture": "res://assets/bleu.png",
>   "tile-texture": "res://assets/noir.png",
>   "music-path": "chemin/vers/musique.mp3",
>   "data": [
>     { "time": 0.46, "lane": 0 },
>     { "time": 0.93, "lane": 2 },
>     ...
>   ]
> }
> ```

### `game_scene.tscn`
Scène principale de jeu. Structure de la scène dans l'éditeur :

```
Control           ← racine, script game_scene.gd
├── TextureRect   ← fond
├── Node2D        ← parent des tiles (position.y = -324)
│   ├── Spawn1    ← Node2D, position.x = -300
│   ├── Spawn2    ← Node2D, position.x = -100
│   ├── Spawn3    ← Node2D, position.x =  100
│   └── Spawn4    ← Node2D, position.x =  300
├── Line2D        ← ligne noire de mort (points à y = 163)
└── AudioStreamPlayer
```

L'export `lane_nodes` doit être assigné dans l'Inspector avec les 4 Spawn dans l'ordre.

L'UI (cœurs, combo, game over) est **entièrement créée par code** dans `_build_ui()` — rien à ajouter dans l'éditeur.

### `tile.tscn`
Tile individuelle. Contient un `Button` (100 × 100 px) avec une `TextureRect`. Descend automatiquement vers le bas à chaque `_process`. Émet :
- `tile_hit` quand le joueur clique dessus
- `tile_missed` quand elle dépasse la ligne de mort

---

## Gameplay

Les tiles apparaissent en haut de l'écran et descendent vers la ligne noire. Le joueur doit cliquer dessus avant qu'elles atteignent la ligne.

### Système de vies
- 3 cœurs affichés en haut à droite
- Une tile qui dépasse la ligne → **-1 vie**, combo reset à 0
- 0 vie → la musique s'arrête, écran Game Over
- Game Over : boutons **Recommencer** (reload de la scène) et **Menu** (retour au menu)

### Système de combo
Chaque tile cliquée incrémente le compteur. Le compteur `xN` s'affiche en haut à gauche dès x2. Un label animé apparaît au centre selon le palier atteint :

| Combo | Message |
|---|---|
| x2 | COMBO! |
| x3 | NICE! |
| x5 | AWESOME! |
| x10 | ON FIRE!! 🔥 |
| x20 | LEGENDARY!! |

Rater une tile remet le combo à 0.

---

## Touches en jeu

| Touche | Action |
|---|---|
| Clic sur une tile | Valider la tile |
| `Échap` | Retour à l'écran de sélection |

---

## Paramètres ajustables

Dans `record.gd` :

| Constante | Valeur par défaut | Rôle |
|---|---|---|
| `MIN_BEAT_INTERVAL` | `0.15` | Intervalle minimum entre deux notes (secondes) — augmenter pour moins de notes |
| `AUTO_LANES` | `4` | Nombre de lanes |

Dans `game_scene.gd` :

| Constante | Valeur | Rôle |
|---|---|---|
| `TIME_TO_TRAVEL` | `4` | Secondes avant que la musique démarre (laisse le temps aux premières tiles de descendre) |

Dans `tile.gd` :

| Constante | Valeur | Rôle |
|---|---|---|
| `TILE_HALF_HEIGHT` | `50.0` | Demi-hauteur de la tile en pixels — ajuster si la taille du Button change |

---

## Ajouter une musique manuellement

Si tu veux créer un JSON à la main sans passer par l'écran Record, place-le dans `res://sounds_data/` avec ce format :

```json
{
  "background-texture": "res://assets/bleu.png",
  "tile-texture": "res://assets/noir.png",
  "music-path": "res://sounds_data/ma_musique.mp3",
  "data": [
    { "time": 1.0,  "lane": 0 },
    { "time": 1.5,  "lane": 2 },
    { "time": 2.0,  "lane": 1 }
  ]
}
```

`time` est en secondes depuis le début de la musique. `lane` est entre `0` et `3`.

---

## Notes techniques

- Le `Control` racine de `game_scene` est **ancré au centre** de l'écran. Son origine locale `(0, 0)` correspond au centre de la fenêtre. Le coin haut-gauche est à `(-576, -324)`.
- Les tiles sont enfants du `Node2D` (positionné à `y = -324`). Leur `position` est locale à ce Node2D. La comparaison de mort utilise `global_position` pour être indépendante du système de coordonnées parent.
- Les boutons du Game Over ont `process_mode = PROCESS_MODE_ALWAYS` pour rester cliquables même quand `get_tree().paused = true`.

---

## 🧾 Crédits

Projet réalisé dans le cadre d’un prototype / game jam.
Fait par :

Gabriel Decloquement | gabriel.decloquement@epitech.eu
Florent Dujardin--Duribreux | florent.dujardin-duribreux@epitech.eu
Clement Dujardin--Duribreux | clement.dujardin-duribreux@epitech.eu
Pierre Leclercq | pierre-leclercq@epitech.eu