# -*- coding: utf-8 -*-
"""walmart_project.ipynb

Automatically generated by Colab.

Original file is located at
    https://colab.research.google.com/drive/1ijFvtnHz8OQQj9ZKhgWfBw4IFp8JqBo-

**Step 1 Data Exploration**
"""

#importing libraries

import pandas as pd

#mysql toolkit
import pymysql #this will work as adapter
from sqlalchemy import create_engine

#psql
import psycopg2

print('Pandas version:', pd.__version__)

df = pd.read_csv('Walmart.csv' ,encoding_errors='ignore')
df.shape

df.head()

df.describe().T

df.info()

#duplicate rows
df.duplicated().sum()

df.drop_duplicates(inplace=True)
df.duplicated().sum()

df.shape

#missing values
df.isna().sum()

#droppping all rows with missing records
df.dropna(inplace=True)

# verify
df.isnull().sum()

df.shape

df.dtypes

#df['unit_price'].astype(float)

df['unit_price'] = df['unit_price'].str.replace('$', '').astype(float)

df.head()

df.info()

df.columns

df['total'] = df['unit_price'] * df['quantity']
df.head()

"""***Fixing the column name to lower case***"""

df.columns

df.columns = df.columns.str.lower()
df.columns

"""***visulization***"""

import seaborn as sns
import matplotlib.pyplot as plt

sns.histplot(data = df, x = 'unit_price', bins = 30, kde = True )

plt.title('Unit Price Distribution')
plt.xlabel('Unit Price')
plt.ylabel('Frequency')
plt.show()

sns.histplot(data=df, x='payment_method', bins=10)

plt.title('Payment Method Distribution')
plt.xlabel('Payment Method')
plt.ylabel('Frequency')
plt.show()

sns.histplot(data = df, x = 'rating' , bins = 10, kde = True)

plt.title('Distribution of rating')
plt.xlabel('Rating')
plt.ylabel('Frequency')
plt.show()

fig, axes = plt.subplots(1, 2, figsize=(18, 9))  # Set up the subplots

# Bar chart for category counts
sns.countplot(data=df, x='category', ax=axes[0], palette='viridis')
axes[0].set_title('Category Counts')
axes[0].set_xticklabels(axes[0].get_xticklabels(), rotation=90)

# Pie chart for category distribution
category_counts = df['category'].value_counts()  # Get category counts
axes[1].pie(category_counts, labels=category_counts.index, autopct='%1.1f%%', startangle=140)
axes[1].set_title('Category Distribution')

# Display the plots
plt.tight_layout()
plt.show()

#category
plt.figure(figsize=(12,12))
sns.boxplot(data = df, x = 'category', y = 'unit_price')

scatters = sns.pairplot(df, hue='category', palette='viridis')
scatters

df.shape

df.to_csv('walmart_clean_data.csv', index=False)

help(df.to_sql)

help(create_engine)

#mysql connection
# "mysql+pymysql://user:password@localhost:3306/db_name"
engine_mysql = create_engine("mysql+pymysql://root:sunil#uk18@localhost:3306/wallmart_db")

try:
    engine_mysql
    print("Connection Successed to mysql")
except:
    print("Unable to connect")

# mysql
# host = localhost
# port = 3306
# user = root
# password = 'your_password'

df.to_sql(name='walmart', con=engine_mysql, if_exists='append', index=False)

df.shape

#psql connection
# "mysql+pymysql://user:password@localhost:3306/db_name"
engine_psql = create_engine("postgresql+psycopg2://postgres:sunil#uk18@localhost:5432/walmart_db")

try:
    engine_psql
    print("Connection Successed to PSQL")
except:
    print("Unable to connect")

df.to_sql(name='walmart', con=engine_psql, if_exists='replace', index=False)

df.to_csv('walmart_clean_data.csv', index=False)