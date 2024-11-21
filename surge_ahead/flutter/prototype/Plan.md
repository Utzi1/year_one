# Spezifikationen

* Sehr unkompliziertes Flutter-Dashboard in einem Pacman Container
* Dieses soll mit einer Redis-DB in einem anderen Container kommunizieren
* Es soll die möglickeit bestehen, daten in die Redis-DB zu schreiben und zu lesen

# Umsetzung
## Redis-Container: 

Für den Redis-Container wird das offizielle Redis-Image verwendet.
Dieses Image wird vom Docker-Hub gepullt, mit dem etwas unspekatkulären Namen `redis-container` versehen und auf Port 6379 des Hosts gemappt:

```bash
docker run --name redis-container -p 6379:6379 -d redis
```

## Flutter-Projekt:

Für das Flutter-Projekt wird dieses erweckt:

```bash
flutter create flutter-dashboard
cd flutter-dashboard
```

Anschließend wird die `pubspec.yaml` um das `redis`-Package erweitert:

```yaml 
dependencies:
  flutter:
    sdk: flutter
  redis: ^4.0.0
```

Es kann sein, dass die Version angepasst werden muss, da die Versionen von Flutter und dem Redis-Package nicht immer kompatibel sind.

Und um die dependencies zu installieren:

```bash
flutter pub get
```

## Dashboard:

Das Dashboard wird in der `main.dart` implementiert.
Hierbei wird das Dashboard in erster Linie zur Darstellung der Daten verwendet.
Dennoch wird zu Studienzwecken auch die Möglichkeit implementiert, Daten in die Redis-DB zu schreiben, dieses Feture ist an die dateneingabe im ursprünglichen Graphana-Dashboard angelehnt.

Für den Anfang jedoch wird eine einfache Version ohne viel 
