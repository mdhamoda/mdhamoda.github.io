✅ README.md
markdown
Copy
Edit
# Logistica Shipment Requests LWC

A Salesforce Lightning Web Component (LWC) that displays shipment requests in a dynamic, interactive table. Features include:

- Region-based filtering
- Live countdown timer for "In Review" shipments
- EMP API subscription for real-time updates
- Editable modal for updating shipment records
- Dispatch functionality with validations
- Record creation and deletion via modal
- Lightning styling with SLDS

---

## 📁 Folder Structure

force-app/
└── main/
└── default/
└── lwc/
└── shipmentDatatable/
├── shipmentDatatable.js
├── shipmentDatatable.html
├── shipmentDatatable.js-meta.xml
└── README.md

yaml
Copy
Edit

---

## 🚀 Setup Instructions

1. **Prerequisites**:
   - Salesforce DX CLI
   - Access to a Salesforce org (scratch org/dev org)
   - Git installed

2. **Deploy to Salesforce**:
   ```bash
   sfdx force:source:push
Assign Permissions:
Assign the correct permission set if needed to view the ShipmentRequest__c object and fields.

Add Component to Lightning App:

Navigate to your Lightning App Builder.

Drag the shipmentDatatable component onto a page.

🧩 Key Features
Real-Time Updates: Uses EMP API to subscribe to custom platform events.

Dynamic Countdown: Dispatch timer shows remaining time before expiration (5 minutes).

Status Management: Status transitions from "Assigned to Agent" to "In Review" automatically.

User Feedback: Toast messages for success/error handling.

New Shipment Modal: Record creation with form validation.

Deletion Support: Full record deletion with confirmation and toast.

⚠️ Limitations
EMP API requires ShipmentRequestEvent__e to be published correctly.

Only works in orgs where ShipmentRequest__c and related fields exist.

✨ Customization
You can modify the following to tailor it to your org:

REGION_OPTS in the JS file for different region values.

Timer logic (formatCountdown()) for different thresholds.

Status options (e.g., "Ready for Dispatch") to match your org's picklist.

👨‍💻 Author
Manigandan Dhamodaran
Last updated: June 25, 2025
