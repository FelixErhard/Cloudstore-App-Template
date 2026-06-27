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

### `parameters` → Terraform

Jeder Parameter unter `parameters` wird 1:1 als Terraform-Variable übergeben.
Der `name` des Parameters muss exakt dem Variablen-Namen in der Terraform-Konfiguration entsprechen.
Der `type` bestimmt den Terraform-Datentyp (`string`, `number`, `bool`, `list(string)`, `map(list(string))`).

### `x-ui` → Appstore-Formular

Das `x-ui`-Feld steuert ausschließlich die Darstellung im Konfigurationsformular:
Gruppierung, Reihenfolge, Sichtbarkeit, Pflichtfeld-Logik, Icons, Hinweistexte, Breite.
`x-ui` hat keinen Einfluss auf Terraform — es ändert nie welcher Wert übergeben wird.

### `outputs` → Deployment-Detail

Das `outputs`-Array beschreibt welche Terraform-Outputs nach dem Deployment
gespeichert und im Deployment-Detail angezeigt werden sollen.
Es steuert auch welche Werte als sensibel markiert und im E-Mail-Schritt angeboten werden.

### Backend-Features

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
