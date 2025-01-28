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
