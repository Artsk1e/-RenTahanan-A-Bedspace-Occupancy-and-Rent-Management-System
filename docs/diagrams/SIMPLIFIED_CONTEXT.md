# Context Diagram (Level 0) — Simplified

**Purpose:** High-level system boundary showing only the primary actors and the main system hub.

```mermaid
flowchart LR
    %% External Actors
    Owner["👤 Owner"]
    Caretaker["👷 Caretaker"]
    Tenant["🎓 Tenant"]
    
    %% System Hub
    System["🏠 RenTahanan Core System"]
    
    %% Database
    DB[("🗄️ PostgreSQL Database")]
    
    %% Simplified Flows
    Owner <-->|Operational Reports & Audit| System
    Caretaker <-->|Daily Operations & Payments| System
    Tenant <-->|Self-Service Portal Access| System
    
    System <-->|Data Persistence| DB

    %% Styling
    classDef entity fill:#f5f5f5,stroke:#333,stroke-width:2px
    classDef system fill:#e3f2fd,stroke:#1976d2,stroke-width:3px
    classDef store fill:#e8f5e9,stroke:#388e3c,stroke-width:2px
    
    class Owner,Caretaker,Tenant entity
    class System system
    class DB store
```

---

*This simplified view focuses on the "what" (Actors interacting with the Core Hub) rather than the "how" (individual data points), making it perfect for an executive summary or a high-level presentation.*