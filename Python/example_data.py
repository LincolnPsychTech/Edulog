import math
import random
import pandas
import edulog as el

data = list()
for n in range(100):
    data.append({"GSR": abs(math.sin(n)*(1-random.random()**2)), "Pulse": 100-random.random()*40, "Time": n/5})
data = pandas.DataFrame(data)
data.Concern = False;

data = el.gsrsplit(data)
data = el.scr(data, 'median')