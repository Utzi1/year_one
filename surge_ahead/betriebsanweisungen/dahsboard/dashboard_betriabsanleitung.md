# Anforderungen

Gebrauchsanweisung, Anhang XV Kap. II 2.2. MDR
Herstellerangaben zur Installation, Wartung, Einhaltung von Hygienenormen und Verwendung, einschließlich Lagerungs- und Handhabungsbestimmungen, und - soweit diese Informationen vorliegen - die auf der Kennzeichnung anzubringenden Informationen und die Gebrauchsanweisung, die zusammen mit dem Produkt beim Inverkehrbringen bereitzustellen ist. Des Weiteren Informationen über gegebenenfalls erforderliche einschlägige Schulungen.

# Installation

Installation der Software auf dem muss durch geschultes Personal erfolgen.
Es wird empfohlen, dass die Installation durch einen Techniker des Herstellers erfolgt.
Hierbei empfehlen wir das Produkt in einem Docker-Container zu installieren.
Das Produkt selbst verwendet mehrere Module der Kategrorie "Software of unknown provenance".

## im docke

## Requirements

- Docker
- Docker-Compose
- Grafana
- Grafana-Image
- Grafana-Plugins
- Grafana-Data-Sources
- Grafana-Config
- Grafana-Data
- Grafana-Data-Volume
- Redis
- python

# Geriatrisches Co-Management Dashboard

## Überblick
Dieses Dashboard dient der Visualisierung und Überwachung patientenbezogener Daten im Rahmen des geriatrischen Co-Managements. Es ermöglicht die ganzheitliche Betrachtung von Patientendaten mit besonderem Fokus auf geriatrische Aspekte.

## Zugang zum Dashboard
Das Dashboard ist über den Webbrowser über die Grafana-Instanz erreichbar
Anmeldung mit Ihren persönlichen Zugangsdaten erforderlich
Bei Zugangsproblemen wenden Sie sich an die IT-Abteilung

## Grundlegende Navigation

###  Patientenauswahl

Oben im Dashboard können Sie die Station (AVC, UCH, URO oder TEST) auswählen
Der Status filtert Patienten (Aktuell, Entlassen, Dropout, Abgeschlossen)
Aus dem Dropdown-Menü Patient wählen Sie den gewünschten Patienten aus

### Zeitraumauswahl
Im oberen Bereich können Sie den angezeigten Zeitraum anpassen
Die Funktion "Autofocus Time" passt den Zeitraum automatisch an die vorhandenen Labordaten an

## Überblick der Dashboardbereiche
Das Dashboard ist in folgende Hauptbereiche gegliedert:

### Allgemein
Patienteninformationen: Zeigt grundlegende Daten wie Geburtsjahr, Körpergröße, Gewicht, BMI und Isolationsstatus
Diagnosen: Darstellung der ICD-10 kodierten Haupt- und Nebendiagnosen
Medikation: Auflistung der aktuellen Medikamente mit FORTA-Bewertung (Überversorgung/Unterversorgung)
Patientenzentrierte Ziele: Visualisierung der individuellen Behandlungsziele
Laborwerte: Graphische Darstellung wichtiger Laborparameter im Zeitverlauf
Prozeduren: Auflistung durchgeführter medizinischer Eingriffe

### Geriatrisches Co-Management
Sozialanamnese: Übersicht zur sozialen Situation des Patienten (Wohnverhältnisse, Hilfsmittel, Unterstützungsbedarf)
Frailty und Vulnerabilität: Visualisierung von Frailty-Scores (CFS) und Vulnerabilität (ISAR)
Delir-Risiko: Anzeige des Delir-Risikos mit prädiktiven Faktoren
Kognition: Übersicht zu kognitiven Funktionen (MoCA), Depression und Gedächtnisverlust
Mobilität: Information zu Stürzen, Mobilisierungsgrad und Funktionalitätserhalt
ADL (Aktivitäten des täglichen Lebens): Darstellung der Barthel-Index-Entwicklung
Harnkontinenz: Information zur Katheterversorgung
Malnutrition & Dysphagie: Status der Ernährungssituation und Schluckfunktion
Schmerz: NRS-Schmerzskala im Zeitverlauf

## Detaillierte Funktionsbeschreibung

### Medikationsübersicht

Die Medikamentenliste zeigt alle erfassten Medikamente mit Dosierung und Applikationsform
Die FORTA-Bewertung kennzeichnet potentielle Risiken (rot markiert):
Überversorgung: Medikamente mit ungünstigem Risiko-Nutzen-Verhältnis
Unterversorgung: Fehlende, aber indizierte Medikation

### Laborwerte
Zeitliche Entwicklung wichtiger Parameter wie Hämoglobin, Leukozyten, CRP, Kreatinin, eGFR, Elektrolyte, Albumin und Blutzucker
Farbliche Kennzeichnung der eGFR nach Schweregrad

### Delir-Management
Das Delir-Prädiktionsmodell zeigt das individuelle Delir-Risiko
Darstellung der wichtigsten Risikofaktoren (rot) und protektiven Faktoren (grün)
Verlauf der 4AT-Scores zur Delir-Erkennung im Zeitverlauf

### Mobilität und ADL
Visualisierung der Barthel-Index-Werte im Zeitverlauf (0-100 Punkte)
Darstellung der Life-Space-Assessment-Werte zur Mobilität
Informationen zu Stürzen und Sturzrisiko

## Datenaktualisierung
Das Dashboard aktualisiert die Daten automatisch alle 15 Minuten
Manuelle Aktualisierung durch Klicken auf das Aktualisierungssymbol rechts oben möglich

## Fehlerbehandlung
Bei Fehlern oder Unstimmigkeiten:

Prüfen Sie, ob alle Filterkriterien korrekt eingestellt sind
Aktualisieren Sie die Seite (Browser-Refresh)
Bei anhaltenden Problemen wenden Sie sich an den zuständigen Ansprechpartner

## Datenschutz
Das Dashboard enthält sensible Patientendaten
Sperren Sie Ihren Arbeitsplatz beim Verlassen
Geben Sie Ihre Zugangsdaten nicht an Dritte weiter
