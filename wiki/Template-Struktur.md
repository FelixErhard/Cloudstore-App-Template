# Template-Struktur

Übersicht aller Top-Level-Felder einer `template.yaml`.

## Dateistruktur

```yaml
name:             # interner Bezeichner (Pflicht)
display_name:     # Anzeigename im Appstore (Pflicht)
description:      # Kurzbeschreibung
version:          # Versionsnummer, z.B. "1.0.0"
category:         # Kategorie im Appstore, z.B. "education"
author:
icon:             # Dateiname des Icons, z.B. "nodejs.png"

terraform:
  working_dir:    # Pfad zum Terraform-Verzeichnis, z.B. "terraform/"
  required_version: # Terraform-Mindestversion, z.B. ">= 1.6.0"

tags: []          # Freitext-Tags für die Appstore-Suche

email_credentials:
  enabled:        # true/false — aktiviert den E-Mail-Versand-Schritt

deploy-strategy:
  one-instance:   # true/false
  one-per-user:   # true/false
  one-per-group:  # true/false

ui-groups: []     # Optionale Gruppendefinitionen für das Formular

parameters:
  general: []     # Wizard-Schritt 1 — gilt für alle Instanzen
  specific: []    # Wizard-Schritt 2 — pro Instanz konfigurierbar

outputs: []       # Terraform-Outputs die gespeichert/angezeigt werden
```

## Parameter: flat vs. general/specific

Es gibt zwei Formate:

```yaml
# Neu — mit deploy-strategy (empfohlen)
parameters:
  general:
    - name: app_name
      ...
  specific:
    - name: flavor_name
      ...

# Legacy — flat, nur one-instance
parameters:
  - name: app_name
    ...
```

Das Legacy-Format wird weiterhin unterstützt, unterstützt aber keine `deploy-strategy`.

## `ui-groups`

Optionale Gruppenstruktur für das Konfigurationsformular.
Details: [x-ui Referenz – group_id](x-ui-Referenz#group_id)

```yaml
ui-groups:
  - id: general
    title: "Allgemein"
    order: 1
  - id: resources
    title: "Ressourcen"
    order: 2
    collapsed: true
```

| Feld | Typ | Pflicht | Beschreibung |
|---|---|---|---|
| `id` | string | Ja | Stabiler Bezeichner, referenziert von `x-ui.group_id` |
| `title` | string | Ja | Angezeigter Gruppenname |
| `order` | number | Nein | Reihenfolge im Formular |
| `collapsed` | boolean | Nein | Gruppe standardmäßig eingeklappt (Standard: `false`) |

## Weiterführend

- [Parameter-Typen](Parameter-Typen)
- [x-ui Referenz](x-ui-Referenz)
- [Deploy-Strategien & Backend-Features](Deploy-Strategien)
- [Outputs](Outputs)
