# CloudStore App-Template – Dokumentation

Willkommen im Wiki des CloudStore App-Template-Projekts.
Hier findest du alle Informationen, um eigene App-Templates für den CloudStore-Appstore zu erstellen.

## Wie ein Template funktioniert

Ein Template ist eine einzige `template.yaml`-Datei. Sie hat drei klar getrennte Aufgaben:

**`parameters`** — definiert die Eingabefelder des Konfigurationsassistenten.
Jeder Parameter wird direkt als Terraform-Variable übergeben. Der `name` muss exakt
dem Variablen-Namen in der Terraform-Konfiguration entsprechen.

**`x-ui`** — steuert ausschließlich wie ein Parameter im Formular dargestellt wird:
Gruppierung, Reihenfolge, Sichtbarkeit, Pflichtfeld-Logik, Icons, Hinweistexte.
`x-ui` hat keinen Einfluss auf Terraform — es ändert nur was der Nutzer sieht und wie.

**`outputs`** — beschreibt welche Terraform-Outputs nach dem Deployment
gespeichert und im Deployment-Detail angezeigt werden (z.B. App-URL, SSH-Befehl, Credentials).

Daneben steuern `deploy-strategy` und `email_credentials` Backend-Features
(Deployment-Modi, E-Mail-Versand von Zugangsdaten).

## Schnellnavigation

| Seite | Inhalt |
|---|---|
| [Architektur & Konzept](Architektur-und-Konzept) | Wie `template.yaml` mit Terraform, UI und Backend zusammenspielt |
| [Template-Struktur](Template-Struktur) | Vollständige YAML-Dateistruktur als Referenz |
| [Parameter-Typen](Parameter-Typen) | `string`, `number`, `boolean`, `array`, `selection`, `groups` |
| [x-ui Referenz](x-ui-Referenz) | Alle UI-Steuerungsfelder: Gruppen, Sichtbarkeit, Layouts, Hinweise |
| [Widgets](Widgets) | Spezialisierte Eingabekomponenten: `user-picker` & `group-builder` |
| [Deploy-Strategien & Backend-Features](Deploy-Strategien) | `deploy-strategy`, `email_credentials` und ihre Voraussetzungen |
| [Outputs](Outputs) | Terraform-Outputs im Template definieren und anzeigen |
| [Vollständiges Beispiel](Vollstaendiges-Beispiel) | Kommentiertes Node.js-Template als Kopiervorlage |

## Einstieg

Ein minimales Template braucht:

1. Metadaten (`name`, `display_name`, `description`, `version`)
2. Terraform-Konfiguration (`terraform.working_dir`)
3. Mindestens einen Parameter in `parameters`

Das vollständige Referenz-Template liegt im Repo unter `template.yaml`.
