from PIL import Image
from os import mkdir, listdir

COLS = 16
ROWS = 1

split_input = "split_input"
split_output = "split_output"

for file_name in listdir(split_input):
    if not file_name.endswith('.png'): continue;
    file_name = file_name.replace(".png", "")
    sheet = Image.open("{}/{}.png".format(split_input, file_name))
    width = sheet.size[0] // COLS
    height = sheet.size[1] // ROWS
    for col in range(COLS):
        for row in range(ROWS):
            left = col * width
            right = left + width
            top = row * height
            bottom = top + height
            icon = sheet.crop((left, top, right, bottom))
            icon.save(split_output + '/{}-{}.png'.format(file_name, row * width + col))
