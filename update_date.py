import datetime
import re

RE = re.compile("let year = ([0-9]{4})")
year = datetime.datetime.now().date().strftime("%Y")
print(f"Updating year to {year}")
lines = []
with open("pre.rhai", "r+") as f:
    for line in f.readlines():
        lines.append(re.sub("let year = [0-9]{4};", f"let year = {year};", line))
    f.seek(0)
    f.write("".join(lines))
    f.truncate()
