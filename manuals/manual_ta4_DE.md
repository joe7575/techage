# TA4: Zukunft

Regenerative Energiequellen wie Wind, Sonne und Biokraft helfen dir, das Ölzeitalter zu verlassen. Mit modernen Technologien und intelligenten Maschinen machst du dich auf in die Zukunft.

[techage_ta4|image]


## Windkraftanlage

Eine Windkraftanlagen liefern immer dann Strom, wenn Wind vorhanden ist. Im Spiel gibt es keinen Wind, aber die Mod simuliert dies dadurch, dass sich nur morgens (5:00 - 9:00) und abends (17:00 - 21:00) die Windräder drehen und damit Strom liefern, sofern diese an geeigneten Stellen errichtet werden.

Die TA Windkraftanlagen sind reine Offshore Anlagen, das heißt, die müssen im Meer (Wasser) errichtet werden. Dies bedeutet, dass um den Mast herum mit einem Abstand von 20 Blöcken nur Wasser sein darf und das mindestens 2 Blöcke tief.
Der Rotor muss in einer Höhe (Y-Koordinate) von 12 bis maximal 20 m platziert werden. Der Abstand zu weiteren Windkraftanlagen muss mindestens 14 m betragen.

Der Strom muss vom Rotor-Block durch den Mast nach unten geführt werden. Dazu zuerst die Stromleitung nach oben ziehen und das Stromkabel dann mit TA4 Säulenblöcke "verputzen". Unten kann eine Arbeitsplattform errichtet werden. Der Plan rechts zeigt den Aufbau im oberen Teil.

Die Windkraftanlage liefert eine Leistung von 70 ku, aber dies nur 8 Stunden am Tag (siehe oben).

[ta4_windturbine|plan]


### TA4 Windkraftanlage / Wind Turbine

Der Windkraftanlagenblock (Rotor) ist das Herzstück der Windkraftanlage. Dieser Block muss oben auf den Mast gesetzt werden. Idealerweise auf Y = 15, dann bleibst du noch gerade innerhalb eines Map-/Forceload-Blocks.
Sofern alle Bedingungen erfüllt sind, erscheinen beim Setzen dieses Blocks auch automatisch die Rotorblätter (Flügel). Anderenfalls wird dir eine Fehlermeldung angezeigt.

[ta4_windturbine|image]


### TA4 Windkraftanlagengondel / Wind Turbine Nacelle

Dieser Block muss an das schwarze Ende des Wind Turbinen Block gesetzt werden.

[ta4_nacelle|image]


### TA4 Wind Turbine Signal Lamp

Dieses Blinklicht ist nur für dekorative Zwecke und kann oben auf den Wind Turbinen Block gesetzt werden.

[ta4_blinklamp|image]


### TA4 Säule / Pillar

Damit wird der Mast für die Windkraftanlage gebaut. Allerdings werden diese Blöcke nicht von Hand gesetzt sondern müssen mit Hilfe der Kelle gesetzt werden, so dass die Stromleitung zur Mastspitze mit diesen Blöcken ersetzt wird (siehe unter TA Stromkabel).

[ta4_pillar|image]


## Solaranlage

Die Solaranlage produziert nur Strom, wenn die Sonne scheint. Im Spiel ist das jeder Spieltag von morgens 6:00 bis abends 18:00.
In dieser Zeit steht immer die gleiche Leistung zur Verfügung. Nach 18:00 schalten die Solarmodule komplett ab.

Für die Leistung der Solarmodule ist die Biome Temperatur entscheidend. Je heißer die Temperatur, um so höher der Ertrag.
Die Biome Temperatur kann mit dem Techage Info Tool (Schraubenschlüssel) bestimmt werden. Sie schwankt typischerweise zwischen 0 und 100:

- bei 100 steht die volle Leistung zur Verfügung
- bei 50 steht die halbe Leistung zur Verfügung
- bei 0 steht keine Leistung zur Verfügung

Es empfiehlt sich daher, nach heißen Steppen und Wüsten für die Solaranlage Ausschau zu halten.  
Für den Stromtransport stehen die Überlandleitungen zur Verfügung.  
Es kann aber auch Wasserstoff produziert werden, welcher sich transportieren und am Ziel wieder zu Strom umwandeln lässt.

Die kleinste Einheit bei einer Solaranlage sind zwei Solarmodule und ein Trägermodul. Das Trägermodul muss zuerst gesetzt werden, die zwei Solarmodule dann links und rechts daneben (nicht darüber!).

Der Plan rechts zeigt 3 Einheiten mit je zwei Solarmodulen und einem Trägermodul, über rote Kabel mit dem Wechselrichter verbunden.

Solarmodule liefern Gleichspannung, welcher nicht direkt in das Stromnetz eingespeist werden kann. Daher müssen zuerst die Solareinheiten über das rote Kabel mit dem Wechselrichter verbunden werden. Dieser besteht aus zwei Blöcken, einen für das rote Kabel zu den Solarmodulen (DC) und einen für das graue Stromkabel ins Stromnetz (AC).

Der Kartenbereich, wo die Solaranlage steht, muss komplett geladen sein. Die gilt auch für die direkte Position über dem Solarmodul, denn dort wird regelmäßig die Lichtstärke gemessen. Es empfiehlt sich daher, zuerst einen Forceload Block zu setzen, und dann innerhalb dieses Bereiches die Module zu platzieren.

[ta4_solarplant|plan]


### TA4 Solarmodul / Solar Module

Das Solarmodul muss an das Trägermodul gesetzt werden. Es sind immer zwei Solarmodule notwendig.
Im Paar leisten die Solarmodule bis 3 ku, je nach Temperatur.
Bei den Solarmodul muss darauf geachtet werden, dass diese das volle Tageslicht haben und nicht durch Blöcke oder Bäume beschattet sind. Getestet kann dies mit dem Info Tool (Schraubenschlüssel).

[ta4_solarmodule|image]


### TA4 Solar Trägermodul / Carrier Module

Das Trägermodul gibt es in zwei Bauhöhen (1m und 2m). Funktionell sind beide identisch.
Die Trägermodule können direkt aneinander gesetzt und so zu einer Modulreihe verbunden werden. Die Verbindung zum Wechselrichter oder zu anderen Modulreihen muss mit den roten Niederspannungskabeln bzw. den Niederspannungsverteilerboxen hergestellt werden.

[ta4_solarcarrier|image]


### TA4 Solar Wechselrichter / Solar Inverter

Der Wechselrichter wandelt den Solarstrom (DC) in Wechselstrom (AC) um, so dass dieser in das Stromnetz eingespeist werden kann.
Ein Wechselrichter kann maximal 100 ku an Strom einspeisen, was 33 Solarmodulen oder auch mehr entspricht.

[ta4_solar_inverter|image]


### TA4 Niederspannungskabel / Low Power Cable

Das Niederspannungskabel dient zur Verbindung von Solar-Modulreihen mit dem Wechselrichter. Das Kabel darf nicht für andere Zwecke benutzt werden.

Die maximale Leitungslänge beträgt 200 m.

[ta4_powercable|image]


### TA4 Niederspannungsverteilerbox / Low Power Box

Die Verteilerbox muss auf den Boden gesetzt werden. Sie besitzt nur 4 Anschlüsse (in die 4 Himmelsrichtungen).

[ta4_powerbox|image]


### TA4 Straßenlampen-Solarzelle / Streetlamp Solar Cell

Die Straßenlampen-Solarzelle dient, wie der Name schon sagt, zur Stromversorgung einer Straßenlampe. Dabei kann eine Solarzelle zwei Lampen versorgen. Die Solarzelle speichert die Sonnenenergie tagsüber und gibt den Strom Nachts an die Lampe ab. Das bedeutet, die Lampe leuchtet nur im Dunkeln.

Diese Solarzelle kann nicht mit den anderen Solarmodulen kombiniert werden.

[ta4_minicell|image]



## Energiespeicher

Der Energiespeicher besteht aus einer Betonhülle (Concrete Block) gefüllt mit Gravel. Es gibt 3 Größen vom Speicher:

- Hülle mit 5x5x5 Concrete Blocks, gefüllt mit 27 Gravel, Speicherkapazität: 1/2 Tag bei 60 ku
- Hülle mit 7x7x7 Concrete Blocks, gefüllt mit 125 Gravel, Speicherkapazität: 2,5 Tage bei 60 ku
- Hülle mit 9x9x9 Concrete Blocks, gefüllt mit 343 Gravel, Speicherkapazität: 6,5 Tage bei 60 ku 

In der Betonhülle darf ein Fenster aus einem Obsidian Glas Block sein. Dieses muss ziemlich in der Mitte der Wand platziert werden. Durch dieses Fenster sieht man, ob der Speicher mehr als 80 % geladen ist. Im Plan rechts sieht man den Aufbau aus TA4 Wärmetauscher  bestehend aus 3 Blöcken, der TA4 Turbine und dem TA4 Generator. Beim Wärmetauscher ist auf die Ausrichtung zu achten (der Pfeil bei Block 1 muss zur Turbine zeigen).

Entgegen dem Plan rechts müssen die Anschlüsse am Speicherblock auf gleicher Ebene sein (horizontal angeordnet, also nicht unten und oben). Die Rohrzuläufe (TA4 Pipe Inlet) müssen genau in der Mitte der Wand sein und stehen sich damit gegenüber. Als Röhren kommen die gelbel TA4 Röhren zum Einsatz. Die TA3 Dampfrohre können hier nicht verwendet werden.
Sowohl der Generator als auch der Wärmetauscher haben einen Stromanschluss und müssen mit dem Stromnetz verbunden werden.

Im Prinzip arbeitet das das Wärmespeichersystem genau gleich wie die Akkus, nur mit viel mehr Speicherkapazität. 
Der Wärmespeicher kann 60 ku aufnehmen und abgeben.

Damit das Wärmespeichersystem funktioniert, müssen alle Blöcke (außer Betonhülle und Gravel) mit Hilfe eines Forceloadblockes geladen sein.

[ta4_storagesystem|plan]


### TA4 Wärmetauscher / Heat Exchanger

Der Wärmetauscher besteht aus 3 Teilen, die aufeinander gesetzt werden müssen, wobei der Pfeil des ersten Blockes Richtung Turbine zeigen muss. Die Rohrleitungen müssen mit den gelben TA4 Röhren aufgebaut werden.
Der Wärmetauscher muss am Stromnetz angeschlossen werden. Der Wärmetauscher kann 60 ku aufnehmen.

[ta4_heatexchanger|image]


### TA4 Turbine

Die Turbine ist Teil des Energiespeichers. Sie muss neben den Generator gesetzt und über TA4 Röhren, wie im Plan abgebildet, mit dem Wärmetauscher verbunden werden.

[ta4_turbine|image]


### TA4 Generator

Der Generator dient zur Stromerzeugung. Daher muss auch der Generator am Stromnetz angeschlossen werden. 

Der Generator kann 60 ku abgeben.

[ta4_generator|image]


### TA4 Rohrzulauf / TA4 Pipe Inlet

Je ein Rohrzulaufblock muss auf beiden Seiten des Speicherblockes eingebaut werden. Die Blöcke müssen sich exakt gegenüber stehen.

Die Rohrzulaufblöcke können **nicht** als normale Wanddurchbrüche verwendet werden, dazu die TA3 Rohr/Wanddurchbruch / TA3 Pipe Wall Entry Blöcke verwenden.

[ta4_pipeinlet|image]


### TA4 Röhre / Pipe

Die gelben Röhren dienen bei TA4 zur Weiterleitung von Gas und Flüssigkeiten. 
Die maximale Leitungslänge beträgt 100 m.

[ta4_pipe|image]

## Wasserstoff

Strom kann mittels Elektrolyse in Wasserstoff und Sauerstoff aufgespalten werden. Auf der anderen Seite kann über eine Brennstoffzelle Wasserstoff mit Sauerstoff aus der Luft wieder in Strom umgewandelt werden.
Damit können Stromspitzen oder ein Überangebot an Strom in Wasserstoff umgewandelt und so gespeichert werden.

Im Spiel kann Strom mit Hilfe des Elektrolyseurs in Wasserstoff und Wasserstoff über die Brennstoffzelle wieder in Strom umgewandelt werden.
Damit kann Strom (in Form von Wasserstoff) nicht nur in Tanks gelagert, sonder mit Hilfe von Gasflaschen auch mit Wagen (carts) transportiert werden.

Die Umwandlung von Strom in Wasserstoff und zurück ist aber verlustbehaftet. Von 100 Einheiten Strom kommen nach der Umwandlung in Wasserstoff und zurück nur 83 Einheiten Strom wieder raus.

[ta4_hydrogen|image]


### Elektrolyseur

Der Elektrolyseur wandelt Strom in Wasserstoff um.  
Es muss von links mit Strom versorgt werden. Rechts kann Wasserstoff über Röhren und Pumpen entnommen werden.

Der Elektrolyseur kann bis zu 30 ku an Strom aufnehmen und generiert dann alle 4 s ein Wasserstoff Item.
In den Elektrolyseur passen 200 Einheiten Wasserstoff.

[ta4_electrolyzer|image]


### Brennstoffzelle

Die Brennstoffzelle wandelt Wasserstoff in Strom um.  
Sie muss von links per Pumpe mit Wasserstoff versorgt werden. Rechts ist der Stromanschluss.

Die Brennstoffzelle kann bis zu 25 ku an Strom abgeben und benötigt dazu alle 4 s ein Wasserstoff Item.

[ta4_fuelcell|image]


## Chemischer Reaktor / chemical reactor

Der Reaktor dient dazu, die über den Destillationsturm oder aus anderen Rezepten gewonnenen Zutaten zu neuen Produkten weiter zu verarbeiten. Der Plan links zeigt nur eine mögliche Variante, da die Anordnung der Silos und Tanks rezeptabhängig ist.

Ein Reaktor besteht aus:
- div. Tanks und Silos mit den Zutaten, die über Leitungen mit dem Dosierer verbunden sind
- optional einem Reaktorsockel, welcher die Abfälle aus dem Reaktor ableitet (nur bei Rezepten mit zwei Ausgangsstoffen notwendig)
- dem Reaktorständer, der auf den Sockel gesetzt werden muss (sofern vorhanden). Der Ständer hat einen Stromanschluss und zieht bei Betrieb 8 ku.
- dem eigentlichen Reaktorbehälter, der auf den Reaktorständer gesetzt werden muss
- dem Einfüllstutzen der auf den Reaktorbehälter gesetzt werden muss
- dem Dosierer, welcher über Leitungen mit den Tanks oder Silos sowie dem Einfüllstutzen verbunden werden muss

Hinweis 1: Flüssigkeiten werden nur in Tanks gelagert, Stoffe in Pulverform nur in Silos. Dies gilt für Zutaten und Ausgangsstoffe.

Hinweis 2: Tanks oder Silos mit verschiedenen Inhalten dürfen nicht zu einem Leitungssystem verbunden werden. Mehrere Tanks oder Silos mit gleichem Inhalt dürfen dagegen parallel an einer Leitung hängen.

Beim Cracken werden lange Kette von Kohlenwasserstoffen unter Verwendung eines Katalysator in kurze Ketten gebrochen.
Als Katalysator dient Gibbsitpulver (wird nicht verbraucht). Damit kann Bitumen in Schweröl, Schweröl in Naphtha und Naphtha in Benzin umgewandelt werden.

Bei der Hydrierung werden einem Molekül Paare von Wasserstoffatomen hinzugefügt, um kurzkettige Kohlenwasserstoffe in lange umzuwandeln. Hier wird Eisenpulver als Katalysator benötigt (wird nicht verbraucht). Damit kann Benzin in Naphtha, 
Naphtha in Schweröl und Schweröl in Bitumen umgewandelt werden.

[ta4_reactor|plan]


### TA4 Dosierer / doser

Teil des Chemischen Reaktors.
Auf allen 4 Seiten der Dosierers können Leitungen für Eingangsmaterialien angeschlossen werden. Nach oben werden die Materialien für den Reaktor ausgegeben.

Über den Dosierer kann das Rezept eingestellt und der Reaktor gestartet werden.

Wie auch bei anderen Maschinen:
- geht der Dosierer in den standby Zustand, so fehlen ein oder mehrere Zutaten
- geht der Dosierer in den blocked Zustand, so ist Ausgangstank oder Silo voll, defekt oder falsch angeschlossen

Der Dosierer benötigt keinen Strom. Alle 10 s wird ein Rezept abgearbeitet.

[ta4_doser|image]

### TA4 Reaktor / reactor

Teil des Chemischen Reaktors. Der Reaktor verfügt über ein Inventar für die Katalysator 
Gegenstände (für Cracking- und Hydrierungs-Rezepte).

[ta4_reactor|image]


### TA4 Einfüllstutzen / fillerpipe

Teil des Chemischen Reaktors. Muss auf den Reaktor gesetzt werden. Wenn dies nicht klappt, ggf. das Rohr an der Position darüber nochmals entfernen und neu setzen.

[ta4_fillerpipe|image]


### TA4 Reaktorständer / reactor stand

Teil des Chemischen Reaktors. Hier ist auch der Stromanschluss für den Reaktor. Der Reaktor benötigt 8 ku Strom.

Der Ständer hat zwei Leitungsanschlüsse, nach rechst für das Ausgangsprodukt und nach unten für den Abfall, wie bspw. Rotschlamm bei der Aluminiumherstellung.

[ta4_reactorstand|image]


### TA4 Reaktorsockel / reactor base

Teil des Chemischen Reaktors. Wird für den Abfluss des Abfallproduktes benötigt.

[ta4_reactorbase|image]


### TA4 Silo / silo

Teil des Chemischen Reaktors. Wird zur Aufbewahrung von Stoffen in Pulver- oder Granulatform benötigt.

[ta4_silo|image]




## ICTA Controller

Der ICTA Controller (ICTA steht für "If Condition Then Action") dient zur Überwachung und Steuerung von Maschinen. Mit dem Controller kann man Daten von Maschinen und anderen Blöcken einlesen und abhängig davon andere Maschinen und Blöcke ein-/ausschalten.

Einlesen von Maschinendaten sowie das Steuern von Blöcken und Maschinen erfolgt über sogenannte Kommandos. Für das Verständnis, wie Kommandos funktionieren, ist das Kapitel TA3 -> Logik-/Schalt-Blöcke wichtig. 

Der Controller benötigt für den Betrieb eine Batterie. Das Display dient zur Ausgabe von Daten, der Signal Tower zur Anzeige von Fehlern.

[ta4_icta_controller|image]



### TA4 ICTA Controller

Der Controller arbeitet auf das Basis von ```IF <condition> THEN <action>``` Regeln. Es können bis zu 8 Regeln pro Controller angelegt werden.

Beispiele für Regeln sind:

- Wenn ein Verteiler verstopft ist (```blocked```), soll der Schieber davor ausgeschaltet werden
- Wenn eine Maschine einen Fehler anzeigt, soll dieser auf dem Display ausgegeben werden

Der Controller prüft diese Regeln zyklisch. Dazu muss pro Regel eine Zykluszeit in Sekunden (```Cycle/s```) angegeben werden (1..1000). 

Für Regeln die einen on/off Eingang auswerten, bspw. von einen Schalter oder Detektor, muss als Zykluszeit 0 angegeben werden. Der Wert 0 bedeutet, dass diese Regel immer dann ausgeführt werden soll, wenn sich das Eingangssignal geändert hat, also bspw. der Button einen neuen Wert gesendet hat.

Alle Regeln sollten nur so oft wie notwendig ausgeführt werden. Dies hat zwei Vorteile:

- die Batterie des Controllers hält länger (jeder Controller benötigt eine Batterie)
- die Last für den Server ist geringer (damit weniger Lags)

Man muss für jede action eine Verzögerungszeit (```after/s```) einstellen. Soll die Aktion sofort ausgeführt werden, ist 0 einzugeben.

Der Controller hat eine eigene Hilfe und Hinweise zu allen Kommandos über das Controller-Menü.

[ta4_icta_controller|image]

### Batterie

Die Batterie muss in unmittelbarer Nähe zum Controller platziert werden, also an einer der 26 Positionen um den Controller herum.

[ta4_battery|image]

### TA4 Display

Das Display zeigt nach dem Platzieren seine Nummer an. Über diese Nummer kann das Display angesprochen werden. Auf dem Display können Texte ausgegeben werden, wobei das Display 5 Zeilen und damit 5 unterschiedliche Texte darstellen kann.

Das Display wird maximal ein mal pro Sekunde aktualisiert.

[ta4_display|image]

### TA4 Display XL

Das TA4 Display XL hat die doppelte Größ wie das TA4 Display.

Das Display wird maximal alle zwei Sekunden aktualisiert.

[ta4_displayXL|image]


### TA4 Signal Tower

Der Signal Tower kann rot, grün und orange anzeigen. Eine Kombination der 3 Farben ist nicht möglich.

[ta4_signaltower|image]



## TA4 Lua Controller

Der Lua Controller muss, wie der Name schon sagt, in der Programmiersprache Lua programmiert werden. Außerdem sollte man etwas Englisch können (oder Google bemühen), denn die Anleitung dazu gibt es nur in Englisch:

https://github.com/joe7575/techage/blob/master/manuals/ta4_lua_controller_EN.md

Auch der Lua Controller benötigt eine Batterie. Die Batterie muss in unmittelbarer Nähe zum Controller platziert werden, also an einer der 26 Positionen um den Controller herum.

[ta4_lua_controller|image]

### TA4 Lua Server

Der Server dient zur zentralen Speicherung von Daten von mehreren Lua Controllern. Es speichert auch die Daten über einen Server-Neustart hinweg.

[ta4_lua_server|image]

### TA4 Sensor Kiste/Chest

Die TA4 Sensor Kiste dient zum Aufbau von Automatischen Lagern oder Verkaufsautomaten in Verbindung mit dem Lua Controller.
Wird etwas in die Kiste gelegt, oder entnommen, oder eine der Tasten "F1"/"F2" gedrückt, so wird ein Event-Signal an den Lua Controller gesendet.
Die Sensor Kiste unterstützt folgende Kommandos:

- Über `state = $read_data(<num>, "state")` kann der Status der Kiste abgefragt werden. Mögliche Antworten sind: "empty", "loaded", "full"
- Über `name, action = $read_data(<num>, "action")` kann die letzte Spieleraktion abgefragt werden. `name` ist der Spielername, Als `action` wird zurückgeliefert: "put", "take", "f1", "f2".
- Über `stacks = $read_data(<num>, "stacks")` kann der Inhalt der Kiste ausgelesen werden. Siehe dazu: https://github.com/joe7575/techage/blob/master/manuals/ta4_lua_controller_EN.md#sensor-chest
- Über `$send_cmnd(<num>, "text", "press both buttons and\nput something into the chest")` kann der Text im Menü der Sensor Kiste gesetzt werden.

Über die Checkbox "Erlaube öffentlichen Zugriff" kann eingestellt werden, ob die Kiste von jedem genutzt werden darf, oder nur von Spielern die hier Zugriffsrechte haben.


[ta4_sensor_chest|image]

### TA4 Lua Controller Terminal

Das Terminal dient zur Ein-/Ausgabe für den Lua Controller.

[ta4_terminal|image]



## TA4 Logik-/Schalt-Module

### TA4 Taster/Schalter / Button/Switch

Beim TA4 Taster/Schalter hat sich nur das Aussehen geändert. Die Funktionalität ist gleich wie beim TA3 Taster/Schalter.

[ta4_button|image]

### TA4 Spieler Detektor / Player Detector

Beim TA4 Spieler Detektor hat sich nur das Aussehen geändert. Die Funktionalität ist gleich wie beim TA3 Spieler Detektor.

[ta4_playerdetector|image]

### TA4 Zustandssammler / State Collector

[ta4_collector|image]

Der Zustandssammler fragt der Reihe nach alle konfigurierten Maschinen nach dem Status ab. Wenn eine der Maschinen einen vorkonfigurierte Status erreicht oder überschritten hat, wird ein "on" Kommando gesendet. Damit können bspw. vom einem Lua Controller aus sehr einfach viele Maschinen auf Störungen überwacht werden.

### TA4 Detektor / Detector

Die Funktionalität ist gleich wie beim TA3 Detektor / Detector. Zusätzlich zählt der Detector aber die weitergegebenen Items. 
Diesen Zähler kann man über das Kommando 'count' abfragen und über 'reset' zurücksetzen.

[ta4_detector|image]


## TA4 Lampen

TA4 beinhaltet eine Reihe von leistungsstarken Lampen, die eine bessere Ausleuchtung ermöglichen oder Spezialaufgaben übernehmen.

### TA4 LED Pflanzenlampe / TA4 LED Grow Light

Die TA4 LED Pflanzenlampe ermöglicht ein schnelles und kräftiges Wachstum aller Pflanzen aus der `farming` Mod. Die Lampe beleuchtet ein 3x3 großes Feld, so dass sich damit auch Pflanzen unter Tage anbauen lassen.
Die Lampe muss mit einem Abstand von einem Block über dem Boden in der Mitte des 3x3 Feldes platziert werden.

Zusätzlich kann  die Lampe auch zur Blumenzucht genutzt werden. Wird die Lampe über ein 3x3 großes Blumenbeet aus "Garden Soil" (Mod `compost`) platziert, so wachsen dort die Blumen ganz von selbst (über und unter Tage).

Abernten kann man die Blumen mit den Signs Bot, der auch über ein entsprechendes Zeichen verfügt, das vor das Blumenfeld gestellt werden muss.

Die Lampe benötigt 1 ku Strom.

[ta4_growlight|image]

### TA4 LED Straßenlampe / TA4 LED Street Lamp

Die TA4 LED Straßenlampe ist eine Lampe mit besonders starker Ausleuchtung. Die Lampe besteht aus dem Lampengehäuse, Lampenarm und Lampenmast Blöcken.

Der Strom muss von unten durch den Mast nach oben zum Lampengehäuse geführt werden. Dazu zuerst die Stromleitung nach oben ziehen und das Stromkabel dann mit Lampenmast Blöcken "verputzen".

Die Lampe benötigt 1 ku Strom.

[ta4_streetlamp|image]

### TA4 LED Industrielampe / TA4 LED Industrial Lamp

Die TA4 LED Industrielampe ist eine Lampe mit besonders starker Ausleuchtung. Die Lampe muss von oben mit Strom versorgt werden.

Die Lampe benötigt 1 ku Strom.

[ta4_industriallamp|image]




## TA4 Flüssigkeitsfilter

Im Flüssigkeitsfilter wird Rotschlamm gefiltert.
Dabei entsteht entweder Lauge, welche unten in einem Tank gesammelt werden kann oder Wüstenkopfsteinpflaster, welches sich im Filter absetzt.
Wenn der Filter zu sehr verstopft ist, muss er geleert und neu befüllt werden.
Der Filter besteht aus einer Fundament-Ebene, auf der 7 identische Filterschichten platziert werden. 
Ganz oben befindet sich die Einfüllebene.

[ta4_liquid_filter|image]

### Fundament-Ebene

Der Aufbau dieser Ebene kann dem Plan entnommen werden.

Im Tank wird die Lauge gesammelt.

[ta4_liquid_filter_base|plan]

### Schotter-Ebene

Diese Ebene muss so wie im Plan gezeigt mit Schotter befüllt werden.
Insgesamt müssen sieben Lagen Schotter übereinander liegen.
Dabei wird mit der Zeit der Filter verunreinigt, sodass das Füllmaterial erneuert werden muss.

[ta4_liquid_filter_gravel|plan]

### Einfüll-Ebene

Diese Ebene dient zum Befüllen des Filters mit Rotschlamm.
In den Einfüllstutzen muss Rotschlamm mittels einer Pumpe geleitet werden.

[ta4_liquid_filter_top|plan]




## Weitere TA4 Blöcke

### TA4 Tank / TA4 Tank

Siehe TA3 Tank.

In einen TA4 Tank passen 2000 Einheiten oder 200 Fässer einer Flüssigkeit.

[ta4_tank|image]

### TA4 Pumpe / TA4 Pump

Siehe TA3 Pumpe.

Die TA4 Pumpe pumpt 8 Einheiten Flüssigkeit alle zwei Sekunden.

[ta4_pump|image]

### TA4 Ofenheizung / furnace heater

Mit TA4 hat der Industrieofen auch seine elektrische Heizung. Der Ölbrenner und auch das Gebläse können mit der Ofenheizung ersetzt werden.

Die Ofenheizung benötigt 14 ku Strom.

[ta4_furnaceheater|image]

### TA4 Wasserpumpe / Water Pump

Mit der Wasserpumpe kann Wasser über Flüssigkeitsleitungen in Tanks gepumpt und so für Rezepte genutzt werden. Die Wasserpumpe muss dazu ins Meer gesetzt werden Ein "Pool" aus ein paar Wasserblöcken geht nicht!

[ta4_waterpump|image]

### TA4 Röhren / TA4 Tube

TA4 hat auch seine eigenen Röhren im TA4 Design. Diese können wie Standard Röhren eingesetzt werden.
Aber: TA4 Schieber und TA4 Verteiler erreichen ihre volle Leistungsfähigkeit nur beim Einsatz mit TA4 Röhren.

[ta4_tube|image]

### TA4 Schieber / Pusher

Die Funktion entspricht grundsätzlich der von TA2/TA3. Zusätzlich kann aber über ein Menü konfiguriert werden, welche Gegenstände aus einer TA4 Kiste geholt und weiter transportiert werden sollen.
Die Verarbeitungsleistung beträgt 12 Items alle 2 s, sofern auf beiden Seiten TA4 Röhren verwendet werden. Anderenfalls sind es nur 6 Items alle 2 s.

Der TA4 Schieber besitzt zwei zusätzliche Kommandos für den Lua Controller:

- `config` dient zur Konfiguration des Schiebers, analog zum manuellen Konfiguration über das Menü.
  Beispiel:  `$send_cmnd(1234, "config", "default:dirt")`
- `pull` dient zum Absetzen eines Auftrags an den Schieber:
  Beispiel: `$send_cmnd(1234, "pull", "default:dirt 8")`
  Als Nummer sind Werte von 1 bis 12 zulässig. Danach geht der Schieber wieder in den `stopped` Mode und sendet ein "off" Kommando zurück an den Sender des "pull" Kommandos.

[ta4_pusher|image]

### TA4 Kiste / TA4 Chest

Die Funktion entspricht der von TA3. Die Kiste kann aber mehr Inhalt aufnehmen.

Zusätzlich besitzt die TA4 Kiste ein Schatteninventar zur Konfiguration. Hier können bestimmte Speicherplätze mit einem Item vorbelegt werden. Vorbelegte Speicherplätze werden beim Füllen nur mit diesen Items belegt. Zum Leeren eines vorbelegten Speicherplatzes wird ein TA4 Schieber oder TA4 Injektor mit entsprechender Konfiguration benötigt.

[ta4_chest|image]

### TA4 8x2000 Kiste / TA4 8x2000 Chest

Die TA4 8x2000 Kiste hat kein normales Inventar wir andere Kisten, sondern verfügt über 8 Speicher, wobei jeder Speicher bis zu 2000 Items einer Sorte aufnehmen kann. Über die orangefarbenen Taster können Items in den Speicher verschoben bzw. wieder heraus geholt werden. Die Kiste kann auch wie sonst üblich mit einem Schieber (TA2, TA3 oder TA4) gefüllt bzw. geleert werden.

Wird die Kiste mit einem Schieber gefüllt, so füllen sich alle Speicherplätze von links nach rechts. Sind alle 8 Speicher voll und können keine weiteren Items hinzugefügt werden, so werden weitere Items werden abgewiesen.

**Reihenfunktion**

Mehrere TA4 8x2000 Kisten können zu einer großen Kiste mit mehr Inhalt verbunden werden. Dazu müssen die Kisten in einer Reihe hintereinander gesetzt werden.

Zuerst muss die Front-Kiste gesetzt werden, dann werden die Stapel-Kisten mit gleicher Blickrichtung dahinter gesetzt (alle Kisten haben die Front in Richtung Spieler). Bei 2 Kisten in Reihe erhöht sich die Größe auf 8x4000, usw.

Die angereihten Kisten können nun nicht mehr entfernt werden. Um die Kisten wieder abbauen zu können, gibt es zwei Möglichkeiten:

- Die Frontkiste leeren und entfernen. Damit wird die nächste Kiste entsperrt und kann entfernt werden.
- Die Frontkiste soweit leeren dass alle Speicherplätzen maximal 2000 Items beinhalten. Damit wird die nächste Kiste entsperrt und kann entfernt werden.

Die Kisten haben eine "Reihenfolge" Checkbox. Wird diese Checkbox aktiviert, werden die Speicherplätze durch einen Schieber nicht mehr vollständig entleert. Das letzte Item verbleibt als Vorbelegung in dem Speicherplatz. Damit ergibt sich eine feste Zuordnung von Items zu Speicherplätzen.

Die Kiste kann nur von den Spielern genutzt werden, die an diesem Ort auch bauen können, also Protection Rechte besitzen. Es spielt dabei keine Rolle, wer die Kiste setzt. 

Der Kiste besitzt ein zusätzliches Kommandos für den Lua Controller:

- `count` dient zur Anfrage, wie viele Items in der Kiste sind.
  Beispiel 1:  `$read_data(CHEST, "count")`  --> Summe der Items über alle 8 Speicher
  Beispiel 2:  `$read_data(CHEST, "count", 2)`  --> Anzahl der Items in Speicher 2 (zweiter von links)

[ta4_8x2000_chest|image]



### TA4 Verteiler / Distributor

Die Funktion entspricht der von TA2.  
Die Verarbeitungsleistung beträgt 24 Items alle 4 s, sofern auf allen Seiten TA4 Röhren verwendet werden. Anderenfalls sind es nur 12 Items alle 4 s.

[ta4_distributor|image]

### TA4 Hochleistungs-Verteiler / High Performance Distributor

Die Funktion entspricht dem normalen TA4 Verteiler, mit zwei Unterschieden:
Die Verarbeitungsleistung beträgt 36 Items alle 4 s, sofern auf allen Seiten TA4 Röhren verwendet werden. Anderenfalls sind es nur 18 Items alle 4 s.
Außerdem können pro Ausgang bis zu 8 Items konfiguriert werden.

[ta4_high_performance_distributor|image]

### TA4 Kiessieb / Gravel Sieve

Die Funktion entspricht der von TA2.  
Die Verarbeitungsleistung beträgt 4 Items alle 4 s. Der Block benötigt 5 ku Strom.

[ta4_gravelsieve|image]

### TA4 Mühle / Grinder

Die Funktion entspricht der von TA2.  
Die Verarbeitungsleistung beträgt 4 Items alle 4 s. Der Block benötigt 9 ku Strom.

[ta4_grinder|image]

### TA4 Steinbrecher / Quarry

Die Funktion entspricht weitgehend der von TA2. 

Zusätzlich kann die Lochgröße zwischen 3x3 und 11x11 Blöcken eingestellt werden. 
Die maximale Tiefe beträgt 80 Meter. Der Steinbrecher benötigt 14 ku Strom.

[ta4_quarry|image]

### TA4 Elektronikfabrik / Electronic Fab

Die Funktion entspricht der von TA2, nur werden hier verschiedene Chips produziert.  
Die Verarbeitungsleistung beträgt ein Chip alle 6 s. Der Block benötigt hierfür 12 ku Strom.

[ta4_electronicfab|image]

### TA4 Injektor / Injector

Der Injektor ist ein TA4 Schieber mit speziellen Eigenschaften. Er besitzt ein Menü zur Konfiguration. Hier können bis zu 8 Items konfiguriert werden. Er entnimmt nur diese Items einer Kiste (TA4 Kiste oder TA4 8x2000 Kiste) um sie an Maschinen mit Rezepturen weiterzugeben (Autocrafter, Industrieofen und Elektronikfabrik). 

Beim Weitergeben wird in der Zielmaschine pro Item nur eine Position im Inventar genutzt. Sind bspw. nur die ersten drei Einträge im Injektor konfiguriert, so werden auch nur die ersten drei Speicherplätze im Inventar der Maschine belegt. Damit wir ein Überlauf im Inventar der Maschine verhindert. 

Die Verarbeitungsleistung beträgt bis zu 8 Items alle 3 Sekunden.

[ta4_injector|image]
