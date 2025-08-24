# Livestock Health Monitoring & Vaccination Record Management System

A comprehensive blockchain-based system for tracking animal health, managing vaccination schedules, and ensuring meat quality safety using Clarity smart contracts.

## System Overview

This system provides a decentralized solution for livestock health management with the following core capabilities:

### Core Features

1. **Animal Registry** - Unique identification and registration of livestock
2. **Vaccination Management** - Schedule tracking and compliance monitoring
3. **Health Records** - Comprehensive health history and veterinary care tracking
4. **Disease Outbreak Detection** - Early warning system for disease containment
5. **Meat Quality Certification** - Safety assurance and quality verification

### Smart Contracts

- `animal-registry.clar` - Core animal identification and ownership management
- `vaccination-manager.clar` - Vaccination scheduling and compliance tracking
- `health-records.clar` - Medical history and veterinary care coordination
- `disease-tracker.clar` - Outbreak detection and containment protocols
- `meat-certification.clar` - Quality assurance and safety certification

## Architecture

The system uses five interconnected Clarity smart contracts that work together to provide comprehensive livestock management:

\`\`\`
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│ Animal Registry │────│ Vaccination Mgr  │────│ Health Records  │
└─────────────────┘    └──────────────────┘    └─────────────────┘
│                       │                       │
└───────────────────────┼───────────────────────┘
│
┌─────────────────┐    ┌┴─────────────────┐
│ Disease Tracker │────│ Meat Certification│
└─────────────────┘    └───────────────────┘
\`\`\`

## Data Models

### Animal
- ID: Unique identifier
- Owner: Principal address
- Species: Animal type
- Birth Date: Date of birth
- Registration Date: System entry date
- Status: Active/Inactive/Deceased

### Vaccination Record
- Animal ID: Reference to animal
- Vaccine Type: Type of vaccination
- Date Administered: Vaccination date
- Veterinarian: Administering vet
- Next Due Date: Scheduled next vaccination
- Batch Number: Vaccine batch tracking

### Health Record
- Animal ID: Reference to animal
- Date: Record date
- Condition: Health condition or treatment
- Veterinarian: Attending veterinarian
- Treatment: Applied treatment
- Notes: Additional observations

### Disease Alert
- Alert ID: Unique identifier
- Location: Geographic area
- Disease Type: Type of disease
- Severity Level: Risk assessment
- Date Reported: Alert creation date
- Status: Active/Contained/Resolved

### Meat Certificate
- Certificate ID: Unique identifier
- Animal ID: Source animal
- Inspection Date: Quality inspection date
- Inspector: Certifying authority
- Grade: Quality grade
- Expiry Date: Certificate validity

## Installation

1. Install Clarinet CLI
2. Clone this repository
3. Run `clarinet check` to validate contracts
4. Run `npm test` to execute test suite

## Usage

### Registering Animals
```clarity
(contract-call? .animal-registry register-animal "cattle" u20220101)
