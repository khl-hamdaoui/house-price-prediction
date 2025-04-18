# 🏡 Boston Housing Price Prediction (Regression Model in R)

This project builds and evaluates a machine learning regression model to predict house prices using the **Boston Housing dataset**. The goal is to estimate the median home value (`medv`) based on various housing attributes.

---

## 📦 Dataset

- **Source**: `MASS::Boston`
- **Features**: 13 input variables (e.g., crime rate, number of rooms, tax rate)
- **Target**: `medv` – Median value of owner-occupied homes (in $1000s)

---

## ⚙️ Methods & Tools

- **Language**: R
- **Libraries**: `tidyverse`, `caret`, `data.table`, `ggplot2`, `corrplot`, `Metrics`
- **Model**: Multiple Linear Regression
- **Evaluation Metrics**:
  - 📉 **RMSE**: 3.07
  - 📊 **MAE**: 2.13
  - 🧠 **R²**: 0.906

---

## 📊 Visualizations

- Correlation heatmap
- Predicted vs Actual plot  
  *(saved as: `figures/actual_vs_predicted.png`)*

---

## 🚀 How to Run

1. Clone this repository:
   ```bash
   git clone https://github.com/YOUR_USERNAME/YOUR_REPO.git
   cd YOUR_REPO
