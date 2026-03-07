# Pipeline Failure

## Overview

Triggered when ingestion pipelines fail.

---

## Quick Triage

1. Confirm alert timestamp
2. Identify pipeline
3. Check last successful run

---

## Diagnostics

| Check | Action |
|------|------|
Pipeline logs | Review error message |
Source system | Confirm availability |
Credentials | Verify tokens |

---

## Escalation

Escalate after **15 minutes** if unresolved.

---

## Communication

Notify:

- Data Platform Team
- Service Owner

---

## Post Incident

Record:

- Root cause
- Fix applied
- Preventive action