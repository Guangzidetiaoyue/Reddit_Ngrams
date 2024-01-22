import _json
import matplotlib.pyplot as plt
import numpy as np

words = ['Apple', 'Orange', 'Banana', 'Grapes', 'Pineapple']
a = [23,45,56,78,32]
b = [15,32,45,60,25]

bar_width = 0.35
index = np.arange(len(a))

plt.barh(index,a,bar_width,label='A')
plt.barh(index+bar_width,b,bar_width,label='B')

plt.xlabel('Values')
plt.ylabel('Words')
plt.yticks(index+bar_width/2,words)
plt.legend()
plt.show()