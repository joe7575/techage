# TA2: Dampfzeitalter

In TA2 geht es darum, erste Maschinen  zur Verarbeitung von Erzen zu bauen und zu betreiben. Einige Maschinen müssen dazu über Antriebsachsen angetrieben werden. Dazu musst du eine Dampfmaschine bauen und diese mit Kohle oder Holzkohle anheizen.

In TA2 steht auch ein Kiesspüler zur Verfügung, mit dem seltene Erze wie Usmium Nuggets ausgewaschen werden können. Diese Nuggets wirst du später für weitere Rezepte brauchen.

## Dampfmaschine

Die Dampfmaschine besteht aus mehreren Blöcken und muss wie im Plan rechts abgebildet, zusammen gebaut werden. Dazu werden die Blöcke TA2 Feuerbox, TA2 Boiler oben, TA2 Boiler unten, TA2 Zylinder, TA2 Schwungrad und Dampfleitungen benötigt.

Zusätzlich werden Antriebsachsen sowie Getriebeblöcke für Richtungswechsel benötigt. Das Schwungrad muss über die Antriebsachsen mit allen Maschinen verbunden werden, die angetrieben werden müssen.

Bei allen Blöcken beim Setzen immer auch die Ausrichtung achten:

- Zylinder links, Schwungrad rechts daneben
- Dampfleitungen anschließen, wo ein entsprechendes Loch ist
- Antriebsachse beim Schwungrad nur rechts
- bei allen Maschinen kann die Antriebsachse an allen Seiten angeschlossen werden, welche nicht durch andere Funktionen belegt wird, wie bspw. die IN und OUT Löcher bei Mühle und Sieb.

Der Boiler muss mit Wasser gefüllt werden. Dazu bis zu 4 Eimer Wasser in den Boiler füllen.

Die Feuerbox muss mit Kohle oder Holzkohle gefüllt werden.

Wenn das Wasser heiß ist, kann das Ventil am Boiler geöffnet und anschließend die Dampfmaschine am Schwungrad gestartet werden.

Die Dampfmaschine leistet 25 ku, kann damit mehrere Maschinen gleichzeitig antreiben.

[steamengine](/plan/)

### TA2 Feuerbox

Teil der Dampfmaschine. 

Die Feuerbox muss mit Kohle oder Holzkohle gefüllt werden. Die Brenndauer ist abhängig von der Leistung, die von der Dampfmaschine angefordert wird. Unter Volllast brennt Kohle 32 s und Holzkohle 96 s.

[ta2_firebox](/image/)



### TA2 Boiler

Teil der Dampfmaschine. Muss mit Wasser gefüllt werden. Wem kein Wasser mehr vorhanden ist oder die Temperatur zu weit absinkt, schaltet sich der Boiler ab.

[ta2_boiler](/image/)



### TA2 Zylinder

Teil der Dampfmaschine.

[ta2_cylinder](/image/)



### TA2 Schwungrad

Antriebsteil der Dampfmaschine. Das Schwungrad muss über Antriebsachsen mit den Maschinen verbunden werden. 

[ta2_flywheel](/image/)



### TA2 Dampfleitungen

Teil der Dampfmaschine. Der Boiler muss mit dem Zylinder über die Dampfleitungen (steam pipes) verbunden werden. Die Dampfleitung besitzt keine Abzweigungen, die maximale Länge beträgt 12 m (Blöcke).

[ta2_steampipe](/image/)

## Items schieben und sortieren

Um Gegenstände (Items) von einer Verarbeitungsstation zur nächsten weiter zu transportieren, werden Schieber und Röhren verwendet. Siehe Plan.

[itemtransport](/plan/)

### Röhren

Zwei Maschinen können mit Hilfe eines Schiebers und einer Röhre (tube) verbunden werden. Röhren besitzen keine Abzweigungen. Die maximale Länge beträgt 200 m (Blöcke).

Röhren können alternativ mit Hilfe der Shift-Taste platziert werden. Dies erlaubt bspw. Röhren parallel zu verlegen, ohne dass diese sich unbeabsichtigt verbinden.

Die Transportkapazität einer Röhre ist unbegrenzt und nur durch die Schieber begrenzt.

[tube](/image/)

### TA2 Schieber

Ein Schieber ist in der Lage, Items aus Kisten oder Maschinen zu ziehen und in andere Kisten oder Maschinen zu schieben. Oder anders gesagt: Zwischen zwei Blöcken mit Inventar muss ein und genau ein Schieber sein. Mehrere Schieber in Reihe sind nicht möglich.

Ein Schieber geht in den Zustand "standby", wenn der keine Items zum Schieben hat. Ist der Ausgang blockiert oder das Inventory des Empfängers voll, so geht der Schieber in den Zustand "blocked". Aus beiden Zuständen kommt der Schieber nach einigen Sekunden selbsttätig wieder raus, sofern sich die Situation geändert hat.

Der Verarbeitungsleistung eines TA2 Schiebers beträgt 2 Items alle 2 s.

[ta2_pusher](/image/)

### TA2 Verteiler

Der Verteiler ist in der Lage, die Items aus seinem Inventar sortieren in bis zu vier Richtungen weiter zu transportieren. Dazu muss der Verteiler entsprechend konfiguriert werden. 

Der Verteiler besitzt dazu ein Menü mit 4 Filter mit unterschiedlichen Farben, entsprechend den 4 Ausgängen. Soll ein Ausgang genutzt werden, so muss der entsprechende Filter über die "on" Checkbox aktiviert werden. Alle Items, die für diesen Filter konfiguriert sind, werden über den zugeordneten Ausgang ausgegeben. Wird ein Filter aktiviert, ohne das Items konfiguriert werden, so sprechen wir hier von einem "nicht-konfigurierten", offenen Ausgang.

Für einen nicht-konfigurierten Ausgang gibt es zwei Betriebsarten:

1) Alle Items ausgeben, die an keine anderen Ausgängen ausgegeben werden können, auch wenn diese blockiert sind.

2) Nur die Items ausgeben, die für keinen anderen Filter konfiguriert wurden.

Im ersten Fall werden immer alle Items weitergeleitet und der Verteiler läuft nicht voll. Im zweiten Fall werden Items zurückgehalten und der Verteiler kann voll laufen und in der Folge blockieren.

Einstellbar ist die Betriebsart ist über die ">>|" Checkbox (an => Betriebsart 2)

Wird nur ein Ausgang aktiviert und mit mehreren Items konfiguriert, so kann die 1:1 Checkbox angeklickt werden. In diesem Falle werden Items streng gemäß der Filtereinstellung weitergegeben. Fehlt ein Item in der Reihenfolge, blockiert der Verteiler. Damit lassen sich andere Maschinen wie bspw. der Autocrafter exakt gemäß dem eingestellten Rezept bestücken.

Der Verarbeitungsleistung eines TA2 Verteilers beträgt 4 Items alle 2 s, wobei der Verteiler dabei versucht, die 4 Items auf die offenen Ausgänge zu verteilen.

[ta2_distributor](/image/)

## Kieswaschanlage

Die Kieswaschanlage ist eine komplexere Maschine mit dem Ziel, Usmium Nuggets aus gesiebtem Kies auszuwaschen. Für den Aufbau wird ein TA2 Kiesspüler mit Achsenantrieb, ein Trichter, eine Kiste, sowie fließendes Wasser benötigt. 

Aufbau von links nach rechts (siehe auch Plan):

* Ein Erdblock, darauf die Wasserquelle, umgeben auf 3 Seiten von bspw. Glasblöcken
* daneben den Kiesspüler, ggf. mit Röhrenanschlüssen für den Kies An- und Abtransport
* dann den Trichter mit Kiste 

Das Ganze umgeben von weiteren Glasblöcken, so dass das Wasser über den Kiesspüler und den Trichter fließt und ausgespielten Nuggets vom Trichter wieder eingesammelt werden können.

[gravelrinser](/plan/)

### TA2 Kiesspüler

Der Kiesspüler ist in der Lade, aus bereits gesiebtem Kies die Erze  Usmium und Kupfer  auszuspülen, sofern dieser von Wasser überspült wird.

Ob der Kiesspüler korrekt arbeitet, kann mit Hilfe von Stöcken (sticks) getestet werden, wenn diese in das Inventar des Kiesspülers getan werden. Diese müssen einzeln ausgespült und vom Trichter eingefangen werden.

Die Verarbeitungsleistung ist ein Kies Item alle 2 s. Der Kiesspüler benötigt 3 ku Energie.

[ta2_rinser](/image/)

## Stein mahlen und sieben

Das Mahlen und Siebe von Gestein dient zur Gewinnung von Erzen. Gesiebtes Kies kann aber auch anderweitig genutzt werden. Mühle und Sieb müssen angetrieben und damit in der Nähe einer Dampfmaschine aufgebaut werden.

[ta2_grinder](/image/)

### TA2 Mühle

Die Mühle ist in der Lage, verschiedenes Gestein, aber auch Holz und andere Items zu mahlen.

Die Verarbeitungsleistung ist ein Item alle 2 s. Die Mühle benötigt 4 ku Energie.

[ta2_grinder](/image/)

### TA2 Kiessieb

Das Kiessieb ist in der Lage, Kies zu sieben um Erze zu gewinnen. Als Ergebnis erhält man teilweise "gesiebtes Kies", was nicht wieder gesiebt werden kann.

Die Verarbeitungsleistung ist ein Item alle 2 s. Die Kiessieb benötigt 3 ku Energie.

[ta2_gravelsieve](/image/)

## Items produzieren

Mit TA2 Maschinen können nicht nur Erze gewonnen, sondern auch Gegenstände hergestellt werden.

### TA2 Autocrafter

Der Autocrafter dient  zur automatischen Herstellung von Waren. Alles was der Spieler über das "Crafting Grid" herstellen kann, kann auch durch den Autocrafter erledigt werden. Dazu müssen im Menü des Autocrafters das Rezept eingegeben und die notwendigen Zutaten hinzugefügt werden.

Zutaten und hergestellte Waren können über Rühren und Schieber in und aus dem Block transportiert werden.

Die Verarbeitungsleistung ist ein Item alle 4 s. Der Autocrafter benötigt 4 ku Energie.

[ta2_autocrafter](/image/)

### TA2 Elektronikfabrik

Die Elektronikfabrik ist eine Spezialmaschine und nur für die Herstellung der Vakuumröhren nutzbar. Vakuumröhren werden für TA3 Maschinen und Blöcke benötigt.

Die Verarbeitungsleistung ist eine Vakuumröhre alle 6 s. Die Elektronikfabrik benötigt 8 ku Energie.

[ta2_electronicfab](/image/)

## Sonstige Blöcke 

### TA2 Flüssigkeitensammler

Für manche Rezepte wird Wasser benötigt. Damit auch diese Rezepte automatisiert mit dem Autocrafter bearbeitet werden können, muss Wasser in Eimern bereitgestellt werden. Hierzu dient der Flüssigkeitensammler. Er benötigt leere Eimer und muss ins Wasser gestellt werden.

Die Verarbeitungsleistung ist ein Wassereimer alle 8 s. Der Flüssigkeitensammler benötigt 3 ku Energie.

[ta2_liquidsampler](/image/)