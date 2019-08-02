import pandas as pd
#import numpy as np

data = pd.read_html("https://www.collegesimply.com/guides/application-deadlines/")
data = pd.DataFrame(data[0])

missing = data.isnull()

badrow = []
for i in range(missing.shape[0]):
    if missing.iloc[i,1] == True:
        badrow.append(i)

data.drop(data.index[badrow], inplace = True)

data.to_csv("College Application Deadline_clean.csv")


