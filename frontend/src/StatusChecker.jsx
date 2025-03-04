import React, { useState, useEffect } from 'react';

const StatusChecker = () => {
    const [urls, setUrls] = useState('');
    const [services, setServices] = useState('');
    const [urlResults, setUrlResults] = useState([]);
    const [serviceResults, setServiceResults] = useState([]);
    const [isLoading, setIsLoading] = useState(false);
    const [activeTab, setActiveTab] = useState('urls');

    // Theme colors for styling
    const colors = {
        primary: '#6366F1',       // Indigo
        primaryLight: '#A5B4FC',  // Light Indigo
        success: '#10B981',       // Green
        danger: '#EF4444',        // Red
        warning: '#F59E0B',       // Amber
        background: '#F9FAFB',    // Light Gray
        textPrimary: '#1F2937',   // Dark Gray
        textSecondary: '#6B7280'  // Medium Gray
    };

    // Function to check URL status
    const checkUrlStatus = async (url) => {
        try {
            const response = await fetch(`http://localhost:5000/status/${url}`);
            const data = await response.json();
            return { url, status: data.code, ok: data.status };
        } catch (error) {
            return { url, status: 'Error', ok: false };
        }
    };

    // Function to check service status (IP:Port)
    const checkServiceStatus = async (service) => {
        const [ip, port] = service.split(':');
        try {
            // This is a placeholder as direct socket connection isn't possible in browser JS
            // In a real-world scenario, you would make an API call to a backend to check the service
            await new Promise((resolve) => setTimeout(resolve, 1000)); // Simulate delay
            const isAvailable = Math.random() > 0.2; // Simulate service availability
            return { service, available: isAvailable ? 'Online' : 'Offline' };
        } catch (error) {
            return { service, available: 'Error' };
        }
    };

    // Main function to process URLs and Services
    const handleCheck = async () => {
        setIsLoading(true);
        setUrlResults([]);
        setServiceResults([]);

        setTimeout(() => {
            handleCheck();
        }, 5000)

        const urlsArray = urls.split('\n').filter(url => url.trim() !== '');
        const servicesArray = services.split('\n').filter(service => service.trim() !== '');

        const urlPromises = urlsArray.map(url => checkUrlStatus(url));
        const servicePromises = servicesArray.map(service => checkServiceStatus(service));

        const allUrlResults = await Promise.all(urlPromises);
        const allServiceResults = await Promise.all(servicePromises);

        setUrlResults(allUrlResults);
        setServiceResults(allServiceResults);
        setIsLoading(false);
    };

    // useEffect hook to add a default state
    useEffect(() => {
        setUrls('https://www.example.com\nhttps://www.google.com');
        setServices('127.0.0.1:80\n127.0.0.1:3000');
    }, []);

    return (
        <div className="min-h-screen bg-gray-100 py-6">
            <div className="container mx-auto px-4">
                <h1 className="text-3xl font-semibold mb-6 text-center" style={{ color: colors.textPrimary }}>
                    Internal URL & Service Status Checker
                </h1>

                {/* Tabs */}
                <div className="mb-4">
                    <button
                        className={`py-2 px-4 rounded-l-md ${activeTab === 'urls' ? 'bg-blue-500 text-white' : 'bg-gray-300 text-gray-700'}`}
                        onClick={() => setActiveTab('urls')}
                    >
                        URLs
                    </button>
                    {/* <button
                        className={`py-2 px-4 rounded-r-md ${activeTab === 'services' ? 'bg-blue-500 text-white' : 'bg-gray-300 text-gray-700'}`}
                        onClick={() => setActiveTab('services')}
                    >
                        Services
                    </button> */}
                </div>

                {/* URL Input */}
                {activeTab === 'urls' && (
                    <div className="mb-4">
                        <h2 className="text-xl font-semibold mb-2" style={{ color: colors.textPrimary }}>
                            Enter URLs to Check:
                        </h2>
                        <textarea
                            placeholder="Enter URLs (one per line)"
                            value={urls}
                            onChange={(e) => setUrls(e.target.value)}
                            className="w-full rounded-md border p-3 h-32"
                        />
                    </div>
                )}

                {/* Services Input */}
                {activeTab === 'services' && (
                    <div className="mb-4">
                        <h2 className="text-xl font-semibold mb-2" style={{ color: colors.textPrimary }}>
                            Enter Services to Check (IP:Port):
                        </h2>
                        <textarea
                            placeholder="Enter Services (one per line)"
                            value={services}
                            onChange={(e) => setServices(e.target.value)}
                            className="w-full rounded-md border p-3 h-32"
                        />
                    </div>
                )}

                {/* Check Button */}
                <button
                    onClick={handleCheck}
                    disabled={isLoading}
                    className="w-full py-3 rounded-md text-white font-semibold transition-colors duration-200"
                    style={{ backgroundColor: colors.primary, ':hover': { backgroundColor: colors.primaryLight } }}
                >
                    {isLoading ? 'Checking...' : 'Check Status'}
                </button>

                {/* URL Results */}
                {urlResults.length > 0 && activeTab === 'urls' && (
                    <div className="mt-8">
                        <h2 className="text-xl font-semibold mb-2" style={{ color: colors.textPrimary }}>
                            URL Status Results:
                        </h2>
                        <table className="w-full">
                            <thead>
                                <tr>
                                    <th className="text-left">URL</th>
                                    <th className="text-left">Status Code</th>
                                    <th className="text-left">Status</th>
                                </tr>
                            </thead>
                            <tbody>
                                {urlResults.map((result, index) => (
                                    <tr key={index}>
                                        <td>{result.url}</td>
                                        <td>{result.status}</td>
                                        <td style={{ color: result.ok ? colors.success : colors.danger }}>
                                            {result.ok ? 'Online' : 'Offline'}
                                        </td>
                                    </tr>
                                ))}
                            </tbody>
                        </table>
                    </div>
                )}

                {/* Service Results */}
                {serviceResults.length > 0 && activeTab === 'services' && (
                    <div className="mt-8">
                        <h2 className="text-xl font-semibold mb-2" style={{ color: colors.textPrimary }}>
                            Service Status Results:
                        </h2>
                        <table className="w-full">
                            <thead>
                                <tr>
                                    <th className="text-left">Service (IP:Port)</th>
                                    <th className="text-left">Availability</th>
                                </tr>
                            </thead>
                            <tbody>
                                {serviceResults.map((result, index) => (
                                    <tr key={index}>
                                        <td>{result.service}</td>
                                        <td style={{ color: result.available === 'Online' ? colors.success : colors.danger }}>
                                            {result.available}
                                        </td>
                                    </tr>
                                ))}
                            </tbody>
                        </table>
                    </div>
                )}
            </div>
        </div>
    );
};

export default StatusChecker;