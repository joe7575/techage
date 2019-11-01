# TA4: Zukunft

Regenerative Energiequellen wie Wind, Sonne und Biokraft helfen dir, das Ölzeitalter zu verlassen. Mit modernen Technologien und intelligenten Maschinen machst du dich auf in die Zukunft.

[techage_ta4|image]


## Windkraftanlage

Eine Windkraftanlagen liefern immer dann Strom, wenn Wind vorhanden ist. Im Spiel gibt es keinen Wind, aber die Mod simuliert dies dadurch, dass sich nur morgens (5:00 - 9:00) und abends (17:00 - 21:00) die Windräder drehen und damit Strom liefern, sofern diese an geeigneten Stellen errichtet werden.

Die TA Windkraftanlagen sind reine Offshore Anlagen, das heißt, die müssen im Meer (Wasser) errichtet werden. Dies bedeutet, dass um den Mast herum mit einem Abstand von 20 Blöcken nur Wasser sein darf und das mindestens 2 Blöcke tief.
Der Rotor muss in einer Höhe (Y-Koordinate) von 12 bis maximal 20 m platziert werden. Der Abstand zu weiteren Windkraftanlagen muss mindestens 14 m betragen.

Der Strom muss vom Rotor-Block durch den Mast nach unten geführt werden. Dazu zuerst die Stromleitung nach oben ziehen und das Stromkabel dann mit TA4 Säulenblöcke "verputzen". Unten kann eine Arbeitsplattform errichtet werden. Der Plan rechts zeigt den Aufbau im oberen Teil.

Die Windkraftanlage liefert eine Leistung von 80 ku, aber dies nur 8 Stunden am Tag (siehe oben).

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
Es kann aber auch Wasserstoff produziert werden, welcher sich transportieren und am Ziel wieder zu Strom umwandeln lässt (geplant).

Die kleinste Einheit bei einer Solaranlage sind zwei Solarmodule und ein Trägermodul. Das Trägermodul muss zuerst gesetzt werden, die zwei Solarmodule dann links und rechts daneben (nicht darüber!).

Der Plan rechts zeigt 3 Einheiten mit je zwei Solarmodulen und einem Trägermodul, über rote Kabel mit dem Wechselrichter verbunden.

Solarmodule liefern Gleichspannung, welcher nicht direkt in das Stromnetz eingespeist werden kann. Daher müssen zuerst die Solareinheiten über das rote Kabel mit dem Wechselrichter verbunden werden. Dieser besteht aus zwei Blöcken, einen für das rote Kabel zu den Solarmodulen (DC) und einen für das graue Stromkabel ins Stromnetz (AC).

Der Kartenbereich, wo die Solaranlage steht, muss komplett geladen sein. Es empfiehlt sich daher, zuerst einen Forceload Block zu setzen, und dann innerhalb dieses Bereiches die Module zu platzieren.

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
Ein Wechselrichter, bestehend aus zwei Blöcken kann maximal 100 ku an Strom einspeisen, was 33 Solarmodulen oder auch mehr entspricht.
Der DC Block muss links neben den AC-Block gesetzt werden.

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

In der Betonhülle darf ein Fenster aus einem Obsidian Glas Block sein. Dieses muss ziemlich in der Mitte der Wand platziert werden. Durch dieses Fenster sieht man, ob der Speicher zu mehr aus 80 % geladen ist. Im Plan rechts sieht man den Aufbau aus TA4 Wärmetauscher  bestehend aus 3 Blöcken, der TA4 Turbine und dem TA4 Generator. Beim Wärmetauscher ist auf die Ausrichtung achten (der Pfeil bei Block 1 muss zur Turbine zeigen).

Entgegen dem Plan rechts müssen die Anschlüsse am Speicherblock auf gleicher Ebene sein (horizontal angeordnet, also nicht unten und oben). Die Rohrzuläufe (TA4 Pipe Inlet) müssen genau in der Mitte der Wand sein und stehen sich damit gegenüber. Als Röhren kommen die TA4 Röhren zum Einsatz. Die TA4 Verbindungsrohre dürfen hier nicht verwendet werden.
Sowohl der Generator als auch der Wärmetauscher haben einen Stromanschluss und müssen mit dem Stromnetz verbunden werden.

Im Prinzip arbeitet das das Wärmespeichersystem genau gleich wie die Akkus, nur mit viel mehr Speicherkapazität. 
Der Wärmespeicher kann 60 ku aufnehmen und abgeben.

Damit das Wärmespeichersystem funktioniert, müssen alle Blöcke (außer Betonhülle und Gravel) mit Hilfe eines Forceloadblockes geladen sein.

[ta4_storagesystem|plan]


### TA4 Wärmetauscher / Heat Exchanger

Der Wärmetauscher besteht aus 3 Teilen, die aufeinander gesetzt werden müssen, wobei der Pfeil des ersten Blockes Richtung Turbine zeigen muss. Die Dampfleitungen müssen mit den TA4 Röhren aufgebaut werden.
Der Wärmetauscher muss am Stromnetz angeschlossen werden. Der Wärmetauscher kann 60 ku aufnehmen.

[ta4_heatexchanger|image]


### TA4 Turbine

Die Turbine ist Teil des Energiespeichers. Sie muss neben den Generator gesetzt und über TA4 Röhren, wie im Plan abgebildet, mit dem Wärmetauscher verbunden werden.

[ta4_turbine|image]


### TA4 Generator

Der Generator dient zur Stromerzeugung. Daher muss auch der Generator am Stromnetz angeschlossen werden. Dabei muss beachtet werden, dass es ein funktionierendes Stromnetz ist, denn der Generator des Energiespeichers kann nicht als einzelne Stromquelle funktionieren. Der Generator kann 60 ku abgeben.

[ta4_generator|image]


### TA4 Röhre / Pipe

Die Röhren dienen bei TA4 zur Weiterleitung von Gas und Dampf. 
Die maximale Leitungslänge beträgt 100 m.

[ta4_pipe|image]


## Wasserstoff

Strom kann mittels Elektrolyse in Wasserstoff und Sauerstoff aufgespalten werden. Auf der anderen Seite kann über eine Brennstoffzelle Wasserstoff mit Sauerstoff aus der Luft wieder in Strom umgewandelt werden.
Damit können Stromspitzen oder ein Überangebot an Strom in Wasserstoff umgewandelt und so gespeichert werden.

Im Spiel kann Strom mit Hilfe des Elektrolyseurs in Wasserstoff-Items und Wasserstoff-Items über die Brennstoffzelle wieder in Strom umgewandelt werden.
Damit kann Strom (in Form von Wasserstoff-Items) nicht nur in Kisten gelagert, sonder auch über Wagen (carts) oder Röhren transportiert werden.

Die Umwandlung von Strom in Wasserstoff und zurück ist aber verlustbehaftet. Von 100 Einheiten Strom kommen nach der Umwandlung in Wasserstoff und zurück nur 75 Einheiten Strom wieder raus.

[ta4_hydrogen|image]


### Elektrolyseur

Der Elektrolyseur wandelt Strom in Wasserstoff um.  
Es muss von links mit Strom versorgt werden. Rechts können die Wasserstoff-Items per Schieber entnommen werden.

Der Elektrolyseur kann bis zu 40 ku an Strom aufnehmen und generiert alle 8 s ein Wasserstoff Item.

[ta4_electrolyzer|image]


### Brennstoffzelle

Die Brennstoffzelle wandelt Wasserstoff in Strom um.  
Sie muss von links per Schieber mit Wasserstoff-Items versorgt werden. Rechts ist der Stromanschluss.

Die Brennstoffzelle kann bis zu 40 ku an Strom abgeben und benötigt dazu alle 6 s ein Wasserstoff Item.

[ta4_fuelcell|image]





