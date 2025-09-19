# How to leverage Graph API
This guide walks you though the complete process of how to properly setup resources that allow for proper use of various Graph API use cases. 

This guide walks you through the complete process of setting up Microsoft Teams meeting creation via API where you can specify any user in your tenant as the meeting organizer, enabling them to create breakout rooms.

## 🎯 What This Solves
**The Problem:** When using the Graph API depending on the endpoints being used, various types of permissions and polices may be required. The goal of this repo is to walk you through those steps and then verify that everything is working using `Bruno`.

**The Solution:** By showing you how to properly create the application registeration in Azure, along with the proper permissions and an Application Access Policy it will allow you make proper use of the API, as opposed to spending hours trying to figure out what is needed.

## 📋 Prerequisites

Before starting, ensure you have:

- **Microsoft 365 Tenant** with Teams enabled
- **Global Administrator** or **Teams Administrator** role
- **Application development** permissions in Azure AD
- **PowerShell execution** permissions
- **HTTP testing tool** (Bruno, Postman, etc.)

## 🥇 Use of Graph API to create a Teams Meeting
For this first example, I have provided all the details that will allow you to create **meetings** that allow for for multiple organizers, co-organizers and external particapants.  The important item to note here is that you **must** use `Application Permissions` not `Delegated Permissions` and you must have a Teams Policy in-place that specifies who can create meetings.  

## 🎯 **Important* 🎯
You cannot use `https://graph.microsoft.com/v1.0/me/onlineMeetings` to create meetings for others!  When this endpoint is used, it will **always** create the meeting using the identity of the user that the credential belongs to.  If the **goal** is to create meetings for anyone that has the proper Application permissions, in this case (Teams permissions), then you need to leveage the `https://graph.microsoft.com/v1.0/me/onlineMeetings` endpoint.

### Initial State (Meeting Start)
#### Only the meeting organizer can:
- Create the first breakout rooms
- Assign the first breakout room managers
- Set up the initial breakout room structure

#### After Initial Setup
Once the organizer delegates permissions, then:

- Co-organizers can create breakout rooms and assign additional managers
- Existing breakout room managers can assign additional managers

#### Key Points About "Initially"
Co-organizers can manage breakout rooms only during the live meeting. They cannot pre-create rooms or pre-assign participants before the meeting starts.

## Let's dive into the Teams Meeting scenario
1. Click 👉 [here](./teams/readme.md) for instructions on how to create the Application Registration, Teams Policy in Azure.
2. Install Bruno and leverage the Graph collection to verify that everything is working properly.  Click [here](./collections/readme.md) for details on installing Bruno and using the collection.




