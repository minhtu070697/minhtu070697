import numpy as np
import matplotlib
import matplotlib.pyplot as plt

show_value = True
data = []
with open("noise_map.txt", "r") as file:
    for line in file:
        if line:
            row = [float(i) for i in line.split(",") if i not in ["", "\n"]]
            row.reverse()
            data.append(row)
terrain = np.array(data)
map_width = len(data)
map_height = len(data[0])
fig, ax = plt.subplots()
im = ax.imshow(terrain)

# # Loop over data dimensions and create text annotations.
if show_value:
    for i in range(map_width):
        for j in range(map_height):
            text = ax.text(j, i, terrain[i, j], ha="center", va="center", color="w")

ax.set_title("Terrain")
fig.tight_layout()
plt.show()
print(plt)
