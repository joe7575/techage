# TA3: Ölzeitalter

Bei TA3 gilt es, die Dampf-betriebenen Maschinen durch leistungsfähigere und mit elektrischem Strom betriebene Maschinen abzulösen.

Dazu musst du Kohlekraftwerke und Generatoren bauen. Bald wirst du sehen, dass dein Strombedarf nur mit Öl-betriebenen Kraftwerken zu decken ist. Also machst du dich auf die Suche nach Erdöl. Bohrtürme und Ölpumpen helfen die, an das Öl zu kommen. Schienenwege dienen dir zum Öltransport bis in die Kraftwerke.

Das Industrielle Zeitalter ist auf seinem Höhepunkt.

[techage_ta3|image]


## Kohlekraftwerk / Ölkraftwerk

Das Kohlekraftwerk besteht aus mehreren Blöcken und muss wie im Plan rechts abgebildet, zusammen gebaut werden. Dazu werden die Blöcke TA3 Kraftwerks-Feuerbox, TA3 Boiler oben, TA3 Boiler unten, TA3 Turbine, TA3 Generator und TA3 Kühler benötigt.

Der Boiler muss mit Wasser gefüllt werden. Dazu bis zu 10 Eimer Wasser in den Boiler füllen.
Die Feuerbox muss mit Kohle oder Holzkohle gefüllt werden.
Wenn das Wasser heiß ist, kann der Generator gestartet werden.

Das Kraftwerk kann alternativ auch mit einem Ölbrenner ausgestattet und dann mit Öl betrieben werden.
Das Öl kann über eine Pumpe und Ölleitung nachgefüllt werden.

Das Kraftwerk liefert eine Leistung von 80 ku.

[coalpowerstation|plan]


### TA3 Kraftwerks-Feuerbox / Power Station Firebox

Teil des Kraftwerks. 
Die Feuerbox muss mit Kohle oder Holzkohle gefüllt werden. Die Brenndauer ist abhängig von der Leistung, die vom Kraftwerk angefordert wird. Unter Volllast brennt Kohle 20 s und Holzkohle 60 s. Unter Teillast entsprechend länger (50% Last = doppelte Zeit).

[ta3_firebox|image]


### TA3 Kraftwerks-Ölbrenner / TA3 Power Station Oil Burner

Teil des Kraftwerks. 

Der Ölbrenner kann mit Erdöl, Schweröl, Naphtha oder Benzin gefüllt werden. Die Brenndauer ist abhängig von der Leistung, die vom Kraftwerk angefordert wird. Unter Volllast brennt Erdöl 15 s, Schweröl 20 s, Naphtha 22 s und Benzin 25 s. 

Unter Teillast entsprechend länger (50% Last = doppelte Zeit).

Der Ölbrenner kann nur 50 Einheiten Kraftstoff aufnehmen. Ein zusätzlicher Öltank und eine Ölpumpe sind daher ratsam.


[ta3_oilbox|image]


### TA3 Boiler unten/oben

Teil des Kraftwerk.  Muss mit Wasser gefüllt werden. Wem kein Wasser mehr vorhanden ist oder die Temperatur zu weit absinkt, schaltet sich das Kraftwerk ab.

[ta3_boiler|image]


### TA3 Turbine

Die Turbine ist Teil des Kraftwerk. Sie muss neben den Generator gesetzt und über Dampfleitungen mit dem Boiler und dem Kühler, wie im Plan abgebildet, verbunden werden.

[ta3_turbine|image]


### TA3 Generator

Der Generator dient zur Stromerzeugung. Er muss über Stromkabel und Verteilerdosen mit den Maschinen verbunden werden.

[ta3_generator|image]


### TA3 Kühler / Cooler

Dient zur Abkühlung des heißen Dampfs aus der Turbine.  Muss über Dampfleitungen mit dem Boiler und der Turbine, wie im Plan abgebildet, verbunden werden.

[ta3_cooler|image]


## Elektrischer Strom

In TA3 (und TA4) werden die Maschinen mit Strom angetrieben. Dazu müssen die Maschinen, Speichersysteme und Generatoren mit Stromkabel verbunden werden.  
TA3 besitzt 2 Arten von Stromkabel:

- Isolierte Kabel (TA Stromkabel) für die lokale Verkabelung im Boden oder in Gebäuden. Diese Kabel lassen sich in der Wand oder im Boden verstecken (können mit der Kelle "verputzt" werden).
- Überlandleitungen (TA Stromleitung) für Freiluftverkabelung über große Strecken. Diese Kabel sind geschützt, können also von anderen Spielern nicht entfernt werden.

Mehrere Verbraucher, Speichersysteme und Generatoren können in einem Stromnetzwerk zusammen betrieben werden. Mit Hilfe der Verteilerdosen können so Netzwerke aufgebaut werden.
Wird zu wenig Strom bereitgestellt, gehen die Verbraucher aus.
In diesem Zusammenhang ist auch wichtig, dass die Funktionsweise von Forceload Blöcken verstanden wurde, denn bspw. Generatoren liefern nur Strom, wenn der entsprechende Map-Block geladen ist. Dies kann mit einen Forceload Block erzwungen werden.

In TA4 kommt noch ein Kabel für die Solaranlage hinzu.

[ta3_powerswitch|image]

### Bedeutung von Speichersystemen

Speichersysteme im Stromnetz erfüllen zwei Aufgaben:

- Um Bedarfsspitzen abzufangen: Alle Generatoren liefern immer gerade soviel Leistung, wie benötigt wird. Werden aber Verbraucher ein/ausgeschaltet oder kommt es aus anderen Gründen zu Bedarfsschwankungen, so können Verbraucher kurzzeitig ausfallen. Um dies zu verhindern, sollte immer mindestens ein Akkublock in jedem Netzwerk vorhanden sein. Dieser dient als Puffer und gleicht diese Schwankungen im Sekundenbereich aus.
- Um regenerative Energie zu speichern: Solar und Wind stehen nicht 24 Stunden am Tag zur Verfügung. Damit die Stromversorgung nicht ausfällt, wenn kein Strom produziert wird, müssen ein oder mehrere Speichersysteme im Netzwerk verbaut werden. Alternativ können die Lücken auch mit Öl/Kohle-Strom überbrückt werden. 

Ein Speichersystem gibt seine Kapazität in kud an, also ku pro day (Tag). Bspw. ein Speichersystem mit 100 kud liefert 100 ku einen Spieltag lang, oder auch 10 ku für 10 Spieltage.

Alle TA3/TA4 Energiequellen besitzen eine einstellbare Ladecharakteristik. Standardmäßig ist diese auf "80% - 100%" eingestellt. Dies bedeutet, dass die Leistung ab 80% Füllung des Speichersystems immer weiter reduziert wird, bis sie bei 100 % komplett abschaltet. Sofern Strom im Netzwerk benötigt wird, werden die 100 % nie erreicht, da die Leistung des Generators irgendwann auf den Strombedarf im Netzwerk abgesunken ist und damit das Speichersystem nicht mehr geladen, sondern nur noch die Verbraucher bedient werden.

Dies hat mehrere Vorteile:

- Die Ladecharakteristik ist einstellbar. Damit kann man bspw. Öl/Kohle Energiequellen bei 60% und die regenerativen Energiequellen erst bei 80% zurückfahren. Damit wird nur Öl/Kohle verbrannt, wenn nicht ausreichend regenerativen Energiequellen zur Verfügung stehen.
- Mehrere Energiequellen können parallel betrieben werden und werden dabei nahezu gleichmäßig belastet, denn alle Energiequellen arbeiten bspw. bis 80% Ladekapazität des Speichersystems mit ihrer vollen Leistung und fahren dann gleichzeitig ihre Leistung zurück.
- Alle Speichersysteme in einem Netzwerk bilden einen großen Puffer. An jedem Speichersystem aber auch am Strom Terminal kann immer die  Ladekapazität und der Füllungsgrad des gesamten Speichersystems in Prozent abgelesen werden. 

[power_reduction|image]




### TA Stromkabel / Electric Cable

Für die lokale Verkabelung im Boden oder in Gebäuden.  
Abzweigungen können mit Hilfe von Verteilerdosen realisiert werden. Die maximale Kabellänge zwischen Maschinen oder Verteilerdosen beträgt 1000 m. Es können maximale 1000 Knoten in einem Strom-Netzwerk verbunden werden. Als Knoten zählen alle Blöcke mit Stromanschluss, also auch Verteilerdosen.

Da die Stromkabel nicht automatisch geschützt sind, wird für längere Strecken die Überlandleitungen (TA Stromleitung) empfohlen.

Stromkabel können mit der Kelle verputzt also in der Wand oder im Boden versteckt werden. Als Material zum Verputzen können alle Stein-, Clay- und sonstige Blöcke ohne "Intelligenz" genutzt werden. Erde (dirt) geht nicht, da Erde zu Gras oder ähnlichem konvertiert werden kann, was die Leitung zerstören würde.

Zum Verputzen muss mit der Kelle auf das Kabel geklickt werden. Das Material, mit dem das Kabel verputzt werden soll, muss sich im Spieler-Inventar ganz links befinden.  
Die Kabel können wieder sichtbar gemacht werden, indem man mit der Kelle wieder auf den Block klickt.

Außer Kabel können auch die TA Verteilerdose und die TA Stromschalterbox verputzt werden.

[ta3_powercable|image]


### TA Verteilerdose / Electric Junction Box

Mit der Verteilerdose kann Strom in bis zu 6 Richtungen verteilt werden. Verteilerdosen können auch mit der Kelle verputzt (versteckt) und wieder sichtbar gemacht werden.

[ta3_powerjunction|image]


### TA Stromleitung / Power Line

Mit der TA Stromleitung und den Strommasten können halbwegs realistische Überlandleitungen realisiert werden. Die Strommasten-Köpfe dienen gleichzeitig zum Schutz der Stromleitung (Protection). Dazu muss alle 16 m oder weniger ein Masten gesetzt werden. Der Schutz gilt aber nur die die Stromleitung und die Masten, alle anderen Blöcke in diesem Bereich sind dadurch nicht geschützt.

[ta3_powerline|image]


### TA Strommast / Power Pole
Dient zum Bauen von Strommasten. Ist durch den Strommast-Kopf vor Zerstörung geschützt und kann nur vom Besitzer wieder abgebaut werden.

[ta3_powerpole|image]


### TA Strommastkopf / Power Pole Top
Hat bis zu vier Arme und erlaubt damit, Strom in bis zu 6 Richtungen weiter zu verteilen. 
Der Strommastkopf schützt Stromleitungen und Masten in einem Radius von 8 m.

[ta3_powerpole4|image]


### TA Strommastkopf 2 / Power Pole Top 2

Dieser Strommastkopf hat zwei feste Arme und wird für die Überlandleitungen genutzt. Er kann aber auch Strom nach unten und oben weiterleiten.
Der Strommastkopf schützt Stromleitungen und Masten in einem Radius von 8 m.

[ta3_powerpole2|image]


### TA Stromschalter / Power Switch

Mit dem Schalter kann der Strom ein- und ausgeschaltet werden. Der Schalter muss dazu auf eine Stromschalterbox gesetzt werden. Die Stromschalterbox muss dazu auf beiden Seiten mit dem Stromkabel verbunden sein.

[ta3_powerswitch|image]


### TA Stromschalter klein / Power Switch Small 

Mit dem Schalter kann der Strom ein- und ausgeschaltet werden. Der Schalter muss dazu auf eine Stromschalterbox gesetzt werden. Die Stromschalterbox muss dazu auf beiden Seiten mit dem Stromkabel verbunden sein.

[ta3_powerswitchsmall|image]


### TA Stromschalterbox / Power Switch Box

siehe TA Stromschalter.

[ta3_powerswitchbox|image]


### TA3 Kleiner Stromgenerator / Tiny Power Generator

Der kleine Stromgenerator wird mit Benzin betrieben und kann für kleine Verbraucher mit bis zu 12 ku genutzt werden. Unter Volllast brennt Benzin 150 s. Unter Teillast entsprechend länger (50% Last = doppelte Zeit).

Der Stromgenerator kann nur 50 Einheiten Benzin aufnehmen. Ein zusätzlicher Tank und eine Pumpe sind daher ratsam.


[ta3_tinygenerator|image]


### TA3 Akku Block /  Akku Box

Der Akku Block dient zur Speicherung von überschüssiger Energie und gibt bei Stromausfall automatisch Strom ab (soweit vorhanden).
Mehrere Akku Blocks zusammen bilden ein TA3 Energiespeichersystem. Jeder Akku Block hat eine Anzeige für den Ladezustand und für die gespeicherte Ladung, wobei hier immer die Werte für das gesamte Netzwerk angezeigt werden. Die gespeicherte Ladung wird in "kud" also "ku-days" angezeigt (analog zu kWh)  5 kud entspricht damit bspw. 5 ku für einen Spieltag (20 min) oder 1 ku für 5 Spieltage.

Ein Akku Block hat 3.33 kud.

[ta3_akkublock|image]


### TA3 Strom Terminal / Power Terminal

Das Strom-Terminal muss mit dem Stromnetz verbunden werden. Es zeigt Daten aus dem Stromnetz an.

In der oberen Hälfte werden die wichtigsten Größen ausgegeben:

- aktuelle/maximale Generatorleistung
- aktueller Stromaufnahme aller Verbraucher
- aktueller Ladestrom in/aus dem Speichersystems
- aktuellen Ladezustand des Speichersystems in Prozent

In der unteren Hälfte wird die Anzahl der Netzwerkblöcke ausgegeben.

Über den Reiter "console" können weitere Daten zu den Generatoren und Speichersystemen abgefragt werden.

[ta3_powerterminal|image]


### TA3 Elektromotor / TA3 Electric Motor

Um TA2 Maschinen über das Stromnetz betreiben zu können, wird der TA3 Elektromotor benötigt. Dieser wandelt Strom in Achsenkraft um.
Wird der Elektromotor nicht mit ausreichend Strom versorgt, geht er in einen Fehlerzustand und muss über einen Rechtsklick wieder aktiviert werden.

Das Elektromotor nimmt primär max. 40 ku an Strom auf und gibt sekundär max. 39 ku als Achsenkraft wieder ab. Er verbraucht also ein ku für die Umwandlung.

[ta3_motor|image]



## TA3 Industrieofen

Der TA3 Industrieofen dient als Ergänzung zu normalen Ofen (furnace). Damit können alle Waren mit "Koch" Rezepten, auch im Industrieofen hergestellt werden. Es gibt aber auch spezielle Rezepte, die nur im Industrieofen hergestellt werden können.
Der Industrieofen hat sein eigenes Menü zur Rezeptauswahl. Abhängig von den Waren im Industrieofen Inventar links kann rechts das Ausgangsprodukt gewählt werden.

Der Industrieofen benötigt Strom (für das Gebläse) sowie Schweröl/Benzin für den Brenner. Der Industrieofens und muss wie im Plan rechts abgebildet, zusammen gebaut werden.

Siehe auch TA4 Ofenheizung.

[ta3_furnace|plan]


### TA3 Ofen-Ölbrenner / Furnace Oil Burner

Ist Teil des TA3 Industrieofen.

Der Ölbrenner kann mit Erdöl, Schweröl, Naphtha oder Benzin betrieben werden. Die Brennzeit beträgt für Erdöl 65 s, Schweröl 80 s, Naphtha 90 s und Benzin 100 s.

Der Ölbrenner kann nur 50 Einheiten Kraftstoff aufnehmen. Ein zusätzlicher Tank und eine Pumpe sind daher ratsam.

[ta3_furnacefirebox|image]


### TA3 Ofenoberteil / Furnace Top

Ist Teil des TA3 Industrieofen. Siehe TA3 Industrieofen.

[ta3_furnace|image]


### TA3 Gebläse / Booster

Ist Teil des TA3 Industrieofen. Siehe TA3 Industrieofen.

[ta3_booster|image]


## Flüssigkeiten

Flüssigkeiten wie Wasser oder Öl können nur die spezielle Leitungen gepumpt und in Tanks gespeichert werden. Wie auch bei Wasser gibt es aber Behälter (Kanister, Fässer), in denen die Flüssig gelagert und transportiert werden kann.

Über die gelben Leitungen und Verbindungsstücke ist es auch möglich, mehrere Tanks zu verbinden. Allerdings müssen die Tanks den selben Inhalt haben und zwischen Tank, Pumpe und Verteiler muss immer mindestens eine gelbe Leitung sein.

Bspw. zwei Tanks direkt mit einem Verteilerstück zu verbinden, geht nicht.

Um Flüssigkeiten von Behältern nach Tanks umzufüllen, dient der Einfülltrichter. Im Plan ist dargestellt, wie Kanistern oder Fässer mit Flüssigkeiten über Schieber in einen Einfülltrichter geschoben werden. Im Einfülltrichter wird der Behälter geleert und die Flüssigkeit nach unten in den Tank geleitet. 

Der Einfülltrichter kann auch unter einen Tank gesetzt werden, um den Tank zu leeren.

[ta3_tank|plan]


### TA3 Tank / TA3 Tank

In einem Tank können Flüssigkeiten gespeichert werden. Ein Tank kann über eine Pumpe gefüllt bzw. geleert werden. Dazu muss die Pumpe über einer Leitung (gelbe Röhre) mit dem Tank verbunden sein.

Ein Tank kann auch von Hand gefüllt oder geleert werden, indem mit einem vollen oder leeren Flüssigkeitsbehälter (Fass, Kanister) auf den Tank geklickt wird. Dabei ist zu beachten, dass Fässer nur komplett gefüllt oder entleert werden können. Sind bspw. weniger als 10 Einheiten im Tank, muss dieser Rest mit Kanistern entnommen oder leergepumpt werden.

In einen TA3 Tank passen 1000 Einheiten oder 100 Fässer einer Flüssigkeit.

[ta3_tank|image]


### TA3 Pumpe / TA3 Pump

Mit der Pumpe können Flüssigkeiten von Tanks oder Behältern zu anderen Tanks oder Behältern gepumpt werden. Bei der Pumpe muss die Pumprichtung (Pfeil) beachtet werden. Über die gelben Leitungen und Verbindungsstücke ist es auch möglich, mehrere Tanks auf jeder Seite der Pumpe anzuordnen. Allerdings müssen die Tanks den selben Inhalt haben.

Die TA3 Pumpe pumpt 4 Einheiten Flüssigkeit alle zwei Sekunden.

Hinweis 1: Die Pumpe darf nicht direkt neben den Tank platziert werden. Es muss immer mindestens ein Stück gelbe Leitung dazwischen sein.

Hinweis 2: Nach dem Starten markiert die Pumpe 10 x die Blöcke, von und zu denen gepumpt wird.

[ta3_pump|image]


### TA Einfülltrichter / TA Liquid Filler

Um Flüssigkeiten zwischen Behältern und Tanks umzufüllen, dient der Einfülltrichter.

- wird der Einfülltrichter unter einen Tank gesetzt und werden leere Fässer mit einem Schieber oder von Hand in den Einfülltrichter gegeben, wird der Tankinhalt in die Fässer umgefüllt und die Fässer können ausgangsseitig wieder entnommen werden
- wird der Einfülltrichter auf einen Tank gesetzt und werden volle Fässer mit einem Schieber oder von Hand in den Einfülltrichter gegeben, werden diese in den Tank umgefüllt und die Fässer können ausgangsseitig wieder entnommen werden

Dabei ist zu beachten, dass Fässer nur komplett gefüllt oder entleert werden können. Sind bspw. weniger als 10 Einheiten im Tank, muss dieser Rest mit Kanistern entnommen oder leergepumpt werden.

[ta3_filler|image]

### TA4 Röhre / Pipe

Die gelben Röhren dienen zur Weiterleitung von Gas und Flüssigkeiten. 
Die maximale Leitungslänge beträgt 100 m.

[ta3_pipe|image]

### TA3 Rohr/Wanddurchbruch / TA3 Pipe Wall Entry Blöcke

Die Blöcke dienen als Wanddurchbrüche für Röhren, so dass keine Löcher offen bleiben.

[ta3_pipe_wall_entry|image]

### TA Ventil / TA Valve

Für die gelben Röhren gibt es ein Ventil, welches über Mausklicks geöffnet und geschlossen werden kann.
Das Ventil kann auch über on/off Kommandos angesteuert werden.

[ta3_valve|image]



## Öl-Förderung

Um deine Generatoren und Öfen mit Öl betreiben zu können, muss du zuerst nach Öl suchen und einen Bohrturm errichten und danach das Öl fördern.
Dazu dienen dir TA3 Ölexplorer, TA3 Ölbohrkiste und TA3 Ölpumpe.

[techage_ta3|image]


### TA3 Ölexplorer / Oil Explorer

Mit dem Ölexplorer kannst du nach Öl suchen. Dazu den Block auf den Boden setzen und mit Rechtsklick die Suche starten. Der Ölexplorer kann oberirdisch und unterirdisch in allen Tiefen eingesetzt werden.
Über die Chat-Ausgabe wird dir angezeigt, in welcher Tiefe nach Öl gesucht wurde und wie viel Öl (oil) gefunden wurde.
Du kannst mehrfach auf den Block klicken, um auch in tieferen Bereichen nach Öl zu suchen. Ölfelder haben eine Größe von 4000 bis zu 20000 Items.

Falls die Suche erfolglos war, musst du den Block ca. 16 m weiter setzen.
Der Ölexplorer sucht immer innerhalb des ganzen Map-Blocks und darunter nach Öl, in dem er gesetzt wurde. Eine erneute Suche im gleichen Map-Block (16x16 Feld) macht daher keinen Sinn.

Falls Öl gefunden wurde, wird die Stelle für den Bohrturm angezeigt. Du musst den Bohrturm innerhalb des angezeigten Bereiches errichten, die Stelle am besten gleich mit einem  Schild markieren und den ganzen Bereich gegen fremde Spieler schützen.

Gib die Suche nach Öl nicht zu schnell auf. Es kann wenn du Pech hast, sehr lange dauern, bis du eine Ölquelle gefunden hast.
Es macht auch keinen Sinn, einen Bereich den ein anderer Spieler bereits abgesucht hat, nochmals abzusuchen. Die Chance, irgendwo Öl zu finden, ist für alle Spieler gleich.

Der Ölexplorer kann immer wieder zur Suche nach Öl eingesetzt werden.

[ta3_oilexplorer|image]


### TA3 Ölbohrkiste / Oil Drill Box

Die Ölbohrkiste muss an die Stelle gesetzt werden, die vom Ölexplorer angezeigt wurde. An anderen Stellen nach Öl zu bohren ist zwecklos.
Wird auf den Button der Ölbohrkiste geklickt, wird über der Kiste ein Bohrturm errichtet. Dies dauert einige Sekunden.  
Die Ölbohrkiste hat 4 Seiten, bei IN muss das Bohrgestänge über Schieber angeliefert und bei OUT muss das Bohrmaterial abtransportiert werden. Über eine der anderen zwei Seiten muss die Ölbohrkiste mit Strom versorgt werden.

Die Ölbohrkiste bohrt bis zum Ölfeld (1 Meter in 16 s) und benötigt dazu 16 ku Strom.
Wurde das Ölfeld erreicht, kann der Bohrturm abgebaut und die Kiste entfernt werden.

[ta3_drillbox|image]


### TA3 Ölpumpe / Oil Pumpjack

An die Stelle der Ölbohrkiste muss nun die Ölpumpe platziert werden. Auch die Ölpumpe benötigt Strom (16 ku) und liefert alle 8 s ein Einheit Erdöl. Das Erdöl muss in einem Tank gesammelt werden. Dazu muss die Ölpumpe über eine Leitung (gelbe Röhre) mit dem Tank verbunden werden.
Ist alles Öl abgepumpt, kann auch die Ölpumpe wieder entfernt werden.

[ta3_pumpjack|image]


### TA3 Bohrgestänge / Drill Pipe

Das Bohrgestänge wird für die Bohrung benötigt. Es werden so viele Bohrgestänge Items benötigt wie als Tiefe für das Ölfeld angegeben wurde. Das Bohrgestänge ist nach der Bohrung nutzlos, kann aber auch nicht abgebaut werden und verbleibt im Boden. Es gibt aber ein Werkzeug, um die Bohrgestänge Blöcke wieder entfernen zu können (-> Werkzeuge -> TA3 Bohrgestängezange).

[ta3_drillbit|image]


### Öltank / Oil Tank

Der Öltank ist die große Ausführung des TA3 Tanks (siehe Flüssigkeiten -> TA3 Tank).

Der große Tank kann 4000 Einheiten Öl, aber auch jede andere Art von Flüssigkeit aufnehmen.

[oiltank|image]



## Öl-Transport

### Öl-Transport mit dem Tankwagen
Um Öl von der Ölquelle zur Ölverarbeitungsanlage zu befördern, können Tankwagen (tank carts) genutzt werden.  Ein Tankwagen kann direkt über Pumpen gefüllt bzw. geleert werden. In beiden Fällen muss die gelbe Röhre von oben mit dem Tankwagen verbunden werden.

Dazu sind folgende Schritte notwendig:

- Den Tankwagen vor den Prellbock setzen. Der Prellbock darf noch nicht mit einer Zeit programmiert sein, so dass der Tankwagen nicht automatisch losfährt
- Den Tankwagen über gelbe Röhren mit der Pumpe verbinden
- Pumpe einschalten
- Prellbock mit einer Zeit (10 - 20 s) programmieren

Diese Reihenfolge muss auf beiden Seiten /Füllen/Leeren) eingehalten werden.

[tank_cart|image]

### Öl-Transport mit Fässern über Minecarts
In die Minecarts können Kanister und Fässer geladen werden. Das Öl muss dazu zuvor in Fässer umgeladen werden. Die Ölfässer können direkt mit einem Schieber und Röhren in das Minecart geschoben werden (siehe Plan). Die leeren Fässer, welche per Minecart von der Entladestation zurück kommen, können über einen Hopper entladen werden, der unter der Schiene an der Haltestelle platziert wird.

Es ist mit dem Hopper nicht möglich, an **einer** Haltestelle sowohl die leeren Fässer zu entladen, als auch die vollen Fässer zu beladen. Der Hopper lädt die vollen Fässer sofort wieder aus. Daher ist es ratsam, jeweils 2 Stationen auf der Be- und Entladeseite einzurichten und den Minecart dann über eine Aufzeichnungsfahrt entsprechend zu programmieren.

Der Plan zeigt, wie das Öl in einen Tank gepumpt und über einen Einfülltrichter in Fässer umgefüllt und in Minecarts geladen werden kann.

Damit die Minecarts automatisch wieder starten, müssen die Prellböcke mit Stationsname und Wartezeit konfiguriert werden. Für das Entladen reichen 5 s. Da aber die Schieber immer für mehrere Sekunden in den Standby fallen, wenn kein Minecart  da ist, muss für das Beladen eine Zeit von 15 oder mehr Sekunden eingegeben werden.

[ta3_loading|plan]


### Tankwagen / Tank Cart

Der Tankwagen dient zum Transport von Flüssigkeiten. Es kann wie Tanks mit Pumpen gefüllt bzw. geleert werden.  In beiden Fällen muss die gelbe Röhre von oben mit dem Tankwagen verbunden werden.

In den Tankwagen passen 100 Einheiten.

[tank_cart|image]

### Kistenwagen / Chest Cart

Der Kistenwagen dient zum Transport von Items. Es kann wie Kisten über Schieber gefüllt bzw. geleert werden.

In den Kistenwagen passen 4 Stacks.

[chest_cart|image]



## Öl-Verarbeitung

Öl ist ein Stoffgemisch und besteht aus sehr vielen Komponenten. Über einen Destillationsturm kann das Öl in seine Hauptbestandteile wie Bitumen, Schweröl, Naphtha, Benzin und Gas zerlegt werden.
Die weitere Verarbeitung zu Endprodukten erfolgt im Chemischen Reaktor.

[techage_ta31|image]


### Destillationsturm / distiller tower

Der Destillationsturm muss wie im Plan rechts oben aufgebaut werden. 
Über den Basisblock wird das Bitumen abgelassen. Der Ausgang ist auf der Rückseite des Basisblocks (Pfeilrichtung beachten).
Auf diesen Basisblock kommen die "Destillationsturm" Blöcke mit den Nummern: 1, 2, 3, 2, 3, 2, 3, 4
An den Öffnungen von unten nach oben werden Schweröl, Naphtha und Benzin abgeleitet. Ganz oben wird das Propangas abgefangen.
Es müssen alle Öffnungen am Turm mit Tanks verbunden werden.
Der Aufkocher (reboiler) muss mit dem Block "Destillationsturm 1" verbunden werden.

Der Aufkocher benötigt Strom (nicht im Plan zu sehen)!


[ta3_distiller|plan]

#### Aufkocher / reboiler)

Der Aufkocher erhitzt das Erdöl auf ca. 400°C. Dabei verdampft es weitgehend und wird in den Destillationsturm zur Abkühlung geleitet.

Der Aufkocher benötigt 14 Einheiten Strom und produziert alle 16 s jeweils eine Einheit Bitumen, Schweröl, Naphtha, Benzin und Propangas.
Dazu muss der Aufkocher über einen Pumpe mit Erdöl versorgt werden.

[reboiler|image]


## Logik-/Schalt-Blöcke

Neben den Röhren für Warentransport, sowie den Gas- und Stromleitungen gibt es auch noch eine drahtlose Kommunikationsebene, über die Blöcke untereinander Daten austauschen können. Dafür müssen keine Leitungen gezogen werden, sondern die Verbindung zwischen Sender und Empfänger erfolgt nur über die Blocknummer. Alle Blöcke, die an dieser Kommunikation teilnehmen können, zeigen die Blocknummer als Info-Text an, wenn man mit dem Mauscursor den Block fixiert.
Welche Kommandos ein Block unterstützt, kann mit dem TechAge Info Werkzeug (Schraubenschlüssel) ausgelesen und angezeigt werden.
Die einfachsten Kommandos, die von fast allen Blöcken unterstützt werden, sind:

- `on` - Block/Maschine/Lampe einschalten
- `off` - Block/Maschine/Lampe ausschalten

Mir Hilfe des TA3 Terminal können diese Kommandos sehr einfach ausprobiert werden. Angenommen, eine Signallampe hat die Nummer 123.
Dann kann mit:

    cmd 123 on

die Lampe ein, und mit:

    cmd 123 off

die Lampe wieder ausgeschaltet werden. Diese Kommandos müssen so in das Eingabefeld des TA3 Terminals eingegeben werden.

Kommandos wie `on` und `off` werden zum Empfänger gesendet, ohne dass eine Antwort zurück kommt. Diese Kommandos können daher bspw. mit einem Taster/Schalter auch gleichzeitig an mehrere Empfänger gesendet werden, wenn dort im Eingabefeld mehrere Nummern eingegeben werden.

Ein Kommandos wie `state` fordert den Status eines Blockes an. Der Block sendet in Folge seinen Status zurück. Diese Art von bestätigten Kommandos kann gleichzeitig nur an einen Empfänger gesendet werden.
Auch dieses Kommandos kann mit dem TA3 Terminal bspw. an einem Schieber ausprobiert werden:

    cmd 123 state

Mögliche Antworten des Schiebers sind:
- `running` --> bin am arbeiten
- `stopped` --> ausgeschaltet
- `standby` --> nichts zu tun, da Quell-Inventar leer
- `blocked` --> kann nichts tun, da Ziel-Inventar voll

Dieser Status und weitere Informationen werden auch ausgegeben, wenn mit dem Schraubenschlüssel auf den Block geklickt wird.

[ta3_logic|image]


### TA3 Taster/Schalter / Button/Switch

Der Taster/Schalter sendet `on`/`off` Kommandos zu den Blöcken, die über die Nummern konfiguriert wurden.
Der Taster/Schalter kann als Taster (button) oder Schalter (switch) konfiguriert werden. Wird er als Taster konfiguriert, so kann die Zeit zwischen den `on` und `off` Kommandos eingestellt werden.

Über die Checkbox "public" kann eingestellt werden, ob den Taster von jedem (gesetzt), oder nur vom Besitzer selbst (nicht gesetzt) genutzt werden darf.

Hinweis: Mit dem Programmer können Blocknummern sehr einfach eingesammelt und konfiguriert werden.

[ta3_button|image]


### TA3 Logikblock / Logic Block

Den TA3 Logikblock kann man so programmieren, dass ein oder mehrere Eingangskommandos zu einem Ausgangskommando verknüpft und gesendet werden. Dieser Block kann daher diverse Logik-Elemente wie AND, OR, NOT, XOR usw. ersetzen.
Eingangkommandos für den Logikblock sind `on`/`off` Kommandos.
Eingangskommandos werden über die Nummer referenziert, also bspw. `1234` für das Kommando vom Sender mit der Nummer 1234.
Das gleiche gilt für Ausgangskommandos.

Eine Regel ist wie folgt aufgebaut:

```
<output> = on/off if <input-expression> is true
```

`<output>` ist die Nummer des Blocks, zu dem das Kommando gesendet werden soll.
`<input-expression>` ist ein boolescher Ausdruck, bei dem Eingabenummern ausgewertet werden. 



**Beispiele für den Input Ausdruck**

Signal negieren (NOT):

    1234 == off

Logisches UND (AND):

    1234 == on and 2345 == on

Logisches ODER (OR):

    1234 == on or 2345 == on

Folgende Operatoren sind zulässig:  `and`   `or`   `on`   `off`   `me`   `==`   `~=`   `(`   `)`

Ist der Ausdruck wahr (true), wird ein Kommando an den Block mit der `<output>` Nummer gesendet.

Es können bis zu vier Regeln definiert werden, wobei immer alle Regeln geprüft werden, wenn ein Kommando empfangen wird.

Die interne Durchlaufzeit aller Kommandos beträgt 100 ms.

Über das Schlüsselwort `me` kann die eigene Knotennummer referenziert werden. Damit ist es möglich, dass sich der Block selbst ein Kommando sendet (Flip-Flop Funktion).

Die Sperrzeit definiert eine Pause nach einem Kommando, in der der Logikblock kein weiteres Kommando von extern annimmt.  Empfangene Kommandos in der Sperrzeit werden damit verworfen. Die Sperrzeit kann in Sekunden definiert werden.

[ta3_logic|image]


### TA3 Wiederholer / Repeater

Der Wiederholer (repeater) sendet das empfangene Signal an alle konfigurierten Nummern weiter.
Dies kann bspw. Sinn machen, wenn man viele Blöcke gleichzeitig angesteuert werden sollen. Den Wiederholer kann man dazu mit dem Programmer konfigurieren, was nicht bei allen Blöcken möglich ist.

[ta3_repeater|image]


### TA3 Sequenzer / Sequencer

Der Sequenzer kann eine Reihe von `on`/`off` Kommandos senden, wobei der Abstand zwischen den Kommandos in Sekunden angegeben werden muss. Damit kann man bspw. eine Lampe blinken lassen.
Es können bis zu 8 Kommandos konfiguriert werden, jedes mit Zielblocknummer und Anstand zum nächsten Kommando.
Der Sequenzer wiederholt die Kommandos endlos, wenn "Run endless" gesetzt wird.
Wird also Kommando nichts ausgewählt, wird nur die angegeben Zeit in Sekunden gewartet.

[ta3_sequencer|image]


### TA3 Timer

Der Timer kann Kommandos Spielzeit-gesteuert senden. Für jede Kommandozeile kann die Uhrzeit, die Zielnummer(n) und das Kommando selbst angegeben werden. Damit lassen sich bspw. Lampen abends ein- und morgens wieder ausschalten.

[ta3_timer|image]


### TA3 Terminal

Das Terminal dient in erster Linie zum Austesten der Kommandoschnittstelle anderer Blöcke (siehe "Logik-/Schalt-Blöcke").
Man kann aber auch Kommandos auf Tasten legen und so das Terminal produktiv nutzen.

    set <button-num> <button-text> <command>

Mit `set 1 ON cmd 123 on` kann bspw. die Usertaste 1 mit dem Kommando `cnd 123 on` programmiert werden. Wird die Taste gedrückt, wird das Kommando gesendet und die Antwort auf dem Bildschirm ausgegeben.

Das Terminal besitzt folgende, lokalen Kommandos:
- `clear` lösche Bildschirm
- `help` gib eine Hilfeseite aus
- `pub` schalte in den öffentlichen Modus um
- `priv` schalte in den privaten Modus um

Im privaten Modus (private) kann das Terminal nur von Spielern verwendet werden, die an diesem Ort bauen können, also Protection Rechte besitzen. Im öffentlichen Modus (public) können alle Spieler die vorkonfigurierten Tasten verwenden.

[ta3_terminal|image]


### TechAge Signallampe / Signal Lamp

Die Signallampe kann mit `on`/`off` Kommando ein- bzw. ausgeschaltet werden. Diese Lampe braucht keinen Strom und
kann mit der Spritzpistole aus der Mod "Unified Dyes" farbig gemacht werden.

[ta3_signallamp|image]


### Tür/Tor Blöcke / Door/Gate Blocks

Mit diese Blöcken kann man Türe und Tore realisieren, die über Kommandos geöffnet (Blöcke verschwinden) und wieder geschlossen werden können. Pro Tor oder Tür wird dazu ein Tür Controller benötigt. 

Das Aussehen der Blöcke kann über das Block-Menü eingestellt werden.
Damit lassen sich Geheimtüren realisieren, die sich nur bei bestimmten Spielern öffnen (mit Hilfe des Spieler-Detektors). 

[ta3_doorblock|image]



### TA3 Tür Controller / Door Controller

Der Tür Controller dient zur Ansteuerung der TA3 Tür/Tor Blöcke. Beim Tür Controller müssen die Nummern der Tür/Tor Blöcke eingegeben werden. Wird ein  `on`/`off` Kommando Kommando an den Tür Controller gesendet, öffnet/schließt dieser die Tür bzw. das Tor.

[ta3_doorcontroller|image]

### TA3 Tür Controller II / Door Controller II

Der Tür Controller II kann alle Arten von Blöcken entfernen und wieder setzen. Um den Tür Controller II anzulernen, muss der "Aufzeichnen" Button gedrückt werden. Dann müssen alle Blöcke angeklickt werden, die Teil der Tür / des Tores sein sollen. Danach muss der "Fertig" Button gedrückt werden.  Es können bis zu 16 Blöcke ausgewählt werden. Die entfernten Blöcke werden im Inventar des Controllers gespeichert.

 Über die Tasten "Entfernen" bzw. "Setzen" kann die Funktion des Controllers von Hand getestet werden.

Wird ein  `on` / `off` Kommando an den Tür Controller II gesendet, entfernt bzw. setzt er die Blöcke ebenfalls.

Mit `$send_cmnd(node_number, "exchange", 2)` können einzelne Böcke gesetzt, entfernt, bzw. durch andere Blöcke aus dem Inventar ersetzt werden. 

Mit `$send_cmnd(node_number, "set", 2)` kann ein Block aus dem Inventory explizit gesetzt werden, sofern der Inventory Slot nicht leer ist.

Mit `$send_cmnd(node_number, "dig", 2)` kann ein Block wieder entfernt werden, sofern der Inventory Slot leer ist. 

Mit `$send_cmnd(node_number, "get", 2)` wird der Name des gesetzten Blocks zurückgeliefert. 

Die Slot-Nummer des Inventars (1 .. 16) muss in allen drei Fällen als payload übergeben werden.

Damit lassen sich auch ausfahrbare Treppen und ähnliches simulieren.

[ta3_doorcontroller|image]

### TA3 Sound Block

Mir dem Sound Block  können veschiedene Sounds/Laute abgespielt werden. Es sind alle Sounds der Mods Techage, Signs Bot, Hyperloop, Unified Inventory, TA4 Jetpack und Minetest Game verfügbar.

Die Sounds können über das Menü und über ein Kommando ausgewählt und abgespielt werden.

- Kommando `on` zum Abspielen eines Sounds
- Kommando `sound <idx>` zur Auswahl eines Sounds über den Index
- Kommando `gain <volume>` zum Einstellen der Lautstärke über den `<volume>`  Wert (1 bis 5). 

[ta3_soundblock|image]

### TA3 Mesecons Umsetzer / TA3 Mesecons Converter

Der Mesecons Umsetzer dient zur Umwandlung von Techage on/off Kommandos in Mesecons Signale und umgekehrt.
Dazu müssen eine oder mehrere Knotennummern eingegeben und der Konverter mit Mesecons Blöcken 
über Mesecons Leitungen verbunden werden. Den Mesecons Umsetzer kann man auch mit dem Programmer konfigurieren.
Der Mesecons Umsetzer akzeptiert bis zu 5 Kommandos pro Sekunde, bei höherer Belastung schaltet er sich ab.

**Dieser Block existiert aber nur, wenn die Mod mesecons aktiv ist!**

[ta3_mesecons_converter|image]


## Detektoren

Detektoren scannen ihre Umgebung ab und senden ein `on`-Kommando, wenn das Gesuchte erkannt wurde.

[ta3_nodedetector|image]


### TA3 Detektor / Detector

Der Detektor ist eine spezieller Röhrenblock, der erkennt, wenn Items über die Röhre weitergegeben werden. Es muss dazu auf beiden Seiten mit der Röhre verbunden sein. Werden Items mit einem Schieber in den Detektor geschoben, gibt er diese automatisch weiter.
Er sendet ein `on`, wenn ein Item erkannt wird, gefolgt von einem `off` eine Sekunde später.
Danach werden weitere Kommando für 8 Sekunden blockiert.
Die Wartezeit, sowie die Items, die ein Kommando auslösen sollen, können über das Gabelschlüssel-Menü konfiguriert werden.


[ta3_detector|image]


### TA3 Wagen Detektor / Cart Detector

Der Wagen Detektor sendet ein `on`-Kommando, wenn er einen Wagen/Cart (Minecart) direkt vor sich erkannt hat. Zusätzlich kann der Detektor auch den Wagen wieder starten, wenn ein `on`-Kommando empfangen wird.

Der Detektor kann auch mit seiner eigenen Nummer programmiert werden. In diesem Falle schiebt er alle Wagen an, die in seiner Nähe (ein Block in alle Richtungen) zum Halten kommen.

[ta3_cartdetector|image]


### TA3 Block Detektor / Node Detector

Der Block Detektor sendet ein `on`-Kommando, wenn er erkennt, dass Blöcke vor ihm erscheinen oder verschwinden, muss jedoch entsprechend konfiguriert werden. Nach dem Zurückschalten des Detektors in den Standardzustand (grauer Block) wird ein `off`-Kommando gesendet. Gültige Blöcke sind alle Arten von Blöcken und Pflanzen, aber keine Tiere oder Spieler. Die Sensorreichweite beträgt 3 Blöcke/Meter in Pfeilrichtung.

[ta3_nodedetector|image]


### TA3 Spieler Detektor / Player Detector

Der Spieler Detektor sendet ein `on`-Kommando, wenn er einen Spieler in einem Umkreis von 4 m um den Block herum erkennt. Verlässt der Spieler wieder den Bereich, wird ein `off`-Kommando gesendet.
Soll die Suche auf bestimmte Spieler eingegrenzt werden, so können diese Spielernamen auch eingegeben werden.

[ta3_playerdetector|image]


### TA3 Lichtdetektor

Der Lichtdetektor sendet einen `on`-Kommando, wenn der Lichtpegel des darüber liegenden Blocks einen bestimmten Pegel überschreitet, der über das Rechtsklickmenü eingestellt werden kann.
Mit einen TA4 Lua Controller kann die genaue Lichtstärke mit $get_cmd(num, 'light_level') ermitteln werden.

[ta3_lightdetector|image]


## TA3 Maschinen

Bei TA3 existieren die gleichen Maschinen wie bei TA2, nur sind diese hier leistungsfähiger und benötigen Strom statt Achsenantrieb.
Im folgenden sind daher nur die unterschiedlichen, technischen Daten angegeben.

[ta3_grinder|image]


### TA3 Schieber / Pusher

Die Funktion entspricht der von TA2.  
Die Verarbeitungsleistung beträgt 6 Items alle 2 s.

[ta3_pusher|image]


### TA3 Verteiler / Distributor

Die Funktion des TA3 Verteilers entspricht der von TA2.
Die Verarbeitungsleistung beträgt 12 Items alle 4 s.

[ta3_distributor|image]


### TA3 Autocrafter

Die Funktion entspricht der von TA2.  
Die Verarbeitungsleistung beträgt 2 Items alle 4 s. Der Autocrafter benötigt hierfür 6 ku Strom.

[ta3_autocrafter|image]


### TA3 Elektronikfabrik / Electronic Fab

Die Funktion entspricht der von TA2, nur werden hier TA4 WLAN Chips produziert.  
Die Verarbeitungsleistung beträgt ein Chip alle 6 s. Der Block benötigt hierfür 12 ku Strom.

[ta3_electronicfab|image]


### TA3 Steinbrecher / Quarry

Die Funktion entspricht der von TA2.  
Die maximale Tiefe beträgt 40 Meter. Der Steinbrecher benötigt 12 ku Strom.

[ta3_quarry|image]


### TA3 Kiessieb / Gravel Sieve

Die Funktion entspricht der von TA2.  
Die Verarbeitungsleistung beträgt 2 Items alle 4 s. Der Block benötigt 4 ku Strom.

[ta3_gravelsieve|image]


### TA3 Kieswaschanlage / Gravel Rinser

Die Funktion entspricht der von TA2.  
Auch die Wahrscheinlichkeit ist wie bei TA2. Der Block benötigt auch 3 ku Strom.  
Aber im Gegensatz zu TA2 kann beim TA3 Block bspw. der Status abgefragt werden (Controller)

[ta3_gravelrinser|image]


### TA3 Mühle / Grinder

Die Funktion entspricht der von TA2.  
Die Verarbeitungsleistung beträgt 2 Items alle 4 s. Der Block benötigt 6 ku Strom.

[ta3_grinder|image]

### TA3 Injektor / Injector

Der Injektor ist ein TA3 Schieber mit speziellen Eigenschaften. Er besitzt ein Menü zur Konfiguration. Hier können bis zu 8 Items konfiguriert werden. Er entnimmt nur diese Items einer Kiste um sie an Maschinen mit Rezepturen weiterzugeben (Autocrafter, Industrieofen und Elektronikfabrik).

Beim Weitergeben wird in der Zielmaschine pro Item nur eine Position im Inventar genutzt. Sind bspw. nur die ersten drei Einträge im Injektor konfiguriert, so werden auch nur die ersten drei Speicherplätze im Inventar der Maschine belegt. Damit wir ein Überlauf im Inventar der Maschine verhindert.

Der Injektor kann auch auf "Ziehe-Modus" umgeschaltet werden. Dann zieht er nur Items von den Positionen aus der Kiste, die in der Konfiguration des Injektors definiert sind. Hier müssen also Item-Typ und Position überein stimmen. Damit können geziehlt Speicherplätze im Inventar einer Kiste geleert werden.

Die Verarbeitungsleistung beträgt bis zu 8 mal ein Item alle 4 Sekunden.

[ta3_injector|image]




## Werkzeuge

### Techage Info Tool

Das Techage Info Tool (Schraubenschlüssel) hat verschiedene Funktionen. Er zeigt die Uhrzeit, die Position, die Temperatur und das Biome an, wenn auf einen unbekannten Block geklickt wird.
Wird auf einen TechAge Block mit Kommandoschnittstelle geklickt, werden alle verfügbaren Daten abgerufen (siehe auch "Logik-/Schalt-Blöcke").

Mit Shift+Rechtsklick kann bei einigen Blöcken ein erweitertes Menü geöffnet werden. Hier lassen sich je nach Block weitere Daten abrufen oder spezielle Einstellungen vornehmen. Bei einem Generator kann bspw. die Ladekurve/abschaltung programmiert werden. 

[ta3_end_wrench|image]


### TechAge Programmer

Mit dem Programmer können Blocknummern mit einem Rechtsklick von mehreren Blöcken eingesammelt und mit einem Linksklick in einen Block wie Taster/Schalter geschrieben werden.
Wird in die Luft geklickt, wird der interne Speicher gelöscht.

[ta3_programmer|image]

### TechAge Kelle / Trowel

Die Kelle dient zum Verputzen von Stromkabel. Siehe dazu "TA Stromkabel".

[ta3_trowel|image]


### TA3 Bohrgestängezange / TA3 Drill Pipe Wrench

Mit diesem Werkzeug lassen sich die Bohrgestängezange Blöcke wieder entfernen, wenn dort bspw. ein Tunnel durch soll.

[ta3_drill_pipe_wrench|image]

### Techage Schraubendreher

Der Techage Schraubendreher dient als Ersatz für den normalen Schraubendreher. Es besitzt folgende Funktionen:

- Linksklick: Den Block nach links drehen
- Rechtsklick: Die sichtbare Seite des Blockes nach oben drehen
- Shift+Linksklick: Ausrichtung des angeklickten Blockes speichern
- Shift+Rechtsklick: Die gespeicherte Ausrichtung auf den angeklickten Block anwenden

[ta3_screwdriver|image]
