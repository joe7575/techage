# TA3: Ölzeitalter

Bei TA3 gilt es, die Dampf-betriebenen Maschinen durch leistungsfähigere und mit elektrischem Strom betriebene Maschinen abzulösen.

Dazu musst du Kohlekraftwerke und Generatoren bauen. Bald wirst du sehen, dass dein Strombedarf nur mit Öl-betriebenen Kraftwerken zu decken ist. Also machst du dich auf die Suche nach Erdöl. Bohrtürme und Ölpumpen helfen die, an das Öl zu kommen. Schienenwege dienen dir zum Öltransport bis in die Kraftwerke.

Das Industrielle Zeitalter ist auf seinem Höhepunkt.



## Kohlekraftwerk

Das Kohlekraftwerk besteht aus mehreren Blöcken und muss wie im Plan rechts abgebildet, zusammen gebaut werden. Dazu werden die Blöcke TA3 Kohlekraftwerks-Feuerbox, TA3 Boiler oben, TA3 Boiler unten, TA3 Turbine, TA3 Generator und TA3 Kühler benötigt.

Der Boiler muss mit Wasser gefüllt werden. Dazu bis zu 10 Eimer Wasser in den Boiler füllen.
Die Feuerbox muss mit Kohle, Holzkohle oder Erdöl gefüllt werden.
Wenn das Wasser heiß ist, kann das Ventil am Boiler geöffnet und anschließend die Generator gestartet werden.

Das Kraftwerk liefert eine Leistung von 80 ku und kann mit Kohle, Holzkohle oder Erdöl betrieben werden.

[coalpowerstation](/plan/)


### TA3 Kohlekraftwerks-Feuerbox

Teil des Kraftwerk. 
Die Feuerbox muss mit Kohle, Holzkohle oder Erdöl gefüllt werden. Die Brenndauer ist abhängig von der Leistung, die vom Kraftwerk angefordert wird. Unter Volllast brennt Kohle 20 s, Holzkohle 60 s und Erdöl 20 s. Unter Teillast entsprechend länger (50% Last = doppelte Zeit).

[ta3_firebox](/image/)


### TA3 Boiler unten/oben

Teil des Kraftwerk.  Muss mit Wasser gefüllt werden. Wem kein Wasser mehr vorhanden ist oder die Temperatur zu weit absinkt, schaltet sich der Boiler ab.

[ta3_boiler](/image/)


### TA3 Turbine

Teil des Kraftwerk. Muss neben den Generator gesetzt und über Dampfleitungen mit dem Boiler und dem Kühler, wie im Plan abgebildet, verbunden werden.

[ta3_turbine](/image/)


### TA3 Generator

Dient zur Stromgewinnung. Muss über Stromkabel und Verteilerboxen mit den Maschinen verbunden werden.

[ta3_generator](/image/)


### TA3 Kühler

Dient zur Abkühlung des heißen Dampfs aus der Turbine.  Muss über Dampfleitungen mit dem Boiler und der Turbine, wie im Plan abgebildet, verbunden werden.

[ta3_cooler](/image/)


## Eletrischer Strom

In TA3 (und TA4) werden die Maschinen mit Strom angetrieben. Dazu müssen die Maschinen und Generatoren mit Stromkabel verbunden werden.
Tech Age besitzt 2 Arten von Stromkabel:

- Isolierte Kabel (TA Stromkabel) für die lokale Verkabelung im Boden oder in Gebäuden. Diese Kabel lassen sich in der Wand oder im Boden verstecken (können mit der Kelle "verputzt" werden).
- Überlandleitungen (TA Stromleitung) für Freiluftverkabelung über große Strecken. Diese Kabel sind geschützt, können also von anderen Spielern nicht entfernt werden.

Verbraucher aber auch Generatoren können in einem Stromnetzwerk parallel betrieben werden. Mit Hilfe der Verteilerboxen können so große Netzwerke aufgebaut werden.
Wird zu wenig Strom bereitgestellt, gehen Teile der Verbraucher aus, bzw. Lampen können flackern.
In diesem Zusammenhang ist auch wichtig, dass die Funktionsweise von Forceload Blöcken verstanden wurde, denn Generatoren liefern bspw. nur Strom, wenn der entsprechende Map-Block geladen ist. Dies kann mit einen Forceload Block erzwungen werden.

[ta3_powerswitch](/image/)


### TA Stromkabel

Für die lokale Verkabelung im Boden oder in Gebäuden. Abzweigungen können mit Hilfe von Verteilerboxen realisiert werden. Die maximale Kabellänge zwischen Maschinen oder Verteilerboxen beträgt 1000 m. Es können maximale 1000 Knoten in einem Strom-Netzwerk verbunden werden. Als Knoten zählen alle Generatoren, Akkus, Verteiler und Maschinen.

Da die Stromkabel nicht automatisch geschützt sind, wird für längere Strecken die Überlandleitungen (TA Stromleitung) empfohlen.

Stromkabel können mit der Kelle verputzt also in der Wand oder im Boden versteckt werden. Als Material zum Verputzen können alle Stein, Clay und sonstige Blöcke ohne Intelligenz genutzt werden. Erde (dirt) geht nicht, da Erde zu Gras oder ähnlichem konvertiert werden kann, was die Leitung zerstören würde.

Zum Verputzen muss mit der Kelle auf das Kabel geklickt werden. Das Material, mit dem das Kabel verputzt werden soll, muss sich im Spieler-Inventar ganz links befinden.

Die Kabel können wieder sichtbar gemacht werden, indem man mit der Kelle wieder auf den Block klickt.

Außer Kabel können auch die TA Verteilerbox und die TA Stromschalterbox verputzt werden.

[ta3_powercable](/image/)


### TA Verteilerbox

Mit der Verteilerbox kann Strom in bis zu 6 Richtungen verteilt werden. Verteilerboxen können auch mit der Kelle verputzt (versteckt) und wieder sichtbar gemacht werden.
Wird mit dem TechAge Info Werkzeug (Schraubenschlüssel) auf die Verteilerbox geklickt, wird angezeigt, wieviel Leistung die Generatoren liefern bzw. die Verbraucher im Netzwerk beziehen. 

[ta3_powerjunction](/image/)


### TA Stromleitung

Mit der TA Stromleitung und den Strommasten können halbwegs realistische Überlandleitungen realisiert werden. Die Strommasten-Köpfe dienen gleichzeitig zum Schutz der Stromleitung (Protection).  Dazu muss mindestens alle 16 m ein Masten gesetzt werden. Der Schutz gilt aber nur die die Stromleitung und die Masten, alle anderen Blöcke in diesem Bereich sind dadurch nicht geschützt.

[ta3_powerline](/image/)


### TA Strommast
Dient zum Bauen von Strommasten. Ist durch den Strommast-Kopf vor Zerstörung geschützt und kann nur vom Besitzer wieder abgebaut werden.

[ta3_powerpole](/image/)


### TA Strommastkopf 
Hat bis zu vier Arme und erlaubt damit, Strom in bis zu 6 Richtungen weiter zu verteilen.
Der Strommastkopf schützt Stromleitungen und Masten in einem Radius von 8 m.

[ta3_powerpole4](/image/)


### TA Strommastkopf 2 

Dieser Strommastkopf hat nur 2 Arme und wird für die Überlandleitungen genutzt. 
Der Strommastkopf schützt Stromleitungen und Masten in einem Radius von 8 m.

[ta3_powerpole2](/image/)


### TA Stromschalter/Stromschalter klein

Mit dem Schalter kann der Strom ein- und ausgeschaltet werden. Der Schalter muss dazu auf eine Stromschalterbox gesetzt werden. Die Stromschalterbox muss dazu auf beiden Seiten mit dem Stromkabel verbunden sein.

[ta3_powerswitch](/image/)


### TA Stromschalterbox

siehe TA Stromschalter.

[ta3_powerswitchbox](/image/)


### TA3 Kleiner Stromgenerator

Der kleine Stromgenerator wird mit Erdöl betrieben und kann für kleine Verbraucher mit bis zu 12 ku genutzt werden. Unter Volllast brennt Erdöl 100 s. Unter Teillast entsprechend länger (50% Last = doppelte Zeit).

[ta3_tinygenerator](/image/)


### TA3 Akku Block

Der Akku Block dient zur Speicherung von überschüssiger Energie und gibt bei Stromausfall automatisch Strom ab (soweit vorhanden).
Der Akku Block ist eine sekundäre Stromquelle. Das bedeutet, bei Strombedarf werden zuerst die Generatoren genutzt. Nur wenn der Strom im Netz nicht ausreicht, springt der Aku Block ein. Das Gleiche gilt auch für die Stromaufnahme. Daher kann auch kein Akku mit einem anderen Akku geladen werden.
Der Akku liefert 10 ku bzw. nimmt 10 ku auf.
Bei Volllast kann ein Akku 400 s lang Strom aufnehmen und wenn er voll ist, auch wieder abgeben. Dies entspricht 8 h bei einem normalen Spieltag von 20 min.

[ta3_akkublock](/image/)


### TA3 Strom Terminal



## Industrieofen

### TA3 Ofen-Feuerkiste

### TA3 Ofenoberteil

### TA3 Gebläse


## Öl-Anlagen

### TA3 Ölexplorer 

### TA3 Ölbohrkiste

### TA3 Ölpumpe

### TA3 Bohrgestänge


## Logik-/Schalt-Blöcke

### TA3 Taster/Schalter

### TA3 Logikblock

### TA3 Wiederholer

### TA3 Sequenzer

### TA3 Timer

### TA3 Terminal


## Detektoren

### TA3 Detektor

### TA3 Wagen Detektor

### TA3 Block Detektor

### TA3 Spieler Detektor


## TA3 Maschinen

### TA3 Autocrafter

### TA3 Verteiler

### TA3 Elektronikfabrik

### TA3 Trichter

### TA3 Kiessieb

### TA3 Mühle

### TA3 Flüssigkeitensammler

