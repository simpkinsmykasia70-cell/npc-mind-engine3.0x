# 🌍 ProGen Worlds — Procedural World Generator (Godot 4)

A powerful procedural open-world generator built in Godot 4.x using noise-based terrain, biome classification, and runtime asset placement.

---

## ✨ Features

- 🏔️ **Noise-Based Terrain** — FastNoiseLite height maps with multiple octaves
- 🌿 **Biome Classification** — Desert, Forest, Tundra, Ocean, Mountains based on height + moisture
- 🌲 **Runtime Asset Placement** — Trees, rocks, and props spawned procedurally
- 💧 **River Generation** — Flow simulation from high to low elevation
- 🗺️ **Minimap System** — Real-time minimap with biome color coding
- ♾️ **Infinite Chunk Loading** — Load/unload chunks as player moves

---

## 📁 Project Structure

```
progen-worlds/
├── scripts/
│   ├── world_generator.gd       # Main generation controller
│   ├── noise_terrain.gd         # Height map generation
│   ├── biome_classifier.gd      # Biome assignment logic
│   ├── chunk_manager.gd         # Infinite chunk streaming
│   └── asset_placer.gd          # Runtime prop placement
├── scenes/
│   ├── world.tscn
│   ├── chunk.tscn
│   └── player.tscn
├── assets/
├── project.godot
└── README.md
```

---

## 🚀 Quick Start

```bash
git clone https://github.com/simpkinsmykasia70-cell/progen-worlds.git
```

Open in **Godot 4.x** and run `world.tscn`

---

## 👩‍💻 Author

**Mykasia Simpkins** — [GitHub](https://github.com/simpkinsmykasia70-cell) | [LinkedIn](https://www.linkedin.com/in/mykasia-simpkins-3130373b1)

---

## 📜 License
MIT License
