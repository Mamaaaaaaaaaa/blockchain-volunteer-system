# Volunteer Profile Management Smart Contract

## Overview
The **Volunteer Profile Management Contract** is a smart contract designed to manage volunteer profiles on the blockchain. It allows volunteers to register, update, and retrieve their profiles. The contract supports managing details like the volunteer's name, location, skills, and hours available. It provides a robust error handling mechanism to manage common issues like missing or invalid data, duplicate profiles, and non-existent profiles.

### Features:
- Register new volunteer profiles.
- Update existing volunteer profiles.
- Retrieve volunteer profiles and their associated skills.
- Validate input data to ensure correct and complete profiles.
- Handle errors for missing profiles, invalid input, and duplicates.

## Contract Constants

The contract defines several constants for error handling to ensure smooth interactions with the blockchain:

- **ERR-NOT-FOUND** (err u404): Volunteer profile not found.
- **ERR-ALREADY-EXISTS** (err u409): Volunteer profile already exists.
- **ERR-INVALID-SKILLS** (err u403): Invalid skills input.
- **ERR-INVALID-HOURS** (err u400): Invalid number of hours.

## Data Structures

The contract utilizes a map to store volunteer profiles, with the following attributes:

- **name**: The name of the volunteer (string, up to 100 characters).
- **location**: The volunteer's location (string, up to 100 characters).
- **skills**: A list of skills (up to 10 skills, each up to 50 characters).
- **hours-available**: The number of hours the volunteer is available (uint).

## Public Functions

### Register a New Volunteer
- **Function**: `register-volunteer`
- **Parameters**:
  - `name`: Volunteer’s name (string).
  - `location`: Volunteer’s location (string).
  - `skills`: A list of skills (up to 10 skills, each up to 50 characters).
  - `hours-available`: Number of hours available (uint).
- **Description**: Registers a new volunteer profile if it doesn’t already exist.
- **Error Handling**: 
  - Returns `ERR-ALREADY-EXISTS` if the profile already exists.
  - Returns `ERR-INVALID-HOURS` if invalid data is provided (e.g., no skills, invalid hours).

### Update Volunteer Profile
- **Function**: `update-volunteer`
- **Parameters**:
  - `name`: Volunteer’s name (string).
  - `location`: Volunteer’s location (string).
  - `skills`: A list of skills (up to 10 skills, each up to 50 characters).
  - `hours-available`: Number of hours available (uint).
- **Description**: Updates the profile of an existing volunteer.
- **Error Handling**: 
  - Returns `ERR-NOT-FOUND` if the volunteer doesn’t exist.
  - Returns `ERR-INVALID-HOURS` if invalid data is provided.

## Read-Only Functions

These functions provide read access to a volunteer's profile information:

### Get Volunteer Profile
- **Function**: `get-volunteer-profile`
- **Parameters**: `user` (principal).
- **Returns**: The full volunteer profile (name, location, skills, hours-available) or an error (`ERR-NOT-FOUND`).

### Get Volunteer Skills
- **Function**: `get-volunteer-skills`
- **Parameters**: `user` (principal).
- **Returns**: List of skills of the volunteer or an error (`ERR-NOT-FOUND`).

### Get Volunteer Available Hours
- **Function**: `get-volunteer-hours`
- **Parameters**: `user` (principal).
- **Returns**: Number of hours the volunteer is available or an error (`ERR-NOT-FOUND`).

### Get Volunteer Location
- **Function**: `get-volunteer-location`
- **Parameters**: `user` (principal).
- **Returns**: The location of the volunteer or an error (`ERR-NOT-FOUND`).

### Check Volunteer Registration Status
- **Function**: `is-volunteer-registered`
- **Parameters**: `user` (principal).
- **Returns**: `true` if the volunteer is registered, `false` otherwise.

### Get Volunteer Summary
- **Function**: `get-volunteer-summary`
- **Parameters**: `user` (principal).
- **Returns**: A summary of the volunteer's profile (name, location, and number of skills) or an error (`ERR-NOT-FOUND`).

## Error Codes

### ERR-NOT-FOUND (err u404)
Indicates that the volunteer profile does not exist.

### ERR-ALREADY-EXISTS (err u409)
Indicates that a volunteer profile with the given principal already exists.

### ERR-INVALID-SKILLS (err u403)
Indicates that the skills provided for the volunteer are invalid or empty.

### ERR-INVALID-HOURS (err u400)
Indicates that the number of hours provided is invalid (e.g., less than 1 hour).

## Installation

### Prerequisites
- **Clarinet**: Make sure you have Clarinet set up to compile and test smart contracts.

### Compile the Contract
Run the following command in the terminal:

```bash
clarinet compile
```

This will compile the smart contract and prepare it for deployment.

### Deploy the Contract
After compiling the contract, you can deploy it to the blockchain with:

```bash
clarinet deploy
```

Make sure you have a working Clarinet setup and have the required test environment set up.

## Example Usage

### Register a New Volunteer
To register a volunteer, you can call the `register-volunteer` function with the following parameters:

```bash
clarinet call <contract-address> register-volunteer \
    --arguments "John Doe" "New York" '["JavaScript", "Python"]' 5
```

### Update an Existing Volunteer Profile
To update the volunteer profile, use the `update-volunteer` function:

```bash
clarinet call <contract-address> update-volunteer \
    --arguments "John Doe" "Los Angeles" '["JavaScript", "Python", "React"]' 10
```

### Get Volunteer Profile Summary
To get a summary of a volunteer's profile:

```bash
clarinet call <contract-address> get-volunteer-summary \
    --arguments "<user-principal>"
```

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
```

This README provides a clear structure with:
- **Overview** of the contract's purpose.
- **Data structures** and **functions**.
- **Error handling** details.
- **Installation and usage** instructions, including command-line examples for interacting with the smart contract.
