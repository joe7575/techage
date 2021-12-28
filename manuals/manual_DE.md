# Tech Age Mod

Tech Age ist eine Technik-Mod mit 5 Entwicklungsstufen:

TA1: Eisenzeitalter (Iron Age) 
Benutze Werkzeuge und Hilfsmittel wie Köhler, Kohlebrenner, Kiessieb, Hammer, Hopper um notwendige Erze und Metalle zu schürfen und zu verarbeiten.

TA2: Dampfzeitalter (Steam Age)
Baue eine Dampfmaschine mit Antriebsachsen und betreibe damit deine ersten Maschinen zur Verarbeitung von Erzen.

TA3: Ölzeitalter (Oil Age)
Suche und fördere Öl, baute Schienenwege zur Ölbeförderung. Ein Kraftwerk liefert den notwendigen Strom für deine Maschinen. Elektrisches Licht erhellt deine Industrieanlagen.

TA4: Gegenwart (Present)
Regenerative Energiequellen wie Wind, Sonne und Biokraft helfen dir, das Ölzeitalter zu verlassen. Mit modernen Technologien und intelligenten Maschinen machst du dich auf in die Zukunft.

TA5: Zukunft (Future)
Maschinen zur Überwindung von Raum und Zeit, neue Energiequellen und andere Errungenschaften prägen dein Leben.


Hinweis: Mit Klicken auf die Pluszeichen kommst du in die Unterkapitel dieser Anleitung.

[techage_ta4|image]



## Hinweise

Diese Dokumentation ist sowohl "ingame" (Block Konstruktionsplan) als auch auf GitHub als MD-Files verfügbar.

- Link: https://github.com/joe7575/techage/wiki

Die Konstruktionspläne (Diagramme) für den Aufbau der Maschinen sowie die Bilder sind aber nur ingame verfügbar.

Bei Tech Age musst du von vorne beginnen. Nur mit den Items aus TA1 kannst du TA2 Blöcke herstellen, für TA3 benötigst du die Ergebnisse aus TA2, usw.

In TA2 laufen die Maschinen nur mit Antriebsachsen.

Ab TA3 laufen die Maschinen mit Strom und besitzen eine Kommunikationsschnittstelle zur Fernsteuerung.

Mit TA4 kommen weitere Stromquellen dazu, aber auch höhere logistische Herausforderungen (Stromtrassen, Item Transport).



## Änderungen ab Version 1.0

Ab V1.0 (17.07.2021) hat sich folgendes geändert:

- Der Algorithmus zur Berechnung der Stromverteilung hat sich geändert. Energiespeichersystem werden dadurch wichtiger. Diese gleichen Schankungen aus, was bei größeren Netzen mit mehreren Generatoren wichtig wird. 
- Aus diesem Grund hat TA2 seinen eigenen Energiespeicher erhalten.
- Die Akkublöcke aus TA3 dienen auch als Energiespeicher. Ihre Funktionsweise wurde entsprechend angepasst.
- Das TA4 Speichersystem wurde überarbeitet. Die Wärmetauscher (heatexchanger) haben eine neue Nummer bekommen,  da die Funktionalität vom unteren in den mittleren Block verschoben  wurde. Sofern diese ferngesteuert wurden, muss die Knotennummer angepasst  werden. Die Generatoren haben kein eigenes Menü mehr, sondern werden nur noch über den Wärmetauscher ein-/ausgeschaltet.  Wärmetauscher und Generator müssen jetzt am gleichen Netz hängen!
- Mehrere Stromnetze können jetzt über einen TA4 Transformator Blöcke gekoppelt werden.
- Neu ist auch ein TA4 Stromzähler Block für Unternetze.

### Tipps zur Umstellung

Viele weitere Blöcke haben kleinere Änderungen bekommen. Daher kann es sein, dass Maschinen oder Anlagen nach der Umstellung  nicht gleich wieder anlaufen. Sollte es zu Störungen kommen, helfen folgende Tipps:

- Maschinen aus- und wieder eingeschalten
- ein Stromkabel-Block entfernen und wieder setzen
- den Block ganz entfernen und wieder setzen
- mindestens ein Akkublock oder Speichersystem in jedes Netzwerk



## Erze und Mineralien

Techage fügt dem Spiel einige neue Items hinzu:

- Meridium - eine Legierung zur Herstellung von leuchtenden Werkzeugen in TA1
- Usmium - ein Erz, was in TA2 gefördert und für TA3 benötigt wird
- Baborium - ein Metall, welches für Rezepte in TA3 benötigt wird
- Erdöl - wird in TA3 benötigt
- Bauxit - ein Aluminiumerz, was in TA4 zur Herstellung von Aluminium benötigt wird
- Basalt - entsteht, wenn sich Wasser und Lave berühren


### Meridium

Meridium ist eine Legierung aus Stahl und Mesekristallen. Meridium Ingots können mit dem Kohlebrenner aus Stahl und Mesesplitter hergestellt werden. Meridium leuchtet im Dunkeln. Auch Werkzeuge aus Meridium leuchten und sind daher im Untertagebau sehr hilfreich.

[meridium|image]


### Usmium

Usmium kommt nur als Nuggets vor und kann nur beim Waschen von Kies mit der TA2/TA3 Kieswaschanlage gewonnen werden.

[usmium|image]


### Baborium

Baborium wird nur im Untertagebau gewonnen. Baborium findet man nur in Stein in einer Höhe zwischen -250 und -340 Meter.
Baborium kann nur im TA3 Industrieofen geschmolzen werden.

[baborium|image]


### Erdöl

Erdöl kann nur mit Hilfe des Explorers gefunden und mit Hilfe entsprechender TA3 Maschinen gefördert werden. Siehe TA3.

[oil|image]


### Bauxit

Bauxit wird nur im Untertagebau gewonnen. Bauxit findet man nur in Stein in einer Höhe zwischen -50 und -500 Meter.
Es wird zur Herstellung von Aluminium benötigt, was vor allem in TA4 Verwendung findet.

[bauxite|image]


### Basalt

Basalt entsteht nur, wenn Lava und Wasser zusammen kommen.
Dazu sollte man am besten eine Anlage aufbauen, bei der eine Lava- und eine Wasserquelle zusammenfließen.
Dort wo sich beide Flüssigkeiten treffen, entsteht Basalt.
Einen automatisierten Basalt Generator kann man mit dem Sign Bot aufbauen.

[basalt|image]

