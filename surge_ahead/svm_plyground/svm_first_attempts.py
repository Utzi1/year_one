"""
File: svm_first_attempts.py
Author: Me
Email: yourname@email.com
Github: https://github.com/yourname
Description: First attempts at using SVM for classification following a tutorial (https://developer.ibm.com/tutorials/awb-classifying-data-svm-algorithm-python/)
"""

#Load the required libraries
import pandas as pd
import numpy as np
import seaborn as sns
from sklearn.utils import resample
from sklearn.model_selection import train_test_split
from sklearn.svm import SVC
from sklearn.metrics import confusion_matrix
from sklearn.model_selection import GridSearchCV, StratifiedKFold
from sklearn.decomposition import PCA
import matplotlib.colors as colors
import matplotlib.pyplot as plt
# !pip3 install xlrd

# Load the dataset
df = pd.read_excel('https://archive.ics.uci.edu/ml/machine-learning-databases/00350/default%20of%20credit%20card%20clients.xls', header=1)

# To explore explore the dataset
print(df.head())
print(df.describe())

# and rename a spcific column:
df.rename({'default payment next month': 'DEFAULT'}, axis='columns', inplace=True)

# and check if dimensions hold invalid values
print(df["SEX"].unique())
print(df["EDUCATION"].unique())
print(df["MARRIAGE"].unique())
print(df["AGE"].unique())

# count of the missing data:
len(df.loc[(df["EDUCATION"] == 0) | (df["MARRIAGE"] == 0)])

# to filter out the missing data:
df_no_missing_data = df.loc[(df["EDUCATION"] != 0) & (df["MARRIAGE"] != 0)]

# now lets check wether the data is balanced or not:
ax = sns.countplot(x='DEFAULT', data=df_no_missing_data)

# add data labels:
ax.bar_label(ax.containers[0])

# add a plot title:
plt.title("Obserservations by Classification Type")

# and show the plot:
plt.show()

# now we need to balance the datra
from sklearn.utils import resample

# split data
df_no_default = df_no_missing_data.loc[(df_no_missing_data['DEFAULT']==0)]
df_default = df_no_missing_data.loc[(df_no_missing_data['DEFAULT']==1)]

# downsample the data set
df_no_default_downsampled = resample(df_no_default, replace=False, n_samples=1000, random_state=42 )
df_default_downsampled = resample(df_default, replace=False, n_samples=1000, random_state=42 )

#check ouput
len(df_no_default_downsampled)
len(df_default_downsampled)

# merge the data sets
df_downsample = pd.concat([df_no_default_downsampled, df_default_downsampled ])
len(df_downsample)

from sklearn.preprocessing import OneHotEncoder
# isolate independent variables
X = df_downsample.drop('DEFAULT', axis=1).copy()

ohe = OneHotEncoder(sparse_output=False, dtype="int")
ohe.fit(X[['SEX', 'EDUCATION', 'MARRIAGE', 'PAY_0', 'PAY_2', 'PAY_3', 'PAY_4', 'PAY_5', 'PAY_6']])
X_ohe_train = ohe.transform(X[['SEX', 'EDUCATION', 'MARRIAGE', 'PAY_0', 'PAY_2', 'PAY_3', 'PAY_4', 'PAY_5', 'PAY_6']])

X_ohe_train

transformed_ohe = pd.DataFrame(
    data=X_ohe_train,
    columns=ohe.get_feature_names_out(['SEX', 'EDUCATION', 'MARRIAGE', 'PAY_0', 'PAY_2', 'PAY_3', 'PAY_4', 'PAY_5', 'PAY_6']),
    index=X.index,
)
transformed_ohe.head()

# merge dataframes
X_encoded = pd.concat([X, transformed_ohe], axis=1)
X_encoded

from sklearn.preprocessing import scale
y = df_downsample['DEFAULT'].copy()
X_train, X_test, y_train, y_test = train_test_split(X_encoded, y, test_size=0.3, random_state=42)

#scale the data
X_train_scaled = scale(X_train)
X_test_scaled = scale(X_test)

# fit the model
from sklearn.metrics import confusion_matrix
from sklearn.metrics import ConfusionMatrixDisplay

clf_svm = SVC(random_state=42)
clf_svm.fit(X_train_scaled, y_train)

# to calculate the overall accuracy
y_pred = clf_svm.predict(X_test_scaled)
accuracy = clf_svm.score(X_test_scaled, y_test)
print(f"Accuracy: {accuracy}")

class_names = ['No Default', 'Default']
disp = ConfusionMatrixDisplay.from_estimator(
    clf_svm, X_test_scaled, y_test, display_labels=class_names, cmap=plt.cm.Blues
)
