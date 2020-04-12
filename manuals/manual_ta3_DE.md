# TA3: Ölzeitalter

Bei TA3 gilt es, die Dampf-betriebenen Maschinen durch leistungsfähigere und mit elektrischem Strom betriebene Maschinen abzulösen.

Dazu musst du Kohlekraftwerke und Generatoren bauen. Bald wirst du sehen, dass dein Strombedarf nur mit Öl-betriebenen Kraftwerken zu decken ist. Also machst du dich auf die Suche nach Erdöl. Bohrtürme und Ölpumpen helfen die, an das Öl zu kommen. Schienenwege dienen dir zum Öltransport bis in die Kraftwerke.

Das Industrielle Zeitalter ist auf seinem Höhepunkt.

[techage_ta3|image]


## Kohlekraftwerk / Ölkraftwerk

Das Kohlekraftwerk besteht aus mehreren Blöcken und muss wie im Plan rechts abgebildet, zusammen gebaut werden. Dazu werden die Blöcke TA3 Kraftwerks-Feuerbox, TA3 Boiler oben, TA3 Boiler unten, TA3 Turbine, TA3 Generator und TA3 Kühler benötigt.

Der Boiler muss mit Wasser gefüllt werden. Dazu bis zu 10 Eimer Wasser in den Boiler füllen.
Die Feuerbox muss mit Kohle oder Holzkohle gefüllt werden.
Wenn das Wasser heiß ist, kann das Ventil am Boiler geöffnet und anschließend die Generator gestartet werden.

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

In TA3 (und TA4) werden die Maschinen mit Strom angetrieben. Dazu müssen die Maschinen und Generatoren mit Stromkabel verbunden werden.  
TA3 besitzt 2 Arten von Stromkabel:

- Isolierte Kabel (TA Stromkabel) für die lokale Verkabelung im Boden oder in Gebäuden. Diese Kabel lassen sich in der Wand oder im Boden verstecken (können mit der Kelle "verputzt" werden).
- Überlandleitungen (TA Stromleitung) für Freiluftverkabelung über große Strecken. Diese Kabel sind geschützt, können also von anderen Spielern nicht entfernt werden.

Mehrere Verbraucher und Generatoren können in einem Stromnetzwerk zusammen betrieben werden. Mit Hilfe der Verteilerdosen können so große Netzwerke aufgebaut werden.
Wird zu wenig Strom bereitgestellt, gehen die Verbraucher aus.
In diesem Zusammenhang ist auch wichtig, dass die Funktionsweise von Forceload Blöcken verstanden wurde, denn bspw. Generatoren liefern nur Strom, wenn der entsprechende Map-Block geladen ist. Dies kann mit einen Forceload Block erzwungen werden.

In TA4 kommt noch ein Kabel für die Solaranlage hinzu.


[ta3_powerswitch|image]


### TA Stromkabel / Electric Cable

Für die lokale Verkabelung im Boden oder in Gebäuden.  
Abzweigungen können mit Hilfe von Verteilerdosen realisiert werden. Die maximale Kabellänge zwischen Maschinen oder Verteilerdosen beträgt 1000 m. Es können maximale 1000 Knoten in einem Strom-Netzwerk verbunden werden. Als Knoten zählen alle Generatoren, Akkus, Verteilerdosen und Maschinen.

Da die Stromkabel nicht automatisch geschützt sind, wird für längere Strecken die Überlandleitungen (TA Stromleitung) empfohlen.

Stromkabel können mit der Kelle verputzt also in der Wand oder im Boden versteckt werden. Als Material zum Verputzen können alle Stein-, Clay- und sonstige Blöcke ohne "Intelligenz" genutzt werden. Erde (dirt) geht nicht, da Erde zu Gras oder ähnlichem konvertiert werden kann, was die Leitung zerstören würde.

Zum Verputzen muss mit der Kelle auf das Kabel geklickt werden. Das Material, mit dem das Kabel verputzt werden soll, muss sich im Spieler-Inventar ganz links befinden.  
Die Kabel können wieder sichtbar gemacht werden, indem man mit der Kelle wieder auf den Block klickt.

Außer Kabel können auch die TA Verteilerdose und die TA Stromschalterbox verputzt werden.

[ta3_powercable|image]


### TA Verteilerdose / Electric Junction Box

Mit der Verteilerdose kann Strom in bis zu 6 Richtungen verteilt werden. Verteilerdosen können auch mit der Kelle verputzt (versteckt) und wieder sichtbar gemacht werden.
Wird mit dem TechAge Info Werkzeug (Schraubenschlüssel) auf die Verteilerdose geklickt, wird angezeigt, wie viel Leistung die Generatoren liefern bzw. die Verbraucher im Netzwerk beziehen.

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
Der Akku Block ist eine sekundäre Stromquelle. Das bedeutet, bei Strombedarf werden zuerst die Generatoren genutzt. Nur wenn der Strom im Netz nicht ausreicht, springt der Akku Block ein. Das Gleiche gilt auch für die Stromaufnahme. Daher kann auch kein Akku mit einem anderen Akku geladen werden.
Der Akku liefert 10 ku bzw. nimmt 10 ku auf.
Bei Volllast kann ein Akku 400 s lang Strom aufnehmen und wenn er voll ist, auch wieder abgeben. Dies entspricht 8 h Spielzeit bei einem normalen Spieltag von 20 min.

[ta3_akkublock|image]


### TA3 Strom Terminal / Power Terminal

Das Strom-Terminal muss mit dem Stromnetz verbunden werden. Es zeigt Daten aus dem Stromnetz an.

In der oberen Hälfte werden nur die Daten eines ausgewählten Typs ausgegeben. Wird als Typ bspw. "Kraftwerk" gewählt, so werden nur die Daten von Öl- und Kohlekraftwerken gesammelt und ausgegeben. Links werden die Daten von Generatoren (Stromabgabe) und rechts die Daten von Energiespeichern (Stromaufnahme) ausgegeben. Beim Akkublocks bspw. wird beides ausgegeben, da der Akku Strom aufnehmen und abgeben kann.

In der unteren Hälfte werden die Daten aller Generatoren und Speichersystemen des ganzen Stromnetzen zusammengefasst ausgegeben.

[ta3_powerterminal|image]


## TA3 Industrieofen

Der TA3 Industrieofen dient als Ergänzung zu normalen Ofen (furnace). Damit können alle Waren mit "Koch" Rezepten, auch im Industrieofen hergestellt werden. Es gibt aber auch spezielle Rezepte, die nur im Industrieofen hergestellt werden können.
Der Industrieofen hat sein eigenes Menü zur Rezeptauswahl. Abhängig von den Waren im Industrieofen Inventar links kann rechts das Ausgangsprodukt gewählt werden.

Der Industrieofen benötigt Strom (für das Gebläse) sowie Öl/Benzin für den Brenner. Der Industrieofens und muss wie im Plan rechts abgebildet, zusammen gebaut werden.

Siehe auch TA4 Ofenheizung.

[ta3_furnace|plan]


### TA3 Ofen-Ölbrenner / Furnace Oil Burner

Ist Teil des TA3 Industrieofen.

Der Ölbrenner kann mit Schweröl, Naphtha oder Benzin betrieben werden. Die Brennzeit beträgt für Schweröl 80 s, Naphtha 90 s und Benzin 100 s.

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

Die Ölbohrkiste bohrt bis zum Ölfeld (1 Meter in 16 s) und benötigt dazu 10 ku Strom.
Wurde das Ölfeld erreicht, kann der Bohrturm abgebaut und die Kiste entfernt werden.

[ta3_drillbox|image]


### TA3 Ölpumpe / Oil Pumpjack

An die Stelle der Ölbohrkiste muss nun die Ölpumpe platziert werden. Auch die Ölpumpe benötigt Strom (16 ku) und liefert alle 8 s ein Einheit Erdöl. Das Erdöl muss in einem Tank gesammelt werden. Dazu muss die Ölpumpe über eine Leitung (gelbe Röhre) mit dem Tank verbunden werden.
Ist alles Öl abgepumpt, kann auch die Ölpumpe wieder entfernt werden.

[ta3_pumpjack|image]


### TA3 Bohrgestänge / Drill Bit

Das Bohrgestänge wird für die Bohrung benötigt. Es werden so viele Bohrgestänge Items benötigt wie als Tiefe für das Ölfeld angegeben wurde. Das Bohrgestänge ist nach der Bohrung nutzlos, kann aber auch nicht abgebaut werden und verbleibt im Boden.

[ta3_drillbit|image]


### Öltank / Oil Tank

Der Öltank ist die große Ausführung des TA3 Tanks (siehe Flüssigkeiten -> TA3 Tank).

Der große Tank kann 4000 Einheiten Öl, aber auch jede andere Art von Flüssigkeit aufnehmen.

[oiltank|image]



## Öl-Transport

Um Öl von der Ölquelle zur Ölverarbeitungsanlage zu befördern, können Minecarts genutzt werden.  In die Minecarts können aber nur Kanister oder Fässer geladen werden. Deshalb muss das Öl zuvor in Fässer umgeladen werden. Die Ölfässer können direkt mit einem Schieber und Röhren in das Minecart geschoben werden (siehe Plan). Die leeren Fässer, welche per Minecart von der Entladestation zurück kommen, können über einen Hopper entladen werden, der unter der Schiene an der Haltestelle platziert wird.

Es ist mit dem Hopper nicht möglich, an **einer** Haltestelle sowohl die leeren Fässer zu entladen, als auch die vollen Fässer zu beladen. Der Hopper lädt die vollen Fässer sofort wieder aus. Daher ist es ratsam, jeweils 2 Stationen auf der Be- und Entladeseite einzurichten und den Minecart dann über eine Aufzeichnungsfahrt entsprechend zu programmieren.

Der Plan zeigt, wie das Öl in einen Tank gepumpt und über einen Einfülltrichter in Fässer umgefüllt und in Minecarts geladen werden kann.

Damit die Minecarts automatisch wieder starten, müssen die Prellböcke mit Stationsname und Wartezeit konfiguriert werden. Für das Entladen reichen 5 s. Da aber die Schieber immer für mehrere Sekunden in den Standby fallen, wenn kein Minecart  da ist, muss für das Beladen eine Zeit von 15 oder mehr Sekunden eingegeben werden.

[ta3_loading|plan]




## Öl-Verarbeitung

Öl ist ein Stoffgemisch und besteht aus sehr vielen Komponenten. Über einen Destillationsturm kann das Öl in seine Hauptbestandteile wie Bitumen, Schweröl, Naphtha, Benzin und Gas zerlegt werden.
Die weitere Verarbeitung zu Endprodukten erfolgt im Chemischen Reaktor.

[techage_ta31|image]


### Destillationsturm / distiller tower

Der Destillationsturm muss wie im Plan rechts oben aufgebaut werden. 
Über den Basisblock wird das Bitumen abgelassen. Der Ausgang ist auf der Rückseite des Basisblocks (Pfeilrichtung beachten).
Auf diesen Basisblock kommen die "Destillationsturm" Blöcke mit den Nummern: 1, 2, 3, 2, 3, 2, 3, 4
An den Öffnungen von unten nach oben werden Schweröl, Naphtha und Benzin abgeleitet. Ganz oben wird das Gas abgefangen.
Es müssen alle Öffnungen am Turm mit Tanks verbunden werden.
Der Aufkocher (reboiler) muss mit dem Block "Destillationsturm 1" verbunden werden.

Der Aufkocher benötigt Strom (nicht im Plan zu sehen)!


[ta3_distiller|plan]

#### Aufkocher / reboiler)

Der Aufkocher erhitzt das Erdöl auf ca. 400°C. Dabei verdampft es weitgehend und wird in den Destillationsturm zur Abkühlung geleitet.

Der Aufkocher benötigt 12 Einheiten Strom und produziert alle 6 s jeweils eine Einheit Bitumen, Schweröl, Naphtha, Benzin und Gas.
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

Den TA3 Logikblock kann man so programmieren, dass ein oder mehrere Eingangssignale zu einem Ausgangssignal verknüpft und gesendet werden. Dieser Block kann daher diverse Logik-Elemente wie AND, OR, NOT, XOR usw. ersetzen.
Eingangssignale für den Logikblock sind `on`/`off` Kommandos. Ein `on` ist ein logisches `true`, ein `off` entspricht dem `false`.
Eingangssignale werden über die Nummer referenziert, also bspw. `n123` für das Signal vom Sender mit der Nummer 123.

**Beispiele für den IF Ausdruck**

Signal negieren (NOT):

    not n123

Logisches UND (AND):

    n123 and n345

Logisches ODER (OR):

    n123 or n345

Ist der `if`-Ausdruck wahr (true), wird der `then` Zweig ausgeführt, anderenfalls der `else` Zweig.
Bei `then` und `else` kann entweder `true`, `false`, oder nichts eingegeben werden:
- bei `true` wird `on` gesendet
- bei `false` wird `off` gesendet
- wird nichts eingegeben, wird auch nichts gesendet

Den oder die Ziel-Blöcke für das Ausgangssignal muss man im Zielnummern-Feld eingeben.

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

Im privaten Modul kann nur der Besitzer selbst Kommandos eingeben oder Tasten nutzen.

[ta3_terminal|image]


### TechAge Signallampe / Signal Lamp

Die Signallampe kann mit `on`/`off` Kommando ein- bzw. ausgeschaltet werden. Diese Lampe braucht keinen Strom und
kann mit der Spritzpistole farbig gemacht werden.

[ta3_signallamp|image]


### Tür/Tor Blöcke / Door/Gate Blocks

Mit diese Blöcken kann man Türe und Tore realisieren, die über Kommandos geöffnet (Blöcke verschwinden) und wieder geschlossen werden können. Pro Tor oder Tür wird dazu ein Tür Controller benötigt. 

Das Aussehen der Blöcke kann über das Block-Menü eingestellt werden.
Damit lassen sich Geheimtüren realisieren, die sich nur bei bestimmten Spielern öffnen (mit Hilfe des Spieler-Detektors). 

[ta3_doorblock|image]



### TA3 Tür Controller / Door Controller

Der Tür Controller dient zur Ansteuerung der TA3 Tür/Tor Blöcke. Beim Tür Controller müssen die Nummern der Tür/Tor Blöcke eingegeben werden. Wird ein  `on`/`off` Kommando Kommando an den Tür Controller gesendet, öffnet/schließt dieser die Tür bzw. das Tor.

[ta3_doorcontroller|image]



## Detektoren

Detektoren scannen ihre Umgebung ab und senden ein `on`-Kommando, wenn das Gesuchte erkannt wurde.

[ta3_nodedetector|image]


### TA3 Detektor / Detector

Der Detektor ist eine spezieller Röhrenblock, der erkennt, wenn Items über die Röhre weitergegeben werden. Es muss dazu auf beiden Seiten mit der Röhre verbunden sein. Werden Items mit einem Schieber in den Detektor geschoben, gibt er diese automatisch weiter.
Er sendet ein `on`, wenn ein Item erkannt wird, gefolgt von einem `off` eine Sekunde später.
Danach werden weitere Kommando für 8 Sekunden blockiert.


[ta3_detector|image]


### TA3 Wagen Detektor / Cart Detector

Der Wagen Detektor sendet ein `on`-Kommando, wenn er einen Wagen/Cart (Minecart) direkt vor sich erkannt hat. Zusätzlich kann der Detektor auch den Wagen wieder starten, wenn ein `on`-Kommando empfangen wird.

[ta3_cartdetector|image]


### TA3 Block Detektor / Node Detector

Der Block Detektor sendet ein `on`-Kommando, wenn er erkennt, dass Blöcke vor ihm erscheinen oder verschwinden, muss jedoch entsprechend konfiguriert werden. Nach dem Zurückschalten des Detektors in den Standardzustand (grauer Block) wird ein `off`-Kommando gesendet. Gültige Blöcke sind alle Arten von Blöcken und Pflanzen, aber keine Tiere oder Spieler. Die Sensorreichweite beträgt 3 Blöcke/Meter in Pfeilrichtung.

[ta3_nodedetector|image]


### TA3 Spieler Detektor / Player Detector

Der Spieler Detektor sendet ein `on`-Kommando, wenn er einen Spieler in einem Umkreis von 4 m um den Block herum erkennt. Verlässt der Spieler wieder den Bereich, wird ein `off`-Kommando gesendet.
Soll die Suche auf bestimmte Spieler eingegrenzt werden, so können diese Spielernamen auch eingegeben werden.

[ta3_playerdetector|image]


## TA3 Maschinen

Bei TA3 existieren die gleichen Maschinen wie bei TA2, nur sind diese hier leistungsfähiger und benötigen Strom statt Achsenantrieb.
Im folgenden sind daher nur die unterschiedlichen, technischen Daten angegeben.

[ta3_grinder|image]


### TA3 Schieber / Pusher

Die Funktion entspricht der von TA2.  
Die Verarbeitungsleistung beträgt 6 Items alle 2 s.

[ta3_pusher|image]


### TA3 Verteiler / Distributor

Die Funktion entspricht der von TA2.  
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


### TA3 Flüssigkeitensammler / Liquid Sampler

Die Funktion entspricht der von TA2.  
Die Verarbeitungsleistung ist 2 Items alle 8 s. Der Block benötigt 5 ku Strom.

[ta3_liquidsampler|image]


## Werkzeuge

### Techage Info Tool

Das Techage Info Tool (Schraubenschlüssel) hat verschiedene Funktionen. Er zeigt die Uhrzeit, die Position, die Temperatur und das Biome an, wenn auf einen unbekannten Block geklickt wird.
Wird auf einen TechAge Block mit Kommandoschnittstelle geklickt, werden alle verfügbaren Daten abgerufen (siehe auch "Logik-/Schalt-Blöcke").
Bei Strom-Verteilerdosen werden die benachbarten Netzwerkteilnehmer (bis zu 50 Meter weit) mit einem blauen Käfig angezeigt.

[ta3_end_wrench|image]


### TechAge Programmer

Mit dem Programmer können Blocknummern mit einem Rechtsklick von mehreren Blöcken eingesammelt und mit einem Linksklick in einen Block wie Taster/Schalter geschrieben werden.
Wird in die Luft geklickt, wird der interne Speicher gelöscht.

[ta3_programmer|image]



### TechAge Kelle / Trowel

Die Kelle dient zum Verputzen von Stromkabel. Siehe dazu "TA Stromkabel".

[ta3_trowel|image]

