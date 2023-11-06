#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sun Nov  5 17:18:36 2023

@author: xlon0007
"""

import lightgbm as lgb
import numpy as np
import pandas as pd
import random
import matplotlib.pyplot as plt
import pickle
import math

if __name__ == "__main__":
    
    random.seed(0)
    np.random.seed(0)
    
    data = pd.read_csv("lgb.clean.csv")
    
    col_mapping = {}
    
    
    for col in data.columns:
        if (data[col].dtypes == "object"):
            data[col].fillna('', inplace=True)
            data[col] = data[col].astype("category")
            # unique values
            col_keys = np.unique(data[col])
            # values it take
            mapping = np.array([i for i in range(len(col_keys))])
            update_dict = dict(zip(col_keys, mapping))
            col_mapping[col] = update_dict
            data[col] = [ update_dict[v] for v in data[col]]
            
        
    
    lgb_params = {
        'objective': 'regression',
        'random_seed': 0,
        'bagging_freq': 1,
        'lambda_l2': 0.1,
        'num_iterations': 1200,
        'num_leaves': 128,
        'min_data_in_leaf': 100
    }
    
    
    
    X = data.iloc[:,data.columns != "value"]
    y = data["value"]
    y.astype("float")
    
    
    # run importance only once...
    # lgb_train = lgb.Dataset(X, y)
    # model = lgb.train(lgb_params, lgb_train)
    
    # lgb.plot_importance(model, importance_type="gain", figsize=(7,26), title="LightGBM Feature Importance (Gain)")
    # plt.show()
    
    
    # model selection: 9 attributes
    col_selected = ["Achievement", "yr3enr", "yr5enr", "yr7enr", "yr9enr", "indigenous_enrolments____", "language_background_other_than_", "income_expenditure_per_student", "full_time_equivalent_teaching_s"]
    X = X[col_selected]
    X.mean()
    
    lgb_train = lgb.Dataset(X, y)
    model = lgb.train(lgb_params, lgb_train)
    
    lgb.plot_importance(model, importance_type="gain", figsize=(7,26), title="LightGBM Feature Importance (Gain)")
    plt.show()
    
    pickle.dump(model, open('model.pkl', 'wb'))
    
    y_pred = model.predict(X)
    
    np.sqrt(((y_pred - y) ** 2).mean())
