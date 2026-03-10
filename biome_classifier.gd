extends Node
class_name BiomeClassifier

## Biome Classification System
## Author: Mykasia Simpkins

enum Biome {
	OCEAN,
	BEACH,
	DESERT,
	GRASSLAND,
	FOREST,
	RAINFOREST,
	TUNDRA,
	MOUNTAIN,
	SNOW_PEAK
}

const BIOME_COLORS = {
	Biome.OCEAN:       Color(0.1, 0.3, 0.7),
	Biome.BEACH:       Color(0.9, 0.85, 0.6),
	Biome.DESERT:      Color(0.9, 0.75, 0.3),
	Biome.GRASSLAND:   Color(0.5, 0.8, 0.3),
	Biome.FOREST:      Color(0.2, 0.55, 0.2),
	Biome.RAINFOREST:  Color(0.1, 0.4, 0.1),
	Biome.TUNDRA:      Color(0.7, 0.8, 0.75),
	Biome.MOUNTAIN:    Color(0.5, 0.45, 0.4),
	Biome.SNOW_PEAK:   Color(0.95, 0.95, 1.0)
}

var _moisture_noise: FastNoiseLite

func initialize(noise_seed: int) -> void:
	_moisture_noise = FastNoiseLite.new()
	_moisture_noise.seed = noise_seed
	_moisture_noise.frequency = 0.003

func classify(height_map: Array, moisture_map: Array, size: int) -> Array:
	var biome_map = []
	for i in range(size * size):
		var h = height_map[i]
		var m = moisture_map[i]
		biome_map.append(_get_biome(h, m))
	return biome_map

func _get_biome(height: float, moisture: float) -> Biome:
	if height < 0.2:   return Biome.OCEAN
	if height < 0.25:  return Biome.BEACH
	if height > 0.85:  return Biome.SNOW_PEAK
	if height > 0.7:   return Biome.MOUNTAIN
	if height > 0.6:   return Biome.TUNDRA if moisture < 0.3 else Biome.FOREST
	if moisture < 0.2: return Biome.DESERT
	if moisture < 0.5: return Biome.GRASSLAND
	if moisture < 0.75:return Biome.FOREST
	return Biome.RAINFOREST

func get_biome_color(biome: Biome) -> Color:
	return BIOME_COLORS.get(biome, Color.WHITE)
