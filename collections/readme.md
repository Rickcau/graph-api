# Bruno Collections
In this folder you will find Bruno Collections that are setup to allow you to test various interactions with the Graph API.

## Download and Install Bruno
Download Bruno
Official Website: https://www.usebruno.com/

## Graph Collection
The Graph collection is a collection of various Graph endpoints that can be used to created meetings.  

### Using Bruno Collections
1. Open in Bruno
- Launch Bruno
- Click "Open Collection"
- Navigate to the folder container the .bru files
- Select the collection folder

## Collection Structure
Bruno collections are organized as folders containing .bru files:
```
collections/
├── Graph/                  # User-related endpoints
│   ├── environments/       # Environment variables
│   ├── bruno.json          # Collection configuration
│   ├── Meeting Creation 3.bru
│   ├── Test Authentication.bru
│   ├── Test Grpah Authentication.bru
└── README.md               # Documentation
```

## Running Requests
1. **Select Environment**
- Click the environment dropdown (top-right)
- Choose the appropriate environment (local, staging, production, Graph)

2. **Execute Requests**
- Navigate to any `.bru` file in the collection
- Click the "**Send**" button
- Review the response in the response panel

3. **View Request Details**
- **Headers**: Check request/response headers
- **Body**: View request payload and response data

## Environment Variables
Bruno uses environment-specific variables for different deployment stages:

- **Local Environment**: http://localhost:3000
- **Staging Environment**: https://staging-api.example.com
- **Production Environment**: https://api.example.com

Variables are referenced using double curly braces: `{{baseUrl}}/users`

## Authentication
Most API collections include authentication setup:

1. **Run Authentication Request**
- Navigate to the auth folder**
- Execute the login request
- Copy the authentication token from the response

2. **Set Auth Token**
- Go to Collection Settings
- Set the authorization header or use environment variables
- Token will be automatically included in subsequent requests

