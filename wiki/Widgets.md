# Widgets

Standardmäßig rendert jeder Parameter ein einfaches Texteingabefeld oder Dropdown.
Widgets ersetzen dieses Standard-Eingabefeld durch spezialisierte UI-Komponenten,
die direkt mit dem CloudStore-Nutzerpool interagieren — also Nutzer oder Gruppen
aus dem System laden, statt freien Text entgegenzunehmen.

Der Terraform-Wert bleibt identisch zum normalen Parameter-Typ (`string`, `array`, `groups`),
der Widget übernimmt nur die Eingabe. Widgets werden unter `x-ui.widget` konfiguriert.

---

## `user-picker`

Ersetzt ein Texteingabefeld durch eine Suchmaske mit Nutzer-Autovervollständigung.
Nutzer werden aus dem CloudStore-Nutzerpool geladen.

```yaml
x-ui:
  widget:
    type: user-picker
    multi: false      # false = Einzelauswahl, true = Mehrfachauswahl
    extract: email    # Welcher Wert an Terraform übergeben wird
```

### `multi`

| Wert | Parameter-Typ | Terraform-Ausgabe |
|---|---|---|
| `false` | `string` | `"max.mustermann@dhbw.de"` |
| `true` | `array` | `["max@dhbw.de", "anna@dhbw.de"]` |

### `extract`

Bestimmt welches Nutzer-Attribut als Wert übergeben wird:

| Wert | Ausgabe |
|---|---|
| `email` | E-Mail-Adresse (Standard) |
| `name` | Username |

### Abhängigkeit zu `deploy-strategy`

Ein `user-picker` mit `multi: true` in `parameters.general` ist Voraussetzung für `one-per-user`.
Siehe [Deploy-Strategien](Deploy-Strategien#one-per-user).

### Vollständiges Beispiel

```yaml
- name: students
  type: array
  required: true
  description: "Studierende"
  x-ui:
    group_id: general
    icon: Users
    placeholder: "Studierende auswählen..."
    widget:
      type: user-picker
      multi: true
      extract: email
```

---

## `group-builder`

Ermöglicht das Erstellen benannter Gruppen aus Nutzern des CloudStore-Nutzerpools.
Gibt ein `map(list(string))`-Objekt an Terraform zurück.

```yaml
x-ui:
  widget:
    type: group-builder
    extract: email
```

### `extract`

Identisch zu `user-picker`: bestimmt welches Nutzer-Attribut als Value verwendet wird.

### Terraform-Ausgabe

```hcl
student_groups = {
  "Gruppe A" = ["max@dhbw.de", "anna@dhbw.de"]
  "Gruppe B" = ["tom@dhbw.de"]
}
```

### Voraussetzung

Setzt `type: groups` am Parameter voraus.

### Abhängigkeit zu `deploy-strategy`

Ein `group-builder` in `parameters.general` ist Voraussetzung für `one-per-group`.
Siehe [Deploy-Strategien](Deploy-Strategien#one-per-group).

### Vollständiges Beispiel

```yaml
- name: student_groups
  type: groups
  required: true
  description: "Projektgruppen"
  x-ui:
    group_id: general
    icon: Users
    widget:
      type: group-builder
      extract: email
```
