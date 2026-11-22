# System Architecture Diagram — RenTahanan

**Generated:** 2026-11-22  
**Alignment:** Requirements ↔ ERD ↔ Class Diagram ↔ Infrastructure  

---

## 1. Architectural Requirements Summary

| Requirement Category | Key Architectural Drivers |
|----------------------|---------------------------|
| **User Stories (US)** | **Role-Based Access:** Isolated portals for Owner, Caretaker, and Tenant roles. |
| **Functional (FR)** | **Transactional Integrity:** SQL Transactions for bed assignments and move-out clearances. |
| **Non-Functional (NFR)** | **Input Security:** Zod Schema Validation for all incoming API requests (NFR-07). |
| **Audit & Alerts** | **Audit Trail:** Automatic activity logging and overdue notification generation (FR-04, FR-06). |

---

## 2. System Architecture Diagram

```mermaid
flowchart TD
    %% ==================== CLIENT TIER ====================
    subgraph ClientTier["📱 Client Tier (Presentation)"]
        Browser["🌐 Browser / Mobile HTTPS Client\n(React 18 + Vite)"]
        subgraph Portals["Role-Based Logic"]
            Owner["Owner: Reports & Audit"]
            Staff["Caretaker: Daily Ops"]
            Tenant["Tenant: Self-Service"]
        end
    end

    %% ==================== GATEWAY TIER ====================
    subgraph GatewayTier["🛡️ Gateway Tier (Security & Validation)"]
        direction TB
        API["🌍 Express API Gateway"]
        Auth["🔑 JWT & RBAC Middleware\n(Identity Guard)"]
        Zod["✅ Zod Schema Validation\n(Ensures valid Data Contracts)"]
        Error["⚠️ Error Handler\n(Standardized Responses)"]
    end

    %% ==================== APPLICATION TIER ====================
    subgraph AppTier["🧠 Application Tier (Business Logic)"]
        direction TB
        Ctrl["🎮 Controllers\n(HTTP to DTO Mapping)"]
        subgraph Services["Services (Business Orchestration)"]
            Svc_Occ["Occupancy Service\n(Room/Bed/Tenant Mgmt)"]
            Svc_Contract["Contract Service\n(Assignments / Move-out)"]
            Svc_Finance["Finance Service\n(Billing / Payments)"]
            Svc_Report["Report Service\n(Owner Analytics)"]
        end
        Logger["📝 Audit & Notification Engine\n(Activity & Alert Logs)"]
    end

    %% ==================== DATA TIER ====================
    subgraph DataTier["💾 Data Tier (Persistence)"]
        direction LR
        Repo["🗄️ Repositories\n(SQL & Transactions)"]
        DB[("🐘 PostgreSQL\n(rentahanan_db)")]
    end

    %% ==================== FLOWS ====================
    Browser --> Portals
    Portals -- "HTTPS / JWT" --> API
    API --> Auth
    Auth --> Zod
    Zod --> Ctrl
    
    %% Application Logic Flow
    Ctrl <--> Services
    Services <--> Repo
    Repo -- "SQL / FOR UPDATE" --> DB
    
    %% Background Logic
    Services -.-> Logger
    Logger -.-> Repo
    Repo -.-> Error
    Error -.-> API

    %% ==================== STYLING ====================
    classDef client fill:#f0f7ff,stroke:#0056b3,stroke-width:2px
    classDef gateway fill:#fdf2f2,stroke:#c81e1e,stroke-width:2px
    classDef app fill:#fffaf0,stroke:#d97706,stroke-width:2px
    classDef data fill:#f0fff4,stroke:#166534,stroke-width:2px

    class ClientTier,Browser,Portals,Owner,Staff,Tenant client
    class GatewayTier,API,Auth,Zod,Error gateway
    class AppTier,Ctrl,Services,Svc_Occ,Svc_Contract,Svc_Finance,Svc_Report,Logger app
    class DataTier,Repo,DB data
```

---

## 3. Communication & Data Integrity Patterns

1.  **Identity Guard (Auth):** Every request must carry a JWT. The **RBAC Middleware** checks the "Role" claim inside the token against the required permission for the route.
2.  **Data Contracts (Zod):** Before reaching a Service, all input is validated by **Zod**. This ensures the **Controllers** only map valid, clean data into **DTOs** (Data Transfer Objects), protecting the logic layer from "dirty" inputs.
3.  **Service Orchestration:** 
    *   **Occupancy Service:** Manages real-time room/bed status toggles.
    *   **Finance Service:** Handles the specific "Exact Payment" logic (FR-03.3).
    *   **Report Service:** Aggregates data for Owner-only financial and occupancy reports.
4.  **Audit & Alerts:** The **Logger Engine** ensures that every sensitive operation is recorded (for the Owner) and that overdue bills automatically trigger entries in the `notifications` table (for the Caretaker).
5.  **Concurrency Control:** The **Repositories** use PostgreSQL row-level locking (`FOR UPDATE`) to ensure that bed assignments are thread-safe and double-bookings are physically impossible.

---

*This architecture is fully synchronized with the `REQUIREMENTS.md`, `ERD.md`, and `IMPLEMENTATION_CLASS_DIAGRAM.md`.*