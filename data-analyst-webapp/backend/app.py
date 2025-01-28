from flask import Flask, request, jsonify, send_from_directory
import pandas as pd
import os
import matplotlib.pyplot as plt
import seaborn as sns

app = Flask(__name__)
UPLOAD_FOLDER = 'uploads'
GRAPH_FOLDER = 'static/graphs'
os.makedirs(UPLOAD_FOLDER, exist_ok=True)
os.makedirs(GRAPH_FOLDER, exist_ok=True)

@app.route('/upload', methods=['POST'])
def upload_file():
    if 'file' not in request.files:
        return jsonify({'error': 'No file provided'}), 400
    file = request.files['file']
    file_path = os.path.join(UPLOAD_FOLDER, file.filename)
    file.save(file_path)

    try:
        if file.filename.endswith('.csv'):
            df = pd.read_csv(file_path)
        elif file.filename.endswith('.xlsx'):
            df = pd.read_excel(file_path)
        else:
            return jsonify({'error': 'Unsupported file format'}), 400

        summary = df.describe().to_dict()
        return jsonify({'summary': summary, 'columns': list(df.columns)})

    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/visualize', methods=['POST'])
def visualize_data():
    data = request.json
    column = data.get('column')
    file_path = os.path.join(UPLOAD_FOLDER, data.get('filename'))
    df = pd.read_csv(file_path)

    if column not in df.columns:
        return jsonify({'error': 'Invalid column name'}), 400

    plt.figure(figsize=(10, 6))
    sns.histplot(df[column], kde=True)
    graph_path = os.path.join(GRAPH_FOLDER, f"{column}_histogram.png")
    plt.savefig(graph_path)
    plt.close()
    return jsonify({'graph_url': f'/static/graphs/{column}_histogram.png'})

if __name__ == '__main__':
    app.run(debug=True)
