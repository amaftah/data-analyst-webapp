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
