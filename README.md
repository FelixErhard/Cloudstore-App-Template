# Cloudstore App-Template

Dieses Repository enthält das Template-Schema für den CloudStore-Appstore.
Eine `template.yaml` beschreibt eine deploybare App: welche Parameter der Nutzer konfigurieren kann,
wie das Formular aussieht und welche Deployment-Modi zur Verfügung stehen.

## Dokumentation

Die vollständige Entwicklerdokumentation befindet sich im **[Wiki](../../wiki)**.

| Seite | Inhalt |
|---|---|
| [Home](../../wiki/Home) | Einstieg, Konzept und Deployment-Workflow |
| [Template-Struktur](../../wiki/Template-Struktur) | Alle Top-Level-Felder als Referenz |
| [Parameter-Typen](../../wiki/Parameter-Typen) | `string`, `number`, `boolean`, `array`, `selection`, `groups` |
| [x-ui Referenz](../../wiki/x-ui-Referenz) | UI-Steuerung: Gruppen, Sichtbarkeit, Layouts, Hinweise |
| [Widgets](../../wiki/Widgets) | `user-picker` & `group-builder` |
| [Deploy-Strategien & Backend-Features](../../wiki/Deploy-Strategien) | `deploy-strategy`, `email_credentials` |
| [Outputs](../../wiki/Outputs) | Terraform-Outputs definieren und anzeigen |
| [Vollständiges Beispiel](../../wiki/Vollstaendiges-Beispiel) | Kommentiertes Node.js-Template als Kopiervorlage |

## Repo-Inhalt

```
template.yaml        # Referenz-Template mit allen Features
terraform/           # Beispiel-Terraform-Konfiguration
wiki/                # Wiki-Quellseiten (gespiegelt auf GitHub Wiki)
```
