# Outputs

Nach einem Deployment liefert Terraform Ausgabewerte zurück — zum Beispiel die URL der App,
einen SSH-Befehl oder generierte Credentials. Das `outputs`-Array in der `template.yaml`
beschreibt welche dieser Terraform-Outputs der Appstore kennen, speichern und anzeigen soll.

Outputs haben keinen Einfluss auf den Deployment-Prozess selbst. Sie steuern ausschließlich
was danach im Deployment-Detail sichtbar ist und welche Werte optional per E-Mail versandt werden können.

Definiert welche Terraform-Outputs nach dem Deployment gespeichert und im Deployment-Detail angezeigt werden.

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

---

## Felder

### `name`

**Typ:** `string` — Pflicht

Muss exakt dem Terraform Output-Namen entsprechen.

```hcl
# terraform/outputs.tf
output "app_url" {
  value = "https://${var.app_name}.cloudstore.example.com"
}
```

```yaml
outputs:
  - name: app_url   # muss "app_url" heißen
```

---

### `description`

**Typ:** `string`

Angezeigter Label im Deployment-Detail.

---

### `display`

**Typ:** `boolean`

| Wert | Verhalten |
|---|---|
| `true` | Output wird im Deployment-Detail angezeigt |
| `false` | Output wird gespeichert aber nicht direkt angezeigt (z.B. interne System-IDs) |

---

### `sensitive`

**Typ:** `boolean` — Standard: `false`

Markiert den Output als sensibel (Passwörter, SSH-Keys, Tokens).
Sensitive Outputs sind im E-Mail-Versand-Schritt standardmäßig deaktiviert und werden seperat gespeichert.

```yaml
outputs:
  - name: admin_credentials
    description: "Admin-Zugangsdaten"
    sensitive: true
    display: false
```

---

## Typische Patterns

```yaml
outputs:
  # Interne ID — gespeichert, nicht angezeigt
  - name: instance_id
    description: "System ID der Instanz"
    display: false

  # Direkter Zugriff — angezeigt
  - name: app_url
    description: "Web-Server URL"
    display: true

  # SSH-Zugang — angezeigt, aber nicht automatisch per E-Mail
  - name: ssh_command
    description: "SSH Befehl für Zugriff"
    display: true

  # Credentials — gespeichert, sensibel, E-Mail opt-in
  - name: admin_credentials
    description: "Admin-Zugangsdaten"
    sensitive: true
    display: false
```
