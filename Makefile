# customer complaint analysis
# author: Ty Andrews, Dhruvi Nishar, Luke Yang
# date: 2022-11-30

all: reports/final_report.html 

# download data
data/raw/complaints.csv: src/data/get_dataset.py
	python src/data/get_dataset.py --url=https://files.consumerfinance.gov/ccdb/complaints.csv.zip

# pre-process data (e.g., scale and split into train & test)
data/processed/preprocessed-complaints.csv : src/data/load_preprocess_data.py data/raw/complaints.csv
	python src/data/load_preprocess_data.py --raw_path="data/raw/complaints.csv" --output_path="data/processed/preprocessed-complaints.csv" 

# exploratory data analysis - visualize predictor distributions across classes
reports/assets/disputed_bar.png reports/assets/complaints_over_time_line.png: src/data/generate_eda.py data/processed/preprocessed-complaints.csv
	python src/data/generate_eda.py --train=data/processed/preprocessed-complaints.csv --out_dir=reports/assets

# perform analysis 
reports/assets/results.csv reports/assets/model_performance.png: src/analysis/analysis.py data/processed/preprocessed-complaints.csv
	python src/analysis/analysis.py --data_filepath=data/processed/preprocessed-complaints.csv --out_filepath=reports/assets

# render report 
reports/final_report.html: reports/final_report.qmd reports/assets/disputed_bar.png reports/assets/complaints_over_time_line.png reports/assets/results.csv reports/assets/model_performance.png 
	quarto render reports/final_report.qmd --to html -P output_dir="reports"

clean: 
	rm -f data/raw/complaints.csv
	rm -f data/processed/preprocessed-complaints.csv
	rm -f reports/assets/*.aux
	rm -f reports/assets/*.html
	rm -f reports/assets/*.pdf
	rm -f reports/assets/*.tex
	rm -f reports/assets/*.toc
	rm -f reports/assets/*_files
	rm -f reports/assets/*.png
	rm -f reports/assets/*.csv
	rm -f reports/assets/tables/*.csv
	rm -r reports/*_files