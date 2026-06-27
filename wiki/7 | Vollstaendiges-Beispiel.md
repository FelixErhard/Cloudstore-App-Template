# Vollständiges Beispiel

Das folgende Template zeigt eine Node.js-Entwicklungsumgebung für Projektgruppen.
Es ist als kommentierte Kopiervorlage gedacht und demonstriert das Zusammenspiel
aller Features in einem realen Anwendungsfall:

- `general`/`specific`-Parameter mit [`deploy-strategy`](5%20%7C%20Deploy-Strategien.md) (alle drei Modi aktiviert)
- `user-picker` (Einzel- und Mehrfachauswahl) und `group-builder`, siehe [Widgets](4%20%7C%20Widgets.md)
- [`ui-groups`](3%20%7C%20x-ui-Referenz.md) mit eingeklappter Gruppe für erweiterte Einstellungen
- [`outputs`](6%20%7C%20Outputs.md) mit verschiedenen Sichtbarkeits- und Sensibilitätsstufen
```yaml
name: nodejs-dev-environment
display_name: "Node.js Entwicklungsumgebung"
description: "Gemeinsame Node.js Entwicklungsumgebung für Projektgruppen"
version: "1.0.0"
category: "education"
author: "DHBW Mannheim"
icon: nodejs.png

terraform:
  working_dir: terraform/
  required_version: ">= 1.6.0"

tags:
  - nodejs
  - javascript
  - education

# Aktiviert den optionalen E-Mail-Schritt nach dem Deployment
email_credentials:
  enabled: true

# Alle drei Modi stehen dem Nutzer zur Auswahl
deploy-strategy:
  one-instance: true
  one-per-user: true    # benötigt user-picker mit multi: true in general
  one-per-group: true   # benötigt group-builder in general

# Drei Formulargruppen — "Erweiterte Einstellungen" standardmäßig eingeklappt
ui-groups:
  - id: general
    title: "Allgemein und Nutzer"
    order: 1
  - id: resources
    title: "Ressourcen"
    order: 2
  - id: advanced
    title: "Erweiterte Einstellungen"
    order: 3
    collapsed: true

parameters:
  # Wizard-Schritt 1: gilt für alle Instanzen gleichzeitig
  general:
    - name: app_name
      type: string
      required: true
      description: "Projektname (wird Hostname)"
      validation:
        pattern: "^[a-zA-Z0-9-_]{3,20}$"
      x-ui:
        group_id: general
        in_group_order: 1
        placeholder: "z.B. mein-projekt-01"

    # Einzelauswahl — gibt name des Dozenten zurück
    - name: admin_username
      type: string
      required: true
      description: "Dozent (erhält Sudo-Rechte)"
      x-ui:
        group_id: general
        in_group_order: 2
        icon: Users
        placeholder: "Dozent auswählen..."
        widget:
          type: user-picker
          multi: false
          extract: name

    # Mehrfachauswahl — Voraussetzung für one-per-user
    - name: students
      type: array
      required: true
      description: "Studierende"
      x-ui:
        group_id: general
        in_group_order: 3
        icon: Users
        placeholder: "Studierende auswählen..."
        widget:
          type: user-picker
          multi: true
          extract: email

    # group-builder — Voraussetzung für one-per-group
    - name: student_groups
      type: groups
      required: true
      description: "Projektgruppen"
      x-ui:
        group_id: general
        in_group_order: 4
        icon: Users
        widget:
          type: group-builder
          extract: email

  # Wizard-Schritt 2: pro Instanz konfigurierbar (bei one-per-user/-group)
  specific:
    - name: flavor_name
      type: selection
      required: true
      default: "gp1.medium"
      description: "VM-Größe"
      options:
        - label: "Small (1 CPU, 2 GB RAM)"
          value: "gp1.small"
        - label: "Medium (2 CPU, 4 GB RAM)"
          value: "gp1.medium"
        - label: "Large (4 CPU, 8 GB RAM)"
          value: "gp1.large"
      x-ui:
        group_id: resources
        in_group_order: 1
        icon: Cpu
        hint: "Für 3-5 Personen wird Medium empfohlen"

    - name: node_version
      type: selection
      required: true
      default: "20"
      description: "Node.js Version"
      options:
        - label: "Node.js 20 (LTS)"
          value: "20"
        - label: "Node.js 18 (LTS)"
          value: "18"
      x-ui:
        group_id: resources
        in_group_order: 2

    # Optional: Git-Repo — token nur wenn URL gesetzt
    - name: git_repo_url
      type: string
      required: false
      description: "Git Repository URL"
      validation:
        pattern: "^https?://.*\\.git$|^$"
      x-ui:
        group_id: advanced
        in_group_order: 1
        placeholder: "https://github.com/org/repo.git"

    - name: git_token
      type: string
      description: "Git Access Token"
      x-ui:
        group_id: advanced
        in_group_order: 2
        warning: "Token wird als Klartext an Terraform übergeben"

outputs:
  # Intern gespeichert, nicht angezeigt
  - name: instance_id
    description: "System ID der Instanz"
    display: false

  # Direkt angezeigt im Deployment-Detail
  - name: app_url
    description: "Web-Server URL"
    display: true

  - name: ssh_command
    description: "SSH Befehl für Zugriff"
    display: true

  # Sensibel: im E-Mail-Schritt standardmäßig deaktiviert
  - name: admin_credentials
    description: "Admin-Zugangsdaten"
    sensitive: true
    display: false

  - name: student_credentials
    description: "Studierenden-Zugangsdaten"
    sensitive: true
    display: false
```

---

[← Zurück zur Übersicht](Home)