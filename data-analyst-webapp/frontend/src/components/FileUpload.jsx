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
