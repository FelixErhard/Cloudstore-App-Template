# x-ui Referenz

`x-ui` ist die Schicht zwischen Parametern und dem Formular im Appstore.
Es steuert ausschließlich wie ein Parameter dargestellt wird — Gruppierung, Reihenfolge,
Sichtbarkeit, Pflichtfeld-Logik, Breite, Icons, Hinweistexte und Spezial-Widgets.

`x-ui` hat keinen Einfluss auf Terraform. Felder unter `x-ui` werden vom Backend ignoriert;
sie ändern nie welcher Wert an Terraform übergeben wird, sondern nur was der Nutzer im
Formular sieht und eingeben kann.

```yaml
- name: my_param
  type: string
  x-ui:
    group_id: resources
    in_group_order: 2
    icon: Cpu
    placeholder: "Beispieltext"
    hint: "Hilfreicher Hinweis"
    warning: "Achtung: kostenpflichtig"
    hidden: false
    width: half
    visible-if: "some_flag === true"
    required-if: "other_field !== ''"
    target: terraform
    widget:
      type: user-picker
      ...
```

---

## `group_id`

**Typ:** `string`
**Abhängigkeit:** `ui-groups` muss eine Gruppe mit dieser `id` definieren

Ordnet den Parameter einer Gruppe zu.

```yaml
x-ui:
  group_id: resources
```

Ist weder `group_id` noch das Legacy-Feld `group` gesetzt, landet der Parameter in der Fallback-Gruppe `General`.

---

## `in_group_order`

**Typ:** `number`

Reihenfolge des Parameters innerhalb seiner Gruppe. Niedrigere Werte erscheinen zuerst.
Ohne dieses Feld ist die Reihenfolge undefiniert.

```yaml
x-ui:
  group_id: general
  in_group_order: 2
```

---

## `icon`

**Typ:** `string`

Kleines Icon links neben dem Parameter-Label.

Verfügbare Werte: `Server`, `Users`, `HardDrive`, `Cpu`, `Zap`

```yaml
x-ui:
  icon: Cpu
```

---

## `placeholder`

**Typ:** `string`

Platzhaltertext im leeren Eingabefeld.
Wird bei `user-picker` und `group-builder` als Suchfeld-Placeholder verwendet.

```yaml
x-ui:
  placeholder: "z.B. mein-projekt-01"
```

---

## `hint`

**Typ:** `string`

Blauer Hilfetext der unterhalb des Labels erscheint — vor dem Eingabefeld.
Für kontextuelle Informationen die die Eingabe erleichtern.

```yaml
x-ui:
  hint: "Für 3-5 Personen wird Medium empfohlen"
```

---

## `warning`

**Typ:** `string`

Gelber Warnhinweis der unterhalb des Eingabefelds erscheint.
Für Hinweise auf Kosten, Risiken oder irreversible Aktionen.

```yaml
x-ui:
  warning: "GPU-Instanzen kosten 5× mehr als Standard-VMs"
```

> `hint` und `warning` können technisch gleichzeitig gesetzt werden, sollten es aber semantisch nicht —
> entweder ist eine Eingabe hilfreich zu erklären (`hint`) oder sie hat Konsequenzen (`warning`).

---

## `hidden`

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

---

## `width`

**Typ:** `string` — `full` (Standard) | `half`

Setzt die Breite des Eingabefelds auf 50%. Sinnvoll für kurze zusammengehörige Werte wie Min/Max-Paare.

```yaml
- name: min_replicas
  x-ui:
    width: half
- name: max_replicas
  x-ui:
    width: half
```

---

## `visible-if`

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

---

## `required-if`

**Typ:** `string` (JavaScript-Expression)

Parameter wird nur als Pflichtfeld behandelt wenn der Ausdruck `true` ergibt.
Ergänzt das statische `required`-Feld für bedingte Pflichtfelder.

```yaml
- name: git_token
  type: string
  x-ui:
    required-if: "git_repo_url !== ''"
```

---

## `target`

**Typ:** `string` — `terraform` (Standard) | `backend`

Bestimmt wohin der Wert nach dem Deployment übergeben wird.
`backend` leitet den Wert an das Backend weiter statt an Terraform.

```yaml
x-ui:
  target: backend
```

---

## `widget`

Ersetzt das Standard-Eingabefeld durch eine spezialisierte UI-Komponente.
Vollständige Dokumentation: [Widgets](Widgets)

```yaml
x-ui:
  widget:
    type: user-picker
    multi: true
    extract: email
```
