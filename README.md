# Evaluation Salesforce - Document Uploader LWC

A Lightning Web Component (LWC) for uploading and managing evaluation documents in Salesforce. This component allows users to upload documents for student evaluation, fetch evaluation details, and download reports in PDF or Excel format.

## Overview

This application integrates with the Trential evaluation system and provides a seamless interface within Salesforce to manage student evaluation documents. The component is designed to be placed on Student record detail pages.

---

## Prerequisites

- Salesforce Developer Org or Sandbox
- Salesforce CLI installed
- Node.js and npm installed

---

## Setup Instructions

### Step 1: Create a New Salesforce App

**What is a Salesforce App?**
A Salesforce App is a collection of tabs, objects, and other features that work together to provide functionality for your organization. Apps appear in the App Launcher and help organize your work.

**Instructions:**

1. Log in to your Salesforce org
2. Click the **Setup** gear icon (top right)
3. In Quick Find, search for **"App Manager"**
4. Click **"New Lightning App"**
5. Configure the app:
   - **App Name:** `Evaluation Manager`
   - **Developer Name:** `Evaluation_Manager` (auto-generated)
   - **Description:** `Manage student evaluations and document uploads`
6. Click **Next** through the following screens:
   - **App Options:** Keep default settings
   - **Utility Items:** Skip (or add as needed)
   - **Navigation Items:** We'll add tabs after creating the custom object
   - **User Profiles:** Select profiles that should access this app (e.g., System Administrator)
7. Click **Save & Finish**

---

### Step 2: Create a Custom Object

**What is a Custom Object?**
Custom Objects are database tables that store data specific to your organization. They function like standard Salesforce objects (like Account or Contact) but are created to meet your unique business needs. Each object can have custom fields, page layouts, and relationships.

**Instructions:**

1. In Setup, search for **"Object Manager"** in Quick Find
2. Click **"Create" → "Custom Object"**
3. Configure the object:
   - **Label:** `Student`
   - **Plural Label:** `Students`
   - **Object Name:** `Student` (API Name: `Student__c`)
   - **Record Name:** `Student Name` (Data Type: Text)
   - Check **"Allow Reports"**
   - Check **"Allow Activities"**
   - Check **"Track Field History"** (optional)
   - **Deployment Status:** `Deployed`
4. Click **Save**

**What are Custom Fields?**
Custom Fields store specific pieces of information on an object record. Each field has a data type (Text, Number, Date, etc.) that determines what kind of data it can store.

#### Create Student ID Field:

1. On the Student object detail page, click **"Fields & Relationships"**
2. Click **"New"**
3. Select **"Text"** as the data type → Click **Next**
4. Configure the field:
   - **Field Label:** `Student ID`
   - **Length:** `50`
   - **Field Name:** `Student_ID` (API Name: `Student_ID__c`)
   - Check **"Required"**
   - Check **"Unique"** and **"Case Insensitive"**
   - Check **"External ID"** (allows this field to be used for integrations)
5. Click **Next** → **Next** (Field-Level Security: select visible for profiles)
6. Click **Save & New** to create the next field

#### Create Student Name Field:

1. Select **"Text"** as the data type → Click **Next**
2. Configure the field:
   - **Field Label:** `Student Name`
   - **Length:** `255`
   - **Field Name:** `Student_Name` (API Name: `Student_Name__c`)
3. Click **Next** → **Next**
4. Click **Save**

---

### Step 3: Add Student Tab to the App

**What is a Tab?**
Tabs provide a way to navigate to and display your custom objects, web content, or custom pages. They appear at the top of Salesforce pages and in the App Launcher.

**Instructions:**

1. In Setup, search for **"Tabs"** in Quick Find
2. Click **"New"** in the Custom Object Tabs section
3. Configure the tab:
   - **Object:** Select `Student`
   - **Tab Style:** Choose an icon (e.g., Briefcase, Person, or any icon you prefer)
   - **Description:** `Access student records and evaluations`
4. Click **Next** → **Next**
5. Select which apps should include this tab (check **"Evaluation Manager"**)
6. Click **Save**

---

### Step 4: Deploy the Lightning Web Component

**What is a Lightning Web Component (LWC)?**
Lightning Web Components are custom UI elements built using modern web standards (HTML, JavaScript, CSS). They provide a fast, reusable way to build Salesforce user interfaces. LWCs can be placed on record pages, home pages, or app pages.

**Instructions:**

#### 4.1 Authenticate with Salesforce

```bash
# Authorize your org
SFDX_DISABLE_DNS_CHECK=true sf org login web --set-default-dev-hub --alias myDevOrg
```

#### 4.2 Deploy the Metadata

**What is Metadata?**
Metadata describes the structure of your Salesforce org (objects, fields, components, etc.). When you deploy, you're pushing your local code and configurations to your Salesforce org.

```bash
# Deploy all components
sf project deploy start --target-org myDevOrg

# Or deploy specific component
sf project deploy start --source-dir force-app/main/default/lwc/fileUploader --target-org myDevOrg
```

---

### Step 5: Configure the Component on the Page Layout

**What is a Page Layout?**
Page Layouts control the organization and appearance of fields, buttons, and related lists on object record pages. Lightning Pages extend this by allowing you to add custom components using the Lightning App Builder.

**Instructions:**

#### 5.1 Activate Lightning Experience (if not already active)

1. In Setup, search for **"Lightning Experience"**
2. Ensure Lightning Experience is enabled

#### 5.2 Add Component to Student Record Page

1. Navigate to a Student record (or create a new one)
   - Go to the **Students** tab
   - Click **"New"** to create a test record, or open an existing one
2. Click the **Setup gear icon** → Select **"Edit Page"**

   **What is Lightning App Builder?**
   Lightning App Builder is a drag-and-drop tool that lets you create custom pages for Lightning Experience. You can add standard and custom components to build pages that meet your specific needs.

3. In the Lightning App Builder:
   - On the left sidebar, find the custom component **"fileUploader"** under Custom section
   - Drag it to the desired location on the page (typically in the right sidebar or a tab)

4. Configure component properties (if any settings are available in the right panel)

5. Click **Save**

6. Activate the page:
   - Click **Activation**
   - Choose **"Assign as Org Default"** to make it the default for all Student records
   - Or create assignment rules based on App, Record Type, or Profile
   - Click **Save**

7. Click **Back** to return to the record page

---

## Project Structure

```
force-app/main/default/
├── lwc/
│   └── fileUploader/
│       ├── fileUploader.js          # Component logic
│       ├── fileUploader.html        # Component template
│       ├── fileUploader.js-meta.xml # Component metadata
│       └── fileUploader.css         # Component styles (if any)
├── classes/
│   └── FileUploadController.cls     # Apex controller for backend operations
```

---

