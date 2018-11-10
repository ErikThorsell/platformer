import os
import subprocess

#path = os.path.dirname(os.path.realpath(__file__))
#jpgs = path + "/*.jpg"
#absolute_filelist = glob.glob(jpgs)

filelist = os.listdir()

for f in filelist:
    if "png" in f:
        command = ["convert", f"{f}", "-resize", "32x32", f"32/{f}"]
        print(f"Converting {f}")
        subprocess.check_output(command)
