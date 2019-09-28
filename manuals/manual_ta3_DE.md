# TA3: Ölzeitalter

Bei TA3 gilt es, die Dampf-betriebenen Maschinen durch leistungsfähigere und mit elektrischem Strom betriebene Maschinen abzulösen.

Dazu musst du Kohlekraftwerke und Generatoren bauen. Bald wirst du sehen, dass dein Strombedarf nur mit Öl-betriebenen Kraftwerken zu decken ist. Also machst du dich auf die Suche nach Erdöl. Bohrtürme und Ölpumpen helfen die, an das Öl zu kommen. Schienenwege dienen dir zum Öltransport bis in die Kraftwerke.

Das Industrielle Zeitalter ist auf seinem Höhepunkt.

[techage_ta3](/image/)


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

Mehrere Verbraucher und Generatoren können in einem Stromnetzwerk zusammen betrieben werden. Mit Hilfe der Verteilerboxen können so große Netzwerke aufgebaut werden.
Wird zu wenig Strom bereitgestellt, gehen Teile der Verbraucher aus, bzw. Lampen beginnen zu flackern.
In diesem Zusammenhang ist auch wichtig, dass die Funktionsweise von Forceload Blöcken verstanden wurde, denn bspw. Generatoren liefern nur Strom, wenn der entsprechende Map-Block geladen ist. Dies kann mit einen Forceload Block erzwungen werden.

[ta3_powerswitch](/image/)


### TA Stromkabel

Für die lokale Verkabelung im Boden oder in Gebäuden.  
Abzweigungen können mit Hilfe von Verteilerboxen realisiert werden. Die maximale Kabellänge zwischen Maschinen oder Verteilerboxen beträgt 1000 m. Es können maximale 1000 Knoten in einem Strom-Netzwerk verbunden werden. Als Knoten zählen alle Generatoren, Akkus, Verteilerboxen und Maschinen.

Da die Stromkabel nicht automatisch geschützt sind, wird für längere Strecken die Überlandleitungen (TA Stromleitung) empfohlen.

Stromkabel können mit der Kelle verputzt also in der Wand oder im Boden versteckt werden. Als Material zum Verputzen können alle Stein-, Clay- und sonstige Blöcke ohne "Intelligenz" genutzt werden. Erde (dirt) geht nicht, da Erde zu Gras oder ähnlichem konvertiert werden kann, was die Leitung zerstören würde.

Zum Verputzen muss mit der Kelle auf das Kabel geklickt werden. Das Material, mit dem das Kabel verputzt werden soll, muss sich im Spieler-Inventar ganz links befinden.  
Die Kabel können wieder sichtbar gemacht werden, indem man mit der Kelle wieder auf den Block klickt.

Außer Kabel können auch die TA Verteilerbox und die TA Stromschalterbox verputzt werden.

[ta3_powercable](/image/)


### TA Verteilerbox

Mit der Verteilerbox kann Strom in bis zu 6 Richtungen verteilt werden. Verteilerboxen können auch mit der Kelle verputzt (versteckt) und wieder sichtbar gemacht werden.
Wird mit dem TechAge Info Werkzeug (Schraubenschlüssel) auf die Verteilerbox geklickt, wird angezeigt, wie viel Leistung die Generatoren liefern bzw. die Verbraucher im Netzwerk beziehen.

[ta3_powerjunction](/image/)


### TA Stromleitung

Mit der TA Stromleitung und den Strommasten können halbwegs realistische Überlandleitungen realisiert werden. Die Strommasten-Köpfe dienen gleichzeitig zum Schutz der Stromleitung (Protection). Dazu muss alle 16 m oder weniger ein Masten gesetzt werden. Der Schutz gilt aber nur die die Stromleitung und die Masten, alle anderen Blöcke in diesem Bereich sind dadurch nicht geschützt.

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
Der Akku Block ist eine sekundäre Stromquelle. Das bedeutet, bei Strombedarf werden zuerst die Generatoren genutzt. Nur wenn der Strom im Netz nicht ausreicht, springt der Akku Block ein. Das Gleiche gilt auch für die Stromaufnahme. Daher kann auch kein Akku mit einem anderen Akku geladen werden.
Der Akku liefert 10 ku bzw. nimmt 10 ku auf.
Bei Volllast kann ein Akku 400 s lang Strom aufnehmen und wenn er voll ist, auch wieder abgeben. Dies entspricht 8 h Spielzeit bei einem normalen Spieltag von 20 min.

[ta3_akkublock](/image/)


### TA3 Strom Terminal

Das Strom-Terminal muss von eine Verteilerbox platziert werden. Es zeigt Daten aus dem Stromnetz an wie:
- Leistung alle Generatoren
- Leistung alles Akkus (Sekundärquellen)
- Leistungsaufnahme aller Maschinen
- Anzahl der Netzwerk-Blöcke (max. 1000)
Die Daten des Terminals werden beim Öffnen des Menüs und dann nur durch Anklicken des "Update" Buttons aktualisiert.

[ta3_powerterminal](/image/)


## TA3 Industrieofen

Der TA3 Industrieofen dient als Ergänzung zu normalen Ofen (furnace). Damit können alle Waren mit "Koch" Rezepte, auch im Industrieofen hergestellt werden. Es gibt aber auch spezielle Rezepte, die nur im Industrieofen hergestellt werden können.
Der Industrieofen hat sein eigenes Menü zur Rezeptauswahl. Abhängig von den Waren im Industrieofen Inventar links kann rechts das Ausgangsprodukt gewählt werden.

Der Industrieofen benötigt Strom (für das Gebläse) sowie Kohle, Holzkohle oder Erdöl für die Befeuerung. Der Industrieofens und muss wie im Plan rechts abgebildet, zusammen gebaut werden.

Die Brennzeit für Kohle und Erdöl beträgt 80 s und für Holzkohle 240 s.

[ta3_furnace](/plan/)


### TA3 Ofen-Feuerkiste

Ist Teil des TA3 Industrieofen. Muss mit Kohle, Holzkohle oder Erdöl befeuert werden.

[ta3_furnacefirebox](/image/)


### TA3 Ofenoberteil

Ist Teil des TA3 Industrieofen. Siehe TA3 Industrieofen.

[ta3_furnace](/image/)


### TA3 Gebläse

Ist Teil des TA3 Industrieofen. Siehe TA3 Industrieofen.

[ta3_booster](/image/)


## Öl-Anlagen

Um deine Generatoren und Öfen mit Öl betrieben zu können, muss du zuerst nach Öl suchen und einen Bohrturm errichten und danach das Öl fördern.
Dazu dienen dir TA3 Ölexplorer, TA3 Ölbohrkiste und TA3 Ölpumpe.

[techage_ta3](/image/)


### TA3 Ölexplorer

Mit dem Ölexplorer kannst du nach Öl suchen. Dazu den Block auf den Boden setzen und mit Rechtsklick die Suche starten.
Über die Chat-Ausgabe wird dir angezeigt, in welcher Tiefe nach Öl gesucht wurde und wie viel Öl (oil) gefunden wurde.
Du kannst bis zu 4 mal auf den Block klicken, um auch in tieferen Bereichen nach Öl zu suchen. Ölfelder haben eine Größe von 2000 bis zu 20000 Items.

Falls die Suche erfolglos war, musst du den Block ca. 16 m weiter setzen.
Der Ölexplorer sucht immer innerhalb des ganzen Map-Blocks und darunter nach Öl, in dem er gesetzt wurde. Eine erneute Suche im gleichen Map-Block (16x16 Feld) macht daher keinen Sinn.

Falls Öl gefunden wurde, wird die Stelle für den Bohrturm angezeigt. Die Mitte des angezeigten Bereiches am besten gleich mit einem  Schild markieren und den ganzen Bereich gegen fremde Spieler schützen.

Gib die Suche nach Öl nicht zu schnell auf. Es kann wenn du Pech hast, sehr lange dauern, bis du eine Ölquelle gefunden hast.
Es macht auch keinen Sinn, einen Bereich den ein anderer Spieler bereits abgesucht hat, nochmals abzusuchen. Die Chance, irgendwo Öl zu finden, ist für alle Spieler gleich.

Der Ölexplorer kann immer wieder zur Suche nach Öl eingesetzt werden.

[ta3_oilexplorer](/image/)


### TA3 Ölbohrkiste

Die Ölbohrkiste muss genau an die Stelle gesetzt werden, die vom Ölexplorer angezeigt wurde.  
Wird auf den Button der Ölbohrkiste geklickt, wird über der Kiste ein Bohrturm errichtet. Dies dauert einige Sekunden.  
Die Ölbohrkiste hat 4 Seiten, bei IN muss das Bohrgestänge über Schieber angeliefert und bei OUT muss das Bohrmaterial abtransportiert werden. Über eine der anderen zwei Seiten muss die Ölbohrkiste mit Strom versorgt werden.

Die Ölbohrkiste bohrt bis zum Ölfeld (1 Meter in 16 s) und benötigt dazu 10 ku Strom.
Wurde das Ölfeld erreicht, kann der Bohrturm abgebaut und die Kiste entfernt werden.

[ta3_drillbox](/image/)


### TA3 Ölpumpe

An die Stelle der Ölbohrkiste muss nun die Ölpumpe platziert werden. Auch die Ölpumpe benötigt Strom (16 ku) und liefert alle 8 s ein Erdöl-Item, das in einer Kiste gesammelt werden muss. Dazu muss die Ölpumpe über eine Röhre mit der Kiste verbunden werden.
Ist alles Öl abgepumpt, kann auch die Ölpumpe wieder entfernt werden.

[ta3_pumpjack](/image/)


### TA3 Bohrgestänge

Das Bohrgestänge wird für die Bohrung benötigt. Es werden so viele Bohrgestänge Items benötigt wie als Tiefe für das Ölfeld angegeben wurde. Das Bohrgestänge ist nach der Bohrung nutzlos, kann aber auch nicht abgebaut werden und verbleibt im Boden.

[ta3_drillbit](/image/)


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

Dieser Status wird bei vielen Blöcken gleichzeitig auch über den Info-Text angezeigt.

[ta3_logic](/image/)


### TA3 Taster/Schalter

Der Taster/Schalter sendet `on`/`off` Kommandos zu den Blöcken, die über die Nummern konfiguriert wurden.
Der Taster/Schalter kann als Taster (button) oder Schalter (switch) konfiguriert werden. Wird er als Taster konfiguriert, so kann die Zeit zwischen den `on` und `off` Kommandos eingestellt werden.

Über die Checkbox "public" kann eingestellt werden, ob den Taster von jedem (gesetzt), oder nur vom Besitzer selbst (nicht gesetzt) genutzt werden darf.

Hinweis: Mit dem Programmer können Blocknummern sehr einfach eingesammelt und konfiguriert werden.

[ta3_button](/image/)


### TA3 Logikblock

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

[ta3_logic](/image/)


### TA3 Wiederholer

Der Wiederholer (repeater) sendet das empfangene Signal an alle konfigurierten Nummern weiter.
Dies kann bspw. Sinn machen, wenn man viele Blöcke gleichzeitig angesteuert werden sollen. Den Wiederholer kann man dazu mit dem Programmer konfigurieren, was nicht bei allen Blöcken möglich ist.

[ta3_repeater](/image/)


### TA3 Sequenzer

Der Sequenzer kann eine Reihe von `on`/`off` Kommandos senden, wobei der Abstand zwischen den Kommandos in Sekunden angegeben werden muss. Damit kann man bspw. eine Lampe blinken lassen.
Es können bis zu 8 Kommandos konfiguriert werden, jedes mit Zielblocknummer und Anstand zum nächsten Kommando.
Der Sequenzer wiederholt die Kommandos endlos, wenn "Run endless" gesetzt wird.
Wird also Kommando nichts ausgewählt, wird nur die angegeben Zeit in Sekunden gewartet.

[ta3_sequencer](/image/)


### TA3 Timer

Der Timer kann Kommandos Spielzeit-gesteuert senden. Für jede Kommandozeile kann die Uhrzeit, die Zielnummer(n) und das Kommando selbst angegeben werden. Damit lassen sich bspw. Lampen abends ein- und morgens wieder ausschalten.

[ta3_timer](/image/)


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

[ta3_terminal](/image/)


### TechAge Signallampe

Die Signallampe kann mit `on`/`off` Kommando ein- bzw. ausgeschaltet werden. Diese Lampe braucht keinen Strom und
kann mit der Spritzpistole farbig gemacht werden.

[ta3_signallamp](/image/)


### Tür/Tor Blöcke

Diese Blöcke kann man mit einem `off` Kommando verschwinden lassen und mit dem `on` Kommando wieder hervor zaubern.
Das Aussehen der Blöcke kann über das Block-Menü eingestellt werden.
Damit lassen sich Geheimtüren realisieren, die sich nur bei bestimmten Spielern öffnen (mit Hilfe des Spieler-Detektors).

[ta3_doorblock](/image/)



## Detektoren

Detektoren scannen ihre Umgebung ab und senden ein `on`-Kommando, wenn das Gesuchte erkannt wurde.

[ta3_nodedetector](/image/)


### TA3 Detektor

Der Detektor ist eine spezieller Röhrenblock, der erkennt, wenn Items über die Röhre weitergegeben werden. Es muss dazu auf beiden Seiten mit der Röhre verbunden sein.
Er sendet ein `on`, wenn ein Item erkannt wird, gefolgt von einem `off` eine Sekunde später.
Danach werden weitere Kommando für 8 Sekunden blockiert.

[ta3_detector](/image/)


### TA3 Wagen Detektor

Der Wagen Detektor sendet ein `on`-Kommando, wenn er einen Wagen/Cart (Minecart) direkt vor sich erkannt hat. Zusätzlich kann der Detektor auch den Wagen wieder starten, wenn ein `on`-Kommando empfangen wird.

[ta3_cartdetector](/image/)


### TA3 Block Detektor

Der Block Detektor sendet ein `on`-Kommando, wenn er erkennt, dass Blöcke vor ihm erscheinen oder verschwinden, muss jedoch entsprechend konfiguriert werden. Nach dem Zurückschalten des Detektors in den Standardzustand (grauer Block) wird ein `off`-Kommando gesendet. Gültige Blöcke sind alle Arten von Blöcken und Pflanzen, aber keine Tiere oder Spieler. Die Sensorreichweite beträgt 3 Blöcke/Meter in Pfeilrichtung.

[ta3_nodedetector](/image/)


### TA3 Spieler Detektor

Der Spieler Detektor sendet ein `on`-Kommando, wenn er einen Spieler in einem Umkreis von 4 m um den Block herum erkennt. Verlässt der Spieler wieder den Bereich, wird ein `off`-Kommando gesendet.
Soll die Suche auf bestimmte Spieler eingegrenzt werden, so können diese Spielernamen auch eingegeben werden.

[ta3_playerdetector](/image/)


## TA3 Maschinen

Bei TA3 existieren die gleichen Maschinen wie bei TA2, nur sind diese hier leistungsfähiger und benötigen Strom statt Achsenantrieb.
Im folgenden sind daher nur die unterschiedlichen, technischen Daten angegeben.

[ta3_grinder](/image/)


### TA3 Schieber

Die Funktion entspricht der von TA2.
Die Verarbeitungsleistung beträgt 6 Items alle 2 s.

[ta3_pusher](/image/)


### TA3 Verteiler

Die Funktion entspricht der von TA2.
Die Verarbeitungsleistung beträgt 12 Items alle 4 s.

[ta3_distributor](/image/)


### TA3 Autocrafter

Die Funktion entspricht der von TA2.
Die Verarbeitungsleistung beträgt 2 Items alle 4 s. Der Autocrafter benötigt hierfür 6 ku Strom.

[ta3_autocrafter](/image/)


### TA3 Elektronikfabrik

Die Funktion entspricht der von TA2, nur werden hier TA4 WLAN Chips produziert.
Die Verarbeitungsleistung beträgt ein Chip alle 6 s. Der Block benötigt hierfür 12 ku Strom.

[ta3_electronicfab](/image/)


### TA3 Trichter

Der TA3 Trichter sammelt abgelegte Gegenstände und speichert sie in seinem Inventar. Gegenstände werden angesaugt, wenn sie auf den Trichterblock fallen.
Der Scanradius beträgt 1 m.

[ta3_funnel](/image/)


### TA3 Kiessieb

Die Funktion entspricht der von TA2.
Die Verarbeitungsleistung beträgt 2 Items alle 4 s. Der Block benötigt 4 ku Strom.

[ta3_gravelsieve](/image/)


### TA3 Mühle

Die Funktion entspricht der von TA2.
Die Verarbeitungsleistung beträgt 2 Items alle 4 s. Der Block benötigt 6 ku Strom.

[ta3_grinder](/image/)


### TA3 Flüssigkeitensammler

Die Funktion entspricht der von TA2.
Die Verarbeitungsleistung ist 2 Items alle 8 s. Der Block benötigt 5 ku Strom.

[ta3_liquidsampler](/image/)



## Werkzeuge

### Techage Info Tool

Das Techage Info Tool (Schraubenschlüssel) hat verschiedene Funktionen. Er zeigt die Uhrzeit, die Position, die Temperatur und das Biome an, wenn auf einen unbekannten Block geklickt wird.
Wird auf einen TechAge Block mit Kommandoschnittstelle geklickt, werden alle verfügbaren Daten abgerufen (siehe auch "Logik-/Schalt-Blöcke").

[ta3_end_wrench](/image/)


### TechAge Programmer

Mit dem Programmer können Blocknummern mit einem Rechtsklick von mehreren Blöcken eingesammelt und mit einem Linksklick in einen Block wie Taster/Schalter geschrieben werden.
Wird in die Luft geklickt, wird der interne Speicher gelöscht.

[ta3_programmer](/image/)



### TechAge Kelle

Die Kelle dient zum Verputzen von Stromkabel. Siehe dazu "TA Stromkabel".

[ta3_trowel](/image/)

