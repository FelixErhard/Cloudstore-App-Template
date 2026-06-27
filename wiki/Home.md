# CloudStore App-Template – Dokumentation

Willkommen im Wiki des CloudStore App-Template-Projekts.
Hier findest du alle Informationen, um eigene App-Templates für den CloudStore-Appstore zu erstellen.

## Schnellnavigation

| Seite | Inhalt |
|---|---|
| [Template-Struktur](Template-Struktur) | Vollständige YAML-Dateistruktur als Referenz |
| [Parameter-Typen](Parameter-Typen) | `string`, `number`, `boolean`, `array`, `selection`, `groups` |
| [x-ui Referenz](x-ui-Referenz) | Alle UI-Steuerungsfelder: Gruppen, Sichtbarkeit, Layouts, Hinweise |
| [Widgets](Widgets) | Spezialisierte Eingabekomponenten: `user-picker` & `group-builder` |
| [Deploy-Strategien & Backend-Features](Deploy-Strategien) | `deploy-strategy`, `email_credentials` und ihre Voraussetzungen |
| [Outputs](Outputs) | Terraform-Outputs im Template definieren und anzeigen |
| [Vollständiges Beispiel](Vollstaendiges-Beispiel) | Kommentiertes Node.js-Template als Kopiervorlage |

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

Jeder Parameter unter `parameters` wird 1:1 als Terraform-Variable übergeben.
Der `name` des Parameters muss exakt dem Variablen-Namen in der Terraform-Konfiguration entsprechen.
Der `type` bestimmt den Terraform-Datentyp (`string`, `number`, `bool`, `list(string)`, `map(list(string))`).



Das `x-ui`-Feld steuert ausschließlich die Darstellung im Konfigurationsformular:
Gruppierung, Reihenfolge, Sichtbarkeit, Pflichtfeld-Logik, Icons, Hinweistexte, Breite.
`x-ui` hat keinen Einfluss auf Terraform — es ändert nie welcher Wert übergeben wird.


Das `outputs`-Array beschreibt welche Terraform-Outputs nach dem Deployment
gespeichert und im Deployment-Detail angezeigt werden sollen.
Es steuert auch welche Werte als sensibel markiert und im E-Mail-Schritt angeboten werden.

Backend-Features bieten erweiterte Funktionalitäten bezüglich des Deployment-Prozesses. Darunter fällt das Versenden von Credentails via Email oder auch Deployment-Strategien.

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
