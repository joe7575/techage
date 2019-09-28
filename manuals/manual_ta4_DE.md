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

Diese glänzt noch durch Abwesenheit.
Aber es gibt schon die...

### TA4 Straßenlampen-Solarzelle / Streetlamp Solar Cell

Die Straßenlampen-Solarzelle dient, wie der Name schon sagt, zur Stromversorgung einer Straßenlampe. Dabei kann eine Solarzelle zwei Lampen versorgen. Die Solarzelle speichert die Sonnenenergie tagsüber und gibt den Strom Nachts an die Lampe ab. Das bedeutet, die Lampe leuchtet nur im Dunkeln.

[ta4_minicell|image]


## Biogasanlage

noch nicht vorhanden...


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
Der Wärmetauscher muss am Stromnetz angeschlossen werden.

[ta4_heatexchanger|image]


### TA4 Turbine

Die Turbine ist Teil des Energiespeichers. Sie muss neben den Generator gesetzt und über TA4 Röhren, wie im Plan abgebildet, mit dem Wärmetauscher verbunden werden.

[ta4_turbine|image]


### TA4 Generator

Der Generator dient zur Stromerzeugung. Daher muss auch der Generator am Stromnetz angeschlossen werden. Dabei muss beachtet werden, dass es ein funktionierendes Stromnetz ist, denn der Generator des Energiespeichers kann nicht als einzelne Stromquelle funktionieren.

[ta4_generator|image]


### TA4 Röhre / Pipe

Die Röhren dienen bei TA4 zur Weiterleitung von Gas und Dampf. 
Die maximale Leitungslänge beträgt 100 m.

[ta4_pipe|image]
