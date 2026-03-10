extends Node
class_name WorldGenerator

## ProGen Worlds - Main World Generator
## Author: Mykasia Simpkins
## GitHub: https://github.com/simpkinsmykasia70-cell

@export var chunk_size: int = 64
@export var render_distance: int = 3
@export var seed: int = 0

var noise_terrain: NoiseTerrain
var biome_classifier: BiomeClassifier
var chunk_manager: ChunkManager
var asset_placer: AssetPlacer

signal world_ready()
signal chunk_generated(chunk_pos: Vector2i)

func _ready() -> void:
	randomize()
	if seed == 0:
		seed = randi()
	
	noise_terrain = $NoiseTerrain
	biome_classifier = $BiomeClassifier
	chunk_manager = $ChunkManager
	asset_placer = $AssetPlacer
	
	noise_terrain.initialize(seed)
	biome_classifier.initialize(seed + 1)
	
	print("[WorldGenerator] Seed: ", seed)
	generate_initial_world()

func generate_initial_world() -> void:
	for x in range(-render_distance, render_distance + 1):
		for y in range(-render_distance, render_distance + 1):
			generate_chunk(Vector2i(x, y))
	world_ready.emit()

func generate_chunk(chunk_pos: Vector2i) -> void:
	var height_map = noise_terrain.generate_heightmap(chunk_pos, chunk_size)
	var moisture_map = noise_terrain.generate_moisturemap(chunk_pos, chunk_size)
	var biome_map = biome_classifier.classify(height_map, moisture_map, chunk_size)
	
	chunk_manager.spawn_chunk(chunk_pos, height_map, biome_map)
	asset_placer.populate_chunk(chunk_pos, height_map, biome_map)
	
	chunk_generated.emit(chunk_pos)

func update_for_player(player_pos: Vector3) -> void:
	var player_chunk = Vector2i(
		int(player_pos.x) / chunk_size,
		int(player_pos.z) / chunk_size
	)
	chunk_manager.update_loaded_chunks(player_chunk, render_distance)
