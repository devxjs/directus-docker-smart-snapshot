# Automated Directus Setup with Docker and Schema Versioning

The purpose of this project is to provide an automated installation system for Directus with preconfigured Docker settings. It facilitates automatic migration through the generation and application of translated database schema snapshots. These snapshots can be versioned, streamlining teamwork and project versioning processes.

Follow the steps below in the src/ folder to configure and run the project locally.

## Prerequisites

Make sure you have Node.js and npm (Node Package Manager) installed on your system. It's recommended to use "nvm" to manage Node.js versions.

## Configuration

1. Configure the `.env.local` file based on the `.env.example` file. This file will contain the environment variables necessary for project configuration. Be sure to include all required values before starting the installation.

## Installation

Before installing the project, please ensure the `.env.local` file is properly configured.

To install the project, enable execution permissions for the installation script (`install.sh`) by running:

```bash
chmod +x ./install.sh
```

Then launch the script using the following command (the script requires sudo password to grant necessary permissions to the uploads, extensions, and snapshots folders):

```bash
./install.sh "<your_sudo_password>"
```

## Running the Project

After the installation script has been executed, you can launch the project by running the `start.sh` script:

```bash
./start.sh
```

## Database Versioning (Before Push)

When making changes in Directus BO that will affect the database structure, remember to update the snapshots with the command:

```bash
npm run schema:update
```

## Database Versioning (After Pull)

Before starting work after a pull request, make sure to verify that your database schema is up to date. It's preferable to update it before you start working to avoid unnecessary conflicts. To apply the latest database update, simply run the command:

```bash
npm run schema:apply
```