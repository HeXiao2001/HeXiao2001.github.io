// Microsoft Clarity Integration
// This script initializes Microsoft Clarity for behavior analytics

import Clarity from '@microsoft/clarity';

// Initialize Clarity with your project ID
const projectId = "u7szbkfie3";
Clarity.init(projectId);

// Optional: Set custom tags for better filtering
// Clarity.setTag("environment", "production");
// Clarity.setTag("theme", "fluid");

console.log('Microsoft Clarity initialized successfully');
