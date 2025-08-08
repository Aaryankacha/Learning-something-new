import pandas as pd
s=pd.DataFrame({'name':['aryan','rohan','harsh'],'marks':[45,67,34]})
print(s)
df=pd.read_csv("D:/Practical/py-libraries-practice/pandas/annual-enterprise-survey-2023-financial-year-provisional.csv")
print(df.rename(columns={'Year':'yr'}))
