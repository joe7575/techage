# TA5: Zukunft

Maschinen zur Überwindung von Raum und Zeit, neue Energiequellen und andere Errungenschaften prägen dein Leben. 

Für die Herstellung und Nutzung von TA5 Maschinen und Blöcken sind Erfahrungspunkte (experience points) notwendig. Diese können nur über den Teilchenbeschleuniger aus TA4 erarbeitet werden.

[techage_ta5|image]

## Energiequellen

### TA5 Fusionsreaktor

Kernfusion bedeutet das Verschmelzen zweier Atomkerne. Dabei können, je nach Reaktion, große Mengen von Energie freigesetzt werden. Kernfusionen, bei denen Energie frei wird, laufen in Form von Kettenreaktionen ab. Sie sind die Quelle der Energie der Sterne, zum Beispiel auch unserer Sonne. Ein Fusionsreaktor wandelt die Energie, die bei einer kontrollierten Kernfusion frei wird, in elektrischen Strom um.

**Wie funktioniert ein Fusionsreaktor?**

Ein Fusionsreaktor funktioniert nach dem klassischen Prinzip eines Wärmekraftwerks: Wasser wird erhitzt und treibt eine Dampfturbine an, deren Bewegungsenergie von einem Generator in Strom gewandelt wird.

Ein Fusionskraftwerk benötigt zunächst eine hohe Menge an Energie, da ein Plasma erzeugt werden muss. „Plasma“ nennt man den vierten Zustand von Stoffen, nach fest, flüssig und gasförmig. Dafür wird viel Strom benötigt. Erst durch diese extreme Energiekonzentration zündet die Fusionsreaktion und mit der abgegebenen Wärme wird über den Wärmetauscher Strom erzeugt. Der Generator liefert dann 800 ku an Strom.

Der Plan rechts zeigt einen Schnitt durch den Fusionsreaktor.

Für den Betrieb des Fusionsreaktors werden 60 Erfahrungspunkte benötigt. Der Fusionsreaktor muss komplett in einem Forceload Block Bereich aufgebaut werden.

[ta5_fusion_reactor|plan]

#### TA5 Fusionreaktor Magnet

Für den Aufbau des Fusionsreaktors werden insgesamt 60 TA5 Fusionreaktor Magnete benötigt. Diese bilden den Ring, in dem sich das Plasma bildet. Der TA5 Fusionsreaktor Magnete benötigt Strom und hat zwei Anschlüsse für die Kühlung.

Es gibt zwei Typen von Magneten, so dass auch alle Seiten der Magnete, die zum Plasmaring zeigen, mit einem Hitzeschild geschützt werden können.

Bei den Eckmagneten auf der Innenseite des Rings ist jeweils eine Anschlussseite verdeckt (Strom oder Kühlung) und kann daher nicht angeschlossen werden. Dies ist technisch nicht machbar und hat daher keinen Einfluß auf die Funktion des Fusionsreaktor. 

[ta5_magnet|image]

#### TA5 Pumpe

Die Pumpe wird benötigt, um den Kühlkreislauf mit Isobutan zu füllen. Es werden ca. 350 Einheiten Isobutan benötigt.

Hinweis: Die TA5 Pumpe kann nur zum Füllen des Kühlkreislaufs genutzt werden, ein Abpumpen des Kühlmittels ist nicht möglich. Daher sollte die Pumpe erst eingeschaltet werden, wenn die Magnete korrekt platziert und alle Strom- und Kühlleitungen angeschlossen sind.

[ta5_pump|image]

#### TA5 Wärmetauscher

Der TA5 Wärmetauscher wird benötigt, um die im Fusionsreaktor erzeugte Hitze zuerst in Dampf und dann in Strom umzuwandeln. Der Wärmetauscher selbst benötigt dazu 5 ku Strom. Der Aufbau gleicht dem Wärmetauscher des Energiespeichers aus TA4.

Hinweis: Der TA5 Wärmetauscher hat zwei Anschlüsse (blau und grün) für den Kühlkreislauf. Über die grünen und blauen Röhren müssen der Wärmetauscher und alle Magnete zu einem Kühlkreislauf verbunden werden.

Über den Start-Button des Wärmetauschers kann der Kühlkreislauf auf Vollständigkeit geprüft werden, auch wenn noch kein Kühlmittel eingefüllt wurde.

[ta5_heatexchanger|plan]

#### TA5 Fusionreaktor Controller

Über den TA5 Fusionreaktor Controller wird der Fusionreaktor eingeschaltet. Dabei muss zuerst die Kühlung/Wärmetauscher und dann der Controller eingeschaltet werden. Es dauert ca. 2 min, bis der Reaktor in Gang kommt und Strom liefert. Der Fusionreaktor und damit der Controller benötigt 400 ku an Strom, um das Plasma aufrecht zu erhalten.

[ta5_fr_controller|image]

#### TA5 Fusionreaktor Hülle

Der komplette Reaktor muss mit einer Hülle umgeben werden, die den enormen Druck, den die Magnete auf das Plasma ausüben, abfängt und die Umgebung vor Strahlung schützt. Ohne diese Hülle kann der Reaktor nicht gestartet werden. Mit der TechAge Kelle können auch Stromkabel und Kühlleitungen des Fusionreaktors in die Hülle integriert werden.

[ta5_fr_shell|image]

#### TA5 Fusionreaktor Kern

Der Kern muss in der Mitte des Reaktors sitzen. Siehe Abbildung unter "TA5 Fusionsreaktor". Auch hierfür wird die TechAge Kelle benötigt.

[ta5_fr_nucleus|image]

## Energiespeicher

### TA5 Hybrid-Speicher (geplant)

## Logik Blöcke

## Transport und Verkehr

### TA5 Flug Controller

Der TA5 Flug Controller ist ähnlich zum TA4 Move Controller. Im Gegensatz zum TA4 Move Controller können hier mehrere Bewegungen zu einer Flugstrecke kombiniert werden. Diese Flugstrecke kann im Eingabefeld über mehrere x,y,z Angaben definiert werden (eine Bewegung pro Zeile). Über "Speichern" wird die Flugstrecke geprüft und gespeichert. Bei einem Fehler wird eine Fehlermeldung ausgegeben.

Mit der Taste "Test" wird die Flugstrecke mit den absoluten Koordinaten zur Überprüfung im Chat ausgegeben.

Die maximale Distanz für die gesammte Flugstrecke beträgt 1500 m. Es können bis zu 32 Blöcke antrainiert werden.

Die Nutzung des TA5 Flug Controllers benötigt 40 Erfahrungspunkte.

**Teleport Mode**

Wird der `Teleport Mode` aktiviert (auf `enable` gesetzt), kann ein Spieler auch ohne Blöcke bewegt werden. Dazu muss die Startposition über die Taste "Aufzeichnen" konfiguriert werden. Es kann hier nur eine Position konfiguriert werden. Das Spieler, der bewegt werden soll, muss dazu auf dieser Position stehen. 

[ta5_flycontroller|image]

### TA5 Hyperloop Kiste / TA5 Hyperloop Chest

Die TA5 Hyperloop Kiste erlaubt den Transport von Gegenständen über ein Hyperloop Netzwerk.

Die TA5 Hyperloop Kiste muss man dazu auf eine Hyperloop Junction stellen. Die Kiste besitzt ein spezielles Menü, mit dem man das Pairing von zwei Kisten durchführen kann. Dinge, die in der Kiste sind, werden zur Gegenstelle teleportiert. Die Kiste kann auch mit einem  Schieber gefüllt/geleert werden.

Für das Pairing musst du zuerst auf der einen Seite einen Namen für die Kiste eingeben, dann kannst du bei der anderen Kiste diesen Namen auswählen und so die beiden Blöcke verbinden.

Die Nutzung der TA5 Hyperloop Kiste benötigt 15 Erfahrungspunkte.

[ta5_chest|image]

### TA5 Hyperloop Tank / TA5 Hyperloop Tank

Der TA5 Hyperloop Tank erlaubt den Transport von Flüssigkeiten über ein Hyperloop Netzwerk.

Den TA5 Hyperloop Tank muss man dazu auf eine Hyperloop Junction stellen. Der Tank besitzt ein spezielles Menü, mit dem man das Pairing von zwei Tanks durchführen kann. Flüssigkeiten, die in dem Tank sind, werden zur Gegenstelle teleportiert. Der Tank kann auch mit einer Pumpe  gefüllt/geleert werden.

Für das Pairing musst du zuerst auf der einen Seite einen Namen für den Tank eingeben, dann kannst du bei dem anderen Tank diesen Namen auswählen und so die beiden Blöcke verbinden.

Die Nutzung des TA5 Hyperloop Tanks benötigt 15 Erfahrungspunkte.

[ta5_tank|image]

### TA5-Raumgleiter (geplant)

Dank einem Spezialantrieb für Lichtgeschwindigkeit können mit dem Raumgleiter auch große Entfernungen sehr schnell überwunden werden.

## Teleport Blöcke

Mit Teleport-Blöcken können Dinge zwischen zwei Teleport-Blöcken übertragen werden, ohne dass sich dazwischen eine Röhre oder Leitung befinden muss. Für das Pairing der Blöcke musst du zuerst auf der einen Seite einen Namen für den Block eingeben, dann kannst du bei dem anderen Block diesen Namen auswählen und so die beiden Blöcke verbinden. Das Pairung kann nur von einem Spieler durchgeführt werden (Spielername wird geprüft) und muss vor einem Server-Neustart abgeschlossen sein. Anderenfalls gehen die Pairing-Daten verloren.

Der Plan rechts zeigt, wie die Blöcke genutzt werden können.

[ta5_teleport|plan]

### TA5 Teleport Block Gegenstände / TA5 Teleport Block Items

Diese Teleport-Blöcke erlauben die Übertragung von Gegenständen und ersetzen somit eine Röhre. Dabei können Entfernungen von bis zu 500 Blöcken überbrückt werden.

Ein Teleport-Block benötigt 12 ku Strom.

Für die Nutzung der Teleport-Blöcke werden 30 Erfahrungspunkte benötigt.

[ta5_tele_tube|image]

### TA5 Teleport Block Flüssigkeiten / TA5 Teleport Block Liquids

Diese Teleport-Blöcke erlauben die Übertragung von Flüssigkeiten und ersetzen somit eine gelbe Leitung. Dabei können Entfernungen von bis zu 500 Blöcken überbrückt werden.

Ein Teleport-Block benötigt 12 ku Strom.

Für die Nutzung der Teleport-Blöcke werden 30 Erfahrungspunkte benötigt.

[ta5_tele_pipe|image]

### Hyperloop Teleport Blöcke (geplant)

Die Hyperloop Teleport Blöcke erlauben den Aufbau von Hyperloop Netzwerk ohne Hyperloop-Röhren.

Die Nutzung der Hyperloop Teleport Blöcke benötigt 60 Erfahrungspunkte.

## Weitere TA5 Blöcke/Items

### TA5 Container (geplant)

Der TA5 Container erlaubt Techage Anlagen ein- und an einer anderen Stelle wieder auszupacken.

Für die Nutzung des TA5 Containers werden 80 Erfahrungspunkte benötigt.

### TA5 KI Chip / TA5 AI Chip

Der TA5 KI Chip wird teilweise zur Herstellung von TA5 Blöcken benötigt. Der TA5 KI Chip kann nur auf der TA4 Elektronik Fab hergestellt werden. Dazu werden 10 Erfahrungspunkte benötigt.

[ta5_aichip|image]

### TA5 KI Chip II / TA5 AI Chip II

Der TA5 KI Chip II wird zur Herstellung des TA5 Fusionsreaktors benötigt. Der TA5 KI Chip II kann nur auf der TA4 Elektronik Fab hergestellt werden. Dazu werden 25 Erfahrungspunkte benötigt.

[ta5_aichip2|image]
