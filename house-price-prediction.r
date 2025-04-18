# Boston Housing Price Prediction Analysis
# Portfolio Project - Predictive Modeling & Data Visualization

# ----------------------------
# 1. Environment Setup
# ----------------------------
# Install & load packages
packages <- c("tidyverse", "caret", "randomForest", "corrplot", 
              "Metrics", "MASS", "ggpubr", "viridis")
installed <- packages %in% rownames(installed.packages())
if (any(!installed)) install.packages(packages[!installed])

suppressPackageStartupMessages({
  library(tidyverse)
  library(caret)
  library(randomForest)
  library(corrplot)
  library(Metrics)
  library(MASS)
  library(ggpubr)
  library(viridis)
})

# ----------------------------
# 2. Data Preparation
# ----------------------------
data <- MASS::Boston

# Convert to tibble for better printing
housing_data <- as_tibble(data) %>%
  rename(Neighborhood = zn,
         Industry = indus,
         River_Access = chas,
         NOX_Pollution = nox,
         Rooms = rm,
         Age = age,
         Distance = dis,
         Highways = rad,
         Tax = tax,
         Teacher_Ratio = ptratio,
         Black_Pop = black,
         Lower_Status = lstat,
         Home_Value = medv)

# ----------------------------
# 3. Exploratory Data Analysis
# ----------------------------
# Custom theme for visualizations
portfolio_theme <- theme_minimal() +
  theme(
    plot.title = element_text(face = "bold", size = 14, hjust = 0.5),
    plot.subtitle = element_text(hjust = 0.5, color = "grey40"),
    axis.title = element_text(face = "bold"),
    legend.position = "bottom"
  )

# Correlation matrix with significance
cor_matrix <- cor(housing_data)
png("images/correlation_matrix.png", width = 8, height = 6, units = "in", res = 300)
corrplot(cor_matrix, method = "color", type = "upper",
         tl.cex = 0.7, tl.col = "black",
         addCoef.col = "black", number.cex = 0.6,
         col = viridis(100),
         title = "Feature Correlation Matrix")
dev.off()

# Distribution of target variable
target_dist <- ggplot(housing_data, aes(x = Home_Value)) +
  geom_histogram(fill = "#2c7fb8", bins = 30, alpha = 0.8) +
  labs(title = "Distribution of Home Values",
       x = "Median Home Value ($1000s)", y = "Count") +
  portfolio_theme

ggsave("images/home_value_distribution.png", target_dist, width = 8, height = 6)

# ----------------------------
# 4. Model Development
# ----------------------------
set.seed(123)
train_index <- createDataPartition(housing_data$Home_Value, p = 0.8, list = FALSE)
train_data <- housing_data[train_index, ]
test_data <- housing_data[-train_index, ]

# Train Random Forest model
set.seed(123)
rf_model <- randomForest(
  Home_Value ~ .,
  data = train_data,
  ntree = 500,
  mtry = 4,
  importance = TRUE,
  do.trace = 100
)

# ----------------------------
# 5. Model Evaluation
# ----------------------------
# Generate predictions
predictions <- predict(rf_model, newdata = test_data)

# Create evaluation data frame
results <- tibble(
  Actual = test_data$Home_Value,
  Predicted = predictions
)

# Actual vs Predicted plot
avp_plot <- ggplot(results, aes(x = Actual, y = Predicted)) +
  geom_point(alpha = 0.6, color = "#2c7fb8") +
  geom_abline(slope = 1, intercept = 0, color = "#e34a33", linewidth = 1) +
  geom_smooth(method = "lm", color = "#2ca25f", se = FALSE) +
  labs(title = "Actual vs Predicted Home Values",
       subtitle = "Random Forest Regression Performance",
       x = "Actual Values ($1000s)", 
       y = "Predicted Values ($1000s)") +
  portfolio_theme +
  scale_x_continuous(labels = scales::dollar_format(prefix = "$")) +
  scale_y_continuous(labels = scales::dollar_format(prefix = "$"))

ggsave("images/actual_vs_predicted.png", avp_plot, width = 10, height = 8)

# Feature importance visualization
importance <- importance(rf_model)
var_importance <- data.frame(
  Feature = rownames(importance),
  Importance = importance[, "%IncMSE"]
) %>% arrange(desc(Importance))

var_plot <- ggplot(var_importance, aes(x = reorder(Feature, Importance), y = Importance)) +
  geom_col(fill = "#2c7fb8", alpha = 0.8) +
  coord_flip() +
  labs(title = "Feature Importance in Price Prediction",
       x = "", y = "% Increase in MSE When Excluded") +
  portfolio_theme +
  theme(panel.grid.major.y = element_blank())

ggsave("images/feature_importance.png", var_plot, width = 10, height = 6)

# ----------------------------
# 6. Performance Metrics
# ----------------------------
metrics <- list(
  RMSE = rmse(results$Actual, results$Predicted),
  MAE = mae(results$Actual, results$Predicted),
  R2 = R2(results$Predicted, results$Actual)
)

cat("Model Performance Metrics:\n",
    "📉 RMSE: ", round(metrics$RMSE, 2), "\n",
    "📊 MAE: ", round(metrics$MAE, 2), "\n",
    "🧠 R²: ", round(metrics$R2, 3), sep = "")

# ----------------------------
# 7. Diagnostic Plots
# ----------------------------
# Residual analysis
residual_plot <- ggplot(results, aes(x = Predicted, y = Actual - Predicted)) +
  geom_point(alpha = 0.6, color = "#2c7fb8") +
  geom_hline(yintercept = 0, color = "#e34a33", linewidth = 1) +
  labs(title = "Residual Analysis",
       x = "Predicted Values ($1000s)", 
       y = "Residuals") +
  portfolio_theme +
  scale_x_continuous(labels = scales::dollar_format(prefix = "$"))

ggsave("images/residual_analysis.png", residual_plot, width = 10, height = 8)