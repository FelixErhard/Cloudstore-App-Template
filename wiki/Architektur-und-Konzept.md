# Architektur & Konzept

## Die Rolle von `template.yaml`

Die `template.yaml` ist die zentrale Schnittstelle zwischen drei Systemen:

```
template.yaml
    │
    ├── Terraform         → parameters werden zu Terraform-Variablen
    ├── Appstore-UI       → x-ui steuert wie Parameter dargestellt werden
    └── Backend-Features  → deploy-strategy, email_credentials, outputs
```

### Terraform

Jeder Parameter unter `parameters` wird 1:1 als Terraform-Variable übergeben.
Der `name` des Parameters muss exakt dem Variablen-Namen in der Terraform-Konfiguration entsprechen.

### Appstore-UI

Das `x-ui`-Feld steuert ausschließlich die Darstellung im Konfigurationsformular —
es hat keinen Einfluss auf die an Terraform übergebenen Werte.

### Backend

Der Backend-Parser liest die Datei via `yaml.safe_load()` und speichert sie unverändert als JSON.
Das Frontend empfängt alles was in der Datei steht — unbekannte Felder werden ignoriert, nicht gefiltert.
Felder wie `deploy-strategy` und `email_credentials` werden direkt vom Backend ausgewertet.

## Deployment-Workflow

```
Nutzer öffnet App im Appstore
        │
        ▼
Wizard Schritt 1: general-Parameter (gilt für alle Instanzen)
        │
        ▼ (wenn deploy_strategy)
Wizard Schritt 2:
Deployment-Strategie wählen:
one-instance, one-per-user, one-per-group
        │
        ▼    
Wizard Schritt 3: specific-Parameter (pro Instanz konfigurierbar)
        │
        ▼         (wenn email_credentials.enabled: true)
Optionaler Schritt: 
Zugangsdaten per E-Mail versenden
        │
        ▼
Terraform-Deployment
```

## Weiterführend

- [Template-Struktur](Template-Struktur) — alle Top-Level-Felder im Überblick
- [Deploy-Strategien & Backend-Features](Deploy-Strategien) — `deploy-strategy` und `email_credentials`
- [Parameter-Typen](Parameter-Typen) — welche Typen es gibt und wie sie gemappt werden
