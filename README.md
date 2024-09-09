# MappKitAppEnd

This project is an iOS application that allows users to search for two locations on a map, calculate the distance and estimated travel time between them, and receive notifications based on their planned travel schedule. Additionally, it integrates with the **Gemini API** to provide chatbot-based suggestions for places to visit, such as restaurants, cafes, and dessert shops.

## Features

- **Search for Two Locations**: 
  - The application has two search bars:
    1. The first search bar is used to enter or select the starting location.
    2. The second search bar is used to enter or select the destination.
  - The app calculates the distance between the two locations and draws a route on the map.
  
- **Distance and Time Calculation**: 
  - The app provides the distance in kilometers and the estimated travel time in minutes between the two locations.
  - The map displays the route between the two points for easy navigation.

- **Travel Time Notification**: 
  - Users can input the desired arrival time at their destination (e.g., 3:30 PM).
  - Based on the calculated travel time, the app schedules a notification to remind the user when they need to leave (e.g., if the travel time is 30 minutes, a notification will be sent at 3:00 PM).

- **Gemini API Chatbot Integration**: 
  - A chatbot feature is integrated using the **Gemini API**, which allows users to ask questions about nearby places in cities, such as "best restaurants in Izmir" or "dessert places in Izmir."
  - The chatbot provides real-time suggestions for locations like **restaurants**, **cafes**, **dessert shops**, and more.
  - Suggestions are displayed on the map and can be pinned for further exploration.

## Technologies Used

- **Swift**: The primary programming language used for the app.
- **UIKit**: For building the user interface.
- **MapKit**: For displaying maps, calculating distances, and drawing routes.
- **CoreLocation**: For fetching the user's location and calculating distances between places.
- **UserNotification**: For sending scheduled notifications to the user when it's time to leave for their destination.
- **Gemini API**: To provide chatbot-based suggestions for nearby places (restaurants, cafes, dessert shops, etc.).
- **SwiftUI**: Some parts of the user interface are built using SwiftUI for a modern and clean design.

## Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/Zeyneppsevgi/MappKitAppEnd.git
2. Set up the Gemini API:
   Obtain your Gemini API key and add it to the Config.swift file in the project.
   Open the project in Xcode and build it on your preferred iOS device or simulator.

## How to Use

- **Search for Locations**:
1. Enter the starting location in the first search bar and the destination in the second search bar.
2. Alternatively, you can select locations directly from the map.
- **View Route and Travel Time**:
1. The app will display the route on the map, along with the distance in kilometers and the estimated travel time in minutes.
- **Schedule Notifications**:
1. If you want to arrive at a specific time, input the desired arrival time.
2. The app will notify you when it's time to leave based on the calculated travel time.
- **Chatbot for Suggestions**:
1. Navigate to the chatbot screen to ask questions like "best restaurants in Izmir" or "dessert places in Izmir."
2. The chatbot will use Gemini API to suggest locations, and you can pin the suggested places on the map.
