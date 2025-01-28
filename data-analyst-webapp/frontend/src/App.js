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
