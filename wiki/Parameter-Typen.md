# Parameter-Typen

Parameter sind die Eingabefelder des Deploymentworkflows. Jeder Parameter wird nach dem
Deployment 1:1 als Terraform-Variable übergeben — der `name` muss exakt dem Variablen-Namen
in der Terraform-Konfiguration entsprechen.

Der `type` bestimmt dabei zweierlei: welches Eingabe-Widget im Formular gerendert wird,
und in welchem Terraform-Typ der Wert ankommt.

Jeder Parameter benötigt ein `type`-Feld. Der Typ bestimmt das Eingabe-Widget und das Terraform-Mapping.

## Gemeinsame Felder

Alle Parameter-Typen unterstützen diese Felder:

| Feld | Typ | Pflicht | Beschreibung |
|---|---|---|---|
| `name` | string | Ja | Interner Bezeichner, muss exakt dem Terraform-Variablen-Namen entsprechen |
| `type` | string | Ja | Einer der unten beschriebenen Typen |
| `description` | string | Empfohlen | Wird als Label über dem Eingabefeld angezeigt |
| `required` | boolean | Nein | Pflichtfeld (Standard: `false`) |
| `default` | any | Nein | Vorausgefüllter Wert, muss zum `type` passen |
| `validation` | object | Nein | Validierungsregeln (siehe unten) |
| `x-ui` | object | Nein | UI-Steuerung (siehe [x-ui Referenz](x-ui-Referenz)) |

---

## `string`

Rendert als einzeiliges Texteingabefeld.
Terraform-Typ: `string`

```yaml
- name: app_name
  type: string
  required: true
  description: "Projektname"
  validation:
    pattern: "^[a-zA-Z0-9-_]{3,20}$"
    min: 3
    max: 20
```

| Validierungsfeld | Beschreibung |
|---|---|
| `pattern` | Regex-Pattern |
| `min` | Mindestzeichenlänge |
| `max` | Maximalzeichenlänge |

---

## `number`

Rendert als numerisches Eingabefeld.
Terraform-Typ: `number`

```yaml
- name: replica_count
  type: number
  required: true
  default: 2
  validation:
    min: 1
    max: 10
```

| Validierungsfeld | Beschreibung |
|---|---|
| `min` | Mindestwert (nicht Zeichenlänge) |
| `max` | Maximalwert (nicht Zeichenlänge) |

---

## `boolean`

Rendert als Checkbox.
Terraform-Typ: `bool`

```yaml
- name: enable_gpu
  type: boolean
  default: false
  description: "GPU-Beschleunigung aktivieren"
```

---

## `array`

Rendert als mehrzeiliges Textfeld. Nutzer gibt Werte zeilenweise oder kommagetrennt ein —
wird automatisch zu einer Terraform `list(string)` transformiert.
Terraform-Typ: `list(string)`

```yaml
- name: allowed_ips
  type: array
  description: "Erlaubte IP-Adressen"
  validation:
    min_items: 1
    max_items: 20
```

| Validierungsfeld | Beschreibung |
|---|---|
| `min_items` | Mindestanzahl Einträge |
| `max_items` | Maximalanzahl Einträge |

Kann auch als `user-picker` mit `multi: true` verwendet werden — dann übernimmt der Widget die Eingabe.
Siehe [Widgets – user-picker](Widgets#user-picker).

---

## `selection`

Rendert als Dropdown. Erfordert `options`.
Terraform-Typ: `string` (der `value` des gewählten Eintrags)

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

- `options[].label` — wird im Dropdown angezeigt
- `options[].value` — wird an Terraform übergeben
- `default` muss einem `value` aus `options` entsprechen

---

## `groups`

Spezieller Typ für den `group-builder` Widget.
Terraform-Typ: `map(list(string))` — jede Gruppe ist ein Key, zugehörige Nutzer sind die Values.

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
Siehe [Widgets – group-builder](Widgets#group-builder).

---

## `validation`

Das `validation`-Objekt liegt am Top-Level des Parameters (nicht unter `x-ui`).
Es wird im Frontend als Echtzeit-Validierung angewendet.

```yaml
validation:
  min: 1              # number: Mindestwert   / string: Mindestlänge
  max: 100            # number: Maximalwert   / string: Maximallänge
  pattern: "^[a-z]+$" # string: Regex-Pattern
  min_items: 1        # array: Mindestanzahl Einträge
  max_items: 10       # array: Maximalanzahl Einträge
```

Ist kein `validation`-Block gesetzt, werden keine Constraints angewendet.
