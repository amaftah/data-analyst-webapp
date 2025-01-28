#!/bin/bash

# Root Project Folder
echo "Creating project directory..."
mkdir -p data-analyst-webapp
cd data-analyst-webapp

# Backend Setup
echo "Setting up backend..."
mkdir -p backend/static/graphs backend/uploads
cat <<EOF > backend/app.py
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
EOF

cat <<EOF > backend/requirements.txt
flask
pandas
matplotlib
seaborn
EOF

# Install Backend Dependencies
echo "Installing backend dependencies..."
cd backend
pip install -r requirements.txt
cd ..

# Frontend Setup
echo "Setting up frontend..."
mkdir -p frontend
cd frontend

# Force Create React App with React 18
npx create-react-app . --template default --use-npm --legacy-peer-deps

# Add Axios for API requests
npm install axios

# Add Custom Components
echo "Adding custom React components..."
mkdir -p src/components
cat <<EOF > src/App.js
import React, { useState } from 'react';
import FileUpload from './components/FileUpload';
import DataSummary from './components/DataSummary';
import Visualization from './components/Visualization';

function App() {
    const [file, setFile] = useState(null);
    const [dataSummary, setDataSummary] = useState(null);
    const [columns, setColumns] = useState([]);
    const [filename, setFilename] = useState('');

    return (
        <div>
            <h1>Data Analyst Solution WebApp</h1>
            <FileUpload
                setFile={setFile}
                setDataSummary={setDataSummary}
                setColumns={setColumns}
                setFilename={setFilename}
            />
            {dataSummary && <DataSummary summary={dataSummary} />}
            {columns.length > 0 && (
                <Visualization columns={columns} filename={filename} />
            )}
        </div>
    );
}

export default App;
EOF

cat <<EOF > src/components/FileUpload.jsx
import React from 'react';
import axios from 'axios';

function FileUpload({ setFile, setDataSummary, setColumns, setFilename }) {
    const handleUpload = async (e) => {
        const file = e.target.files[0];
        setFile(file);

        const formData = new FormData();
        formData.append('file', file);

        try {
            const response = await axios.post('http://localhost:5000/upload', formData);
            setDataSummary(response.data.summary);
            setColumns(response.data.columns);
            setFilename(file.name);
        } catch (error) {
            console.error('Error uploading file:', error);
        }
    };

    return (
        <div>
            <h2>Upload your Dataset</h2>
            <input type="file" onChange={handleUpload} />
        </div>
    );
}

export default FileUpload;
EOF

cat <<EOF > src/components/DataSummary.jsx
import React from 'react';

function DataSummary({ summary }) {
    return (
        <div>
            <h2>Data Summary</h2>
            <pre>{JSON.stringify(summary, null, 2)}</pre>
        </div>
    );
}

export default DataSummary;
EOF

cat <<EOF > src/components/Visualization.jsx
import React, { useState } from 'react';
import axios from 'axios';

function Visualization({ columns, filename }) {
    const [selectedColumn, setSelectedColumn] = useState('');
    const [graphUrl, setGraphUrl] = useState('');

    const handleVisualize = async () => {
        try {
            const response = await axios.post('http://localhost:5000/visualize', {
                column: selectedColumn,
                filename: filename,
            });
            setGraphUrl(response.data.graph_url);
        } catch (error) {
            console.error('Error generating visualization:', error);
        }
    };

    return (
        <div>
            <h2>Visualize Data</h2>
            <select onChange={(e) => setSelectedColumn(e.target.value)}>
                <option value="">Select Column</option>
                {columns.map((col) => (
                    <option key={col} value={col}>
                        {col}
                    </option>
                ))}
            </select>
            <button onClick={handleVisualize}>Visualize</button>
            {graphUrl && <img src={graphUrl} alt="Visualization" />}
        </div>
    );
}

export default Visualization;
EOF

# Final Message
echo "Setup complete!"
echo "To run the backend: cd data-analyst-webapp/backend && python app.py"
echo "To run the frontend: cd data-analyst-webapp/frontend && npm start"
