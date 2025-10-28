#!/usr/bin/env python3
"""
Flask Web Application for DevOps CI/CD Pipeline
A simple web application that displays deployment information
"""

from flask import Flask, render_template_string, jsonify
from datetime import datetime
import socket
import os
import platform

app = Flask(__name__)

# HTML template
HTML_TEMPLATE = """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>DevOps CI/CD - Flask App</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            padding: 20px;
        }
        .container {
            max-width: 1000px;
            margin: 0 auto;
            background: white;
            border-radius: 20px;
            padding: 3rem;
            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
        }
        h1 {
            color: #667eea;
            text-align: center;
            margin-bottom: 2rem;
        }
        .badge {
            background: linear-gradient(135deg, #10b981 0%, #059669 100%);
            color: white;
            padding: 0.5rem 1.5rem;
            border-radius: 50px;
            display: inline-block;
            margin: 1rem 0;
        }
        .info-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 1.5rem;
            margin: 2rem 0;
        }
        .card {
            background: #f3f4f6;
            padding: 1.5rem;
            border-radius: 12px;
            border-left: 4px solid #667eea;
        }
        .card h3 {
            color: #667eea;
            margin-bottom: 1rem;
        }
        .card p {
            margin: 0.5rem 0;
            color: #4b5563;
        }
        .json-viewer {
            background: #1f2937;
            color: #10b981;
            padding: 1.5rem;
            border-radius: 8px;
            overflow-x: auto;
            font-family: 'Courier New', monospace;
            margin: 2rem 0;
        }
        .api-section {
            background: #ecfdf5;
            padding: 1.5rem;
            border-radius: 12px;
            margin: 2rem 0;
            border: 2px solid #10b981;
        }
        .api-section h3 {
            color: #059669;
            margin-bottom: 1rem;
        }
        .endpoint {
            background: white;
            padding: 0.8rem;
            margin: 0.5rem 0;
            border-radius: 6px;
            font-family: monospace;
            border-left: 3px solid #10b981;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🐍 Flask Application - DevOps CI/CD</h1>
        <div style="text-align: center;">
            <span class="badge">✓ Python Flask Running</span>
        </div>

        <div class="info-grid">
            <div class="card">
                <h3>🖥️ Server Information</h3>
                <p><strong>Hostname:</strong> {{ hostname }}</p>
                <p><strong>IP Address:</strong> {{ ip_address }}</p>
                <p><strong>Platform:</strong> {{ platform }}</p>
            </div>

            <div class="card">
                <h3>🐍 Python Environment</h3>
                <p><strong>Python Version:</strong> {{ python_version }}</p>
                <p><strong>Framework:</strong> Flask</p>
                <p><strong>Environment:</strong> {{ environment }}</p>
            </div>

            <div class="card">
                <h3>⏰ Deployment Time</h3>
                <p><strong>Current Time:</strong> {{ current_time }}</p>
                <p><strong>Timezone:</strong> UTC</p>
                <p><strong>Uptime:</strong> Active</p>
            </div>

            <div class="card">
                <h3>🔧 DevOps Tools</h3>
                <p><strong>IaC:</strong> Terraform</p>
                <p><strong>CI/CD:</strong> Jenkins</p>
                <p><strong>Cloud:</strong> Azure</p>
            </div>
        </div>

        <div class="api-section">
            <h3>📡 Available API Endpoints</h3>
            <div class="endpoint">GET / - This page (HTML)</div>
            <div class="endpoint">GET /api/info - Server information (JSON)</div>
            <div class="endpoint">GET /api/health - Health check endpoint</div>
            <div class="endpoint">GET /api/status - Deployment status (JSON)</div>
        </div>

        <div class="json-viewer" id="json-data">
            Click "Load JSON Data" to view server information
        </div>

        <div style="text-align: center; margin-top: 2rem;">
            <button onclick="loadJSON()" style="
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                color: white;
                border: none;
                padding: 1rem 2rem;
                border-radius: 8px;
                font-size: 1rem;
                cursor: pointer;
                box-shadow: 0 4px 15px rgba(102, 126, 234, 0.4);
            ">Load JSON Data</button>
        </div>
    </div>

    <script>
        async function loadJSON() {
            try {
                const response = await fetch('/api/info');
                const data = await response.json();
                document.getElementById('json-data').textContent = 
                    JSON.stringify(data, null, 2);
            } catch (error) {
                document.getElementById('json-data').textContent = 
                    'Error loading data: ' + error.message;
            }
        }
    </script>
</body>
</html>
"""


@app.route('/')
def index():
    """Main page displaying application information"""
    context = {
        'hostname': socket.gethostname(),
        'ip_address': socket.gethostbyname(socket.gethostname()),
        'platform': f"{platform.system()} {platform.release()}",
        'python_version': platform.python_version(),
        'environment': os.getenv('ENVIRONMENT', 'production'),
        'current_time': datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    }
    return render_template_string(HTML_TEMPLATE, **context)


@app.route('/api/info')
def api_info():
    """API endpoint returning server information in JSON format"""
    info = {
        'application': 'DevOps CI/CD Flask App',
        'version': '1.0.0',
        'server': {
            'hostname': socket.gethostname(),
            'ip_address': socket.gethostbyname(socket.gethostname()),
            'platform': platform.system(),
            'platform_release': platform.release(),
            'platform_version': platform.version(),
            'architecture': platform.machine(),
            'processor': platform.processor()
        },
        'python': {
            'version': platform.python_version(),
            'implementation': platform.python_implementation(),
            'compiler': platform.python_compiler()
        },
        'deployment': {
            'method': 'Terraform + Jenkins',
            'cloud_provider': 'Microsoft Azure',
            'environment': os.getenv('ENVIRONMENT', 'production'),
            'timestamp': datetime.now().isoformat()
        },
        'devops_tools': {
            'iac': 'Terraform',
            'cicd': 'Jenkins',
            'containerization': 'Docker',
            'cloud': 'Azure',
            'scm': 'Git/GitHub'
        }
    }
    return jsonify(info)


@app.route('/api/health')
def health_check():
    """Health check endpoint for monitoring"""
    return jsonify({
        'status': 'healthy',
        'timestamp': datetime.now().isoformat(),
        'uptime': 'active'
    }), 200


@app.route('/api/status')
def deployment_status():
    """Deployment status endpoint"""
    return jsonify({
        'deployment_status': 'successful',
        'application_status': 'running',
        'last_deployment': datetime.now().isoformat(),
        'deployed_by': 'Jenkins CI/CD Pipeline',
        'infrastructure': 'Azure + Terraform'
    })


@app.errorhandler(404)
def not_found(error):
    """Custom 404 error handler"""
    return jsonify({
        'error': 'Not Found',
        'message': 'The requested endpoint does not exist',
        'available_endpoints': [
            '/',
            '/api/info',
            '/api/health',
            '/api/status'
        ]
    }), 404


@app.errorhandler(500)
def internal_error(error):
    """Custom 500 error handler"""
    return jsonify({
        'error': 'Internal Server Error',
        'message': 'An error occurred while processing your request'
    }), 500


if __name__ == '__main__':
    # Get port from environment variable or use default
    port = int(os.getenv('PORT', 5000))
    
    # Run the application
    # For production, use a WSGI server like Gunicorn
    app.run(
        host='0.0.0.0',
        port=port,
        debug=os.getenv('FLASK_DEBUG', 'False').lower() == 'true'
    )