# CloudStore App-Template Entwicklerdokumentation

## Grundidee

Die `template.yml` ist die zentrale Schnittstelle zwischen drei Welten:

```
template.yml
    │
    ├── Terraform         → parameters werden zu Terraform-Variablen
    ├── Appstore-UI       → x-ui steuert wie Parameter dargestellt werden
    └── Backend-Features  → deploy-strategy, email_credentials, outputs
```

Der Backend-Parser liest die Datei via `yaml.safe_load()` und speichert sie unverändert als JSON.
Das Frontend empfängt alles was in der Datei steht — unbekannte Felder werden ignoriert, nicht gefiltert.

Ein vollständiges Beispiel-Template befindet sich unter
`src/worker/templates/testubuntu-42/template.yaml`.


**Dateistruktur Template.yaml**

```yaml
name:             # interner Bezeichner
display_name:     # Anzeigename im Appstore
description:
version:
category:
author:
icon:

terraform:        # Terraform-Konfiguration
  working_dir:
  required_version:

tags: []

email_credentials:
  enabled:

deploy-strategy:
  one-instance:
  one-per-user:
  one-per-group:

ui-groups: []     # Optionale Gruppendefinitionen

parameters:
  general: []     # Schritt 1 im Wizard (gilt für alle Instanzen)
  specific: []    # Schritt 2 im Wizard (pro Instanz konfigurierbar)

outputs: []
```

---


## Appstore-UI-Steuerung: `ui-groups`

Definiert benannte Gruppen in die Parameter eingeordnet werden können.
Ohne `ui-groups` werden alle Parameter unter dem Fallback-Namen `General` gruppiert.

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

### `id`

**Typ:** `string` — Pflicht
Stabiler Bezeichner der Gruppe. Wird von Parametern via `x-ui.group_id` referenziert.
Eine Umbenennung von `title` bricht keine Parameter-Referenzen solange `id` gleich bleibt.

### `title`

**Typ:** `string` — Pflicht
Angezeigter Gruppenname im Formular.

### `order`

**Typ:** `number` — Optional
Reihenfolge der Gruppen im Formular. Gruppen ohne `order` werden nach definierten Gruppen
alphabetisch sortiert.

### `collapsed`

**Typ:** `boolean` — Optional, Standard: `false`
Wenn `true`, wird die Gruppe im Formular standardmäßig eingeklappt.
Nützlich für selten geänderte Einstellungen wie Ressourcen-Größen.

---

## Appstore: Backend-Features: `deploy-strategy` und `email_credentials`

### `deploy-strategy`

Bestimmt welche Deployment-Modi dem Nutzer im Wizard angeboten werden.

```yaml
deploy-strategy:
  one-instance: true    # Eine VM für alle Nutzer (immer verfügbar)
  one-per-user: true    # Eine VM pro Nutzer aus dem user-picker
  one-per-group: true   # Eine VM pro Gruppe aus dem group-builder
```

- `one-per-user` setzt voraus dass ein Parameter mit `widget.type: user-picker`
  und `widget.multi: true` in `parameters.general` existiert.
- `one-per-group` setzt voraus dass ein Parameter mit `widget.type: group-builder`
  in `parameters.general` existiert.
- Ist `deploy-strategy` nicht gesetzt, steht nur `one-instance` zur Verfügung.

---

### `email_credentials`

```yaml
email_credentials:
  enabled: true
```

Wenn `true`, erscheint nach dem Konfigurationsschritt ein optionaler Schritt in dem der Nutzer
Zugangsdaten nach dem Deployment per E-Mail versenden kann.
Die Empfänger werden automatisch aus `user-picker`-Parametern abgeleitet.

---

## Terraform-Mapping

### `parameters`

Parameter können flach (Legacy) oder aufgeteilt in `general`/`specific` definiert werden:

```yaml
# Neu (mit deploy-strategy)
parameters:
  general:
    - name: app_name
      ...
  specific:
    - name: flavor_name
      ...

# Legacy (flat, nur one-instance)
parameters:
  - name: app_name
    ...
```

**`general`** — wird im ersten Wizard-Schritt angezeigt. Gilt für alle Instanzen gleichzeitig
(z.B. App-Name, Nutzerauswahl, Gruppen).

**`specific`** — wird im zweiten Wizard-Schritt angezeigt. Bei `one-per-user` / `one-per-group`
kann jede Instanz eigene Werte erhalten (z.B. VM-Größe, Git-Repo).

#### `name`

**Typ:** `string` — Pflicht
Interner Bezeichner. Muss exakt dem Terraform-Variablen-Namen entsprechen.
Nur Buchstaben, Zahlen und Unterstriche.

#### `description`

**Typ:** `string` — Empfohlen
Wird als Label über dem Eingabefeld angezeigt.

#### `required`

**Typ:** `boolean` — Standard: `false`
Pflichtfelder müssen ausgefüllt sein bevor der Wizard fortschreitet.
Bedingte Pflichtfelder können via `x-ui.required-if` definiert werden.

#### `default`

**Typ:** any
Vorausgefüllter Wert. Muss zum `type` passen.

---

## Parameter-Typen

### `string`

Rendert als einzeiliges Texteingabefeld.

```yaml
- name: app_name
  type: string
  required: true
  description: "Projektname"
  validation:
    pattern: "^[a-zA-Z0-9-_]{3,20}$"
```

Unterstützt `validation.pattern` (Regex) sowie `validation.min` / `validation.max`
für Zeichenlänge.

### `number`

Rendert als numerisches Eingabefeld.

```yaml
- name: replica_count
  type: number
  required: true
  default: 2
  validation:
    min: 1
    max: 10
```

`validation.min` / `validation.max` werden als Wertbereich (nicht Zeichenlänge) interpretiert.

### `boolean`

Rendert als Checkbox.

```yaml
- name: enable_gpu
  type: boolean
  default: false
  description: "GPU-Beschleunigung aktivieren"
```

Typischer Use Case: Steuert via `x-ui.visible-if` ob abhängige Parameter angezeigt werden.

### `array`

Rendert als mehrzeiliges Textfeld. Nutzer gibt Werte zeilenweise oder kommagetrennt ein —
wird automatisch zu einer Terraform `list(string)` transformiert.

```yaml
- name: allowed_ips
  type: array
  description: "Erlaubte IP-Adressen"
  validation:
    min_items: 1
    max_items: 20
```

### `selection`

Rendert als Dropdown. Erfordert `options`.

```yaml
- name: flavor_name
  type: selection
  required: true
  default: "gp1.medium"
  options:
    - label: "Small (1 CPU, 2 GB RAM)"
      value: "gp1.small"
    - label: "Medium (2 CPU, 4 GB RAM)"
      value: "gp1.medium"
    - label: "Large (4 CPU, 8 GB RAM)"
      value: "gp1.large"
```

`options[].label` wird angezeigt, `options[].value` wird an Terraform übergeben.
`default` muss einem `value` aus `options` entsprechen.

### `groups`

Spezieller Typ für den `group-builder` Widget. Wird als `map(list(string))` an Terraform
übergeben — jede Gruppe ist ein Key, die zugehörigen Nutzer sind die Values.

```yaml
- name: student_groups
  type: groups
  required: true
  x-ui:
    widget:
      type: group-builder
      extract: email
```

Setzt zwingend `widget.type: group-builder` voraus.

---

## `validation`

Liegt am Top-Level des Parameters, nicht unter `x-ui`. Wird im Frontend als
Echtzeit-Validierung angewendet.

```yaml
validation:
  min: 1             # number: Mindestwert   / string: Mindestlänge
  max: 100           # number: Maximalwert   / string: Maximallänge
  pattern: "^[a-z]+$"  # string: Regex-Pattern
  min_items: 1       # array: Mindestanzahl Einträge
  max_items: 10      # array: Maximalanzahl Einträge
```

Ist kein `validation`-Block gesetzt, werden keine Constraints angewendet.

---

## `x-ui`

Optionale UI-Metadaten die steuern wie ein Parameter dargestellt wird.
Hat keinen Einfluss auf Terraform-Variablen.

### `group_id`

**Typ:** `string`
**Abhängigkeit:** `ui-groups` muss eine Gruppe mit dieser `id` definieren

Ordnet den Parameter einer Gruppe zu. Bevorzuge `group_id` gegenüber dem
Legacy-Feld `group` (direkte Titelangabe).

```yaml
x-ui:
  group_id: resources
```

Ist weder `group_id` noch `group` gesetzt, landet der Parameter in der Gruppe `General`.

### `in_group_order`

**Typ:** `number`
Reihenfolge des Parameters innerhalb seiner Gruppe. Niedrigere Werte erscheinen zuerst.
Ohne dieses Feld ist die Reihenfolge undefiniert.

```yaml
x-ui:
  group_id: general
  in_group_order: 2
```

### `icon`

**Typ:** `string`
Kleines Icon links neben dem Parameter-Label.

Verfügbare Werte: `Server`, `Users`, `HardDrive`, `Cpu`, `Zap`

```yaml
x-ui:
  icon: Cpu
```

### `placeholder`

**Typ:** `string`
Platzhaltertext im leeren Eingabefeld. Wird bei `user-picker` und `group-builder`
als Suchfeld-Placeholder verwendet.

```yaml
x-ui:
  placeholder: "z.B. mein-projekt-01"
```

### `hint`

**Typ:** `string`
Blauer Hilfetext der unterhalb des Labels erscheint — vor dem Eingabefeld.
Für kontextuelle Informationen die die Eingabe erleichtern.

```yaml
x-ui:
  hint: "Für 3-5 Personen wird Medium empfohlen"
```

### `warning`

**Typ:** `string`
Gelber Warnhinweis der unterhalb des Eingabefelds erscheint.
Für Hinweise auf Kosten, Risiken oder irreversible Aktionen.

```yaml
x-ui:
  warning: "GPU-Instanzen kosten 5× mehr als Standard-VMs"
```

> `hint` und `warning` können technisch gleichzeitig gesetzt werden, sollten es aber
> semantisch nicht — entweder ist eine Eingabe hilfreich zu erklären (hint) oder
> sie hat Konsequenzen (warning).

### `hidden`

**Typ:** `boolean` — Standard: `false`
Parameter wird nicht im Formular angezeigt und nicht validiert.
Der Wert aus `default` wird trotzdem an Terraform übergeben.

```yaml
- name: region
  type: string
  default: "de-fra1"
  x-ui:
    hidden: true
```

### `target`

**Typ:** `string` — `terraform` (Standard) | `backend`
Bestimmt wohin der Wert nach dem Deployment übergeben wird.
`backend` leitet den Wert an das Backend weiter statt an Terraform.

<!-- PLACEHOLDER: Konkreten Use Case für target: backend ergänzen -->

### `visible-if`

**Typ:** `string` (JavaScript-Expression)
Parameter wird nur angezeigt wenn der Ausdruck `true` ergibt.
Kann auf andere Parameter-Namen im Formular zugreifen.

```yaml
- name: enable_gpu
  type: boolean

- name: gpu_count
  type: number
  x-ui:
    visible-if: "enable_gpu === true"
```

Weitere Beispiele:
```
"ram_mb > 8192"
"cpu_cores >= 4 && enable_gpu === true"
"git_repo_url !== ''"
```

### `required-if`

**Typ:** `string` (JavaScript-Expression)
Parameter wird nur als Pflichtfeld behandelt wenn der Ausdruck `true` ergibt.

```yaml
- name: git_token
  type: string
  x-ui:
    required-if: "git_repo_url !== ''"
```

### `width: half`

**Typ:** `string` — `full` (Standard) | `half`
Setzt die Breite des Eingabefelds auf 50%. Sinnvoll für kurze zusammengehörige Werte
wie Min/Max-Paare.

```yaml
- name: min_replicas
  x-ui:
    width: half
- name: max_replicas
  x-ui:
    width: half
```

---

## Widget-Komponenten (`widget`)

Widgets ersetzen Standard-Eingabefelder durch spezialisierte UI-Komponenten.
Werden unter `x-ui.widget` konfiguriert.

### `user-picker`

Ersetzt ein Texteingabefeld durch eine Suchmaske mit Nutzer-Autovervollständigung.
Nutzer werden aus dem CloudStore-Nutzerpool geladen.

```yaml
x-ui:
  widget:
    type: user-picker
    multi: false      # false = Einzelauswahl, true = Mehrfachauswahl
    extract: email    # Welcher Wert an Terraform übergeben wird
```

| `multi` | `type` am Parameter | Terraform-Ausgabe |
|---|---|---|
| `false` | `string` | `"max.mustermann@dhbw.de"` |
| `true` | `array` | `["max@dhbw.de", "anna@dhbw.de"]` |

`extract` bestimmt welches Nutzer-Attribut als Wert übergeben wird:

| Wert | Ausgabe |
|---|---|
| `email` | E-Mail-Adresse (Standard) |
| `name` | Vorname |
| `id` | Interne Nutzer-ID |

**Abhängigkeit zu `deploy-strategy`:** Ein `user-picker` mit `multi: true` in
`parameters.general` ist Voraussetzung für `one-per-user`.

### `group-builder`

Ermöglicht das Erstellen benannter Gruppen aus Nutzern.
Gibt ein `map(list(string))`-Objekt an Terraform zurück.

```yaml
- name: student_groups
  type: groups
  x-ui:
    widget:
      type: group-builder
      extract: email
```

Terraform-Ausgabe:
```hcl
student_groups = {
  "Gruppe A" = ["max@dhbw.de", "anna@dhbw.de"]
  "Gruppe B" = ["tom@dhbw.de"]
}
```

Setzt `type: groups` am Parameter voraus.

**Abhängigkeit zu `deploy-strategy`:** Ein `group-builder` in `parameters.general`
ist Voraussetzung für `one-per-group`.

---

### `outputs`

Definiert welche Terraform-Outputs nach dem Deployment gespeichert und angezeigt werden.

```yaml
outputs:
  - name: app_url
    description: "Web-Server URL"
    display: true

  - name: ssh_private_key
    description: "SSH Private Key"
    display: false
    sensitive: true
```

### `name`

Muss exakt dem Terraform Output-Namen entsprechen.

### `description`

Angezeigter Label im Deployment-Detail.

### `display`

**Typ:** `boolean`
`true` — Output wird im Deployment-Detail angezeigt.
`false` — Output wird gespeichert aber nicht direkt angezeigt (z.B. System-IDs).

### `sensitive`

**Typ:** `boolean` — Standard: `false`
Markiert den Output als sensibel (Passwörter, SSH-Keys, Tokens).
Sensitive Outputs werden im Email-Versand-Schritt standardmäßig deaktiviert.

<!-- PLACEHOLDER: Prüfen ob sensitive outputs im UI maskiert werden oder nur im Email-Schritt -->

---

## Vollständiges Beispiel-Template

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

email_credentials:
  enabled: true

deploy-strategy:
  one-instance: true
  one-per-user: true
  one-per-group: true

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

outputs:
  - name: instance_id
    description: "System ID der Instanz"
    display: false

  - name: app_url
    description: "Web-Server URL"
    display: true

  - name: ssh_command
    description: "SSH Befehl für Zugriff"
    display: true

  - name: admin_credentials
    description: "Admin-Zugangsdaten"
    sensitive: true
    display: false

  - name: student_credentials
    description: "Studierenden-Zugangsdaten"
    sensitive: true
    display: false
```
