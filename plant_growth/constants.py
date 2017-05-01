from math import pi

NUM_INPUTS = 4
NUM_OUTPUTS = 2
MAX_CELLS = 2000
NUM_GENERATIONS = 100
SIMULATION_STEPS = 400

WORLD_WIDTH = 1000
WORLD_HEIGHT = 750
SOIL_HEIGHT = 350
LIGHT_ANGLE = pi / 4.0

SEED_SEGMENTS = 16
SEED_RADIUS = 20

PLANT_EFFICIENCY = .001

# 1.5 times the link start state
MAX_EDGE_LENGTH = 1.3 * (2*pi*SEED_RADIUS / SEED_SEGMENTS)