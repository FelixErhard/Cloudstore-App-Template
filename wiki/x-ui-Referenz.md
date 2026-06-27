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
    hidden: false    
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

**Achtung: `warning` überschreibt `hint`.**

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
