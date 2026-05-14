# student_assistant_app

CapsOn Student Assistant Application

## Overview
The Student Assistant Application is a mobile application developed using Flutter and Supabase. The system helps students manage their academic activities efficiently

## Objectives
The purpose of the system is to:
- Allow students to apply for Student Assistant positions
- Allow administrators to review applications
- Manage application approval and rejection
- Store application data securely using Supabase

## Features
- User Registration
- User Login
- Admin Dashboard 

## Technologies Used
- Flutter
- Supabase
- Provider State Management
- MVVM Architecture
- GitHub Version Control

### Student Portal
- View submitted applications
- Submit Student Assistant applications
- Edit applications while pending
- Delete applications with confirmation
- View application status

### Admin Portal
- View all applications
- Approve or reject applications
- Update application status
- Remove invalid applications
- Filter application data

## Project Structure
student_assistant_app
lib/
│
├── models
├── services
├── utils
├── viewmodels
├── views
├── widgets
└── main.dart

## MVVM Architecture
The application follows the MVVM (Model-View-ViewModel) architecture:
- Models store application data
- Views represent UI screens
- ViewModels manage business logic and state
- Provider is used for state management

## CRUD Operations
The application implements:
- Create → Submit applications
- Read → View applications
- Update → Edit applications
- Delete → Remove applications

## Validation and Form Handling
The system validates:
- Required fields
- Valid module selection
- Eligibility confirmation
- Maximum module limits

## Supabase Integration
Supabase is used for:
- Authentication
- Database storage
- File storage
- User data management

## Group Members
| Student number| Name & Surname|
|223020021| B Mbinga | 
|223040545| FB Amatebelle | 
|223038085| BF Motseki |
|223051025| LD Mokheti |
|223007530| A Jara |
|221034577| ML Mwenda |
|222033434| KD Tsolo |
|224020157| KP Molelekeng |
|223005893| TV Thabisi |

## Installation Instructions
1. Open the project in VS Code
2. Install dependencies

```bash
flutter pub get
```
3. Run the project

```bash
flutter run
```

## GitHub Collaboration
The project was developed collaboratively using GitHub for version control. Each member contributed through commits, feature development, and documentation updates.

## Conclusion
The Student Assistant Application System provides a secure and structured platform for managing Student Assistant applications within the Information Technology Department.