return {
  titles = {
    "1,Tech Age Mod",
    "2,Hinweise",
    "2,Änderungen ab Version 1.0",
    "3,Tipps zur Umstellung",
    "2,Erze und Mineralien",
    "3,Meridium",
    "3,Usmium",
    "3,Baborium",
    "3,Erdöl",
    "3,Bauxit",
    "3,Basalt",
  },
  texts = {
    "Tech Age ist eine Technik-Mod mit 5 Entwicklungsstufen:\n"..
    "\n"..
    "TA1: Eisenzeitalter (Iron Age)\n"..
    "Benutze Werkzeuge und Hilfsmittel wie Köhler\\, Kohlebrenner\\, Kiessieb\\, Hammer und Hopper\\, um notwendige Erze und Metalle zu schürfen und zu verarbeiten.\n"..
    "\n"..
    "TA2: Dampfzeitalter (Steam Age)\n"..
    "Baue eine Dampfmaschine mit Antriebsachsen und betreibe damit deine ersten Maschinen zur Verarbeitung von Erzen.\n"..
    "\n"..
    "TA3: Ölzeitalter (Oil Age)\n"..
    "Suche und fördere Öl\\, baue Schienenwege zur Ölbeförderung. Ein Kraftwerk liefert den notwendigen Strom für deine Maschinen. Elektrisches Licht erhellt deine Industrieanlagen.\n"..
    "\n"..
    "TA4: Gegenwart (Present)\n"..
    "Regenerative Energiequellen wie Wind\\, Sonne und Biokraft helfen dir\\, das Ölzeitalter zu verlassen. Mit modernen Technologien und intelligenten Maschinen machst du dich auf in die Zukunft.\n"..
    "\n"..
    "TA5: Zukunft (Future)\n"..
    "Maschinen zur Überwindung von Raum und Zeit\\, neue Energiequellen und andere Errungenschaften prägen dein Leben.\n"..
    "\n"..
    "Hinweis: Mit Klicken auf die Pluszeichen kommst du in die Unterkapitel dieser Anleitung.\n"..
    "\n"..
    "\n"..
    "\n",
    "Diese Dokumentation ist sowohl \"ingame\" (Block Konstruktionsplan) als auch auf GitHub als MD-Files verfügbar.\n"..
    "\n"..
    "  - Link: https://github.com/joe7575/techage/wiki\n"..
    "\n"..
    "Die Konstruktionspläne (Diagramme) für den Aufbau der Maschinen sowie die Bilder sind aber nur ingame verfügbar.\n"..
    "\n"..
    "Bei Tech Age musst du von vorne beginnen. Nur mit den Items aus TA1 kannst du TA2 Blöcke herstellen\\, für TA3 benötigst du die Ergebnisse aus TA2\\, usw.\n"..
    "\n"..
    "In TA2 laufen die Maschinen nur mit Antriebsachsen.\n"..
    "\n"..
    "Ab TA3 laufen die Maschinen mit Strom und besitzen eine Kommunikationsschnittstelle zur Fernsteuerung.\n"..
    "\n"..
    "Mit TA4 kommen weitere Stromquellen dazu\\, aber auch höhere logistische Herausforderungen (Stromtrassen\\, Item Transport).\n"..
    "\n",
    "Ab V1.0 (17.07.2021) hat sich folgendes geändert:\n"..
    "\n"..
    "  - Der Algorithmus zur Berechnung der Stromverteilung hat sich geändert. Energiespeichersysteme werden dadurch wichtiger. Diese gleichen Schankungen aus\\, was bei größeren Netzen mit mehreren Generatoren wichtig wird.\n"..
    "  - Aus diesem Grund hat TA2 seinen eigenen Energiespeicher erhalten.\n"..
    "  - Die Akkublöcke aus TA3 dienen auch als Energiespeicher. Ihre Funktionsweise wurde entsprechend angepasst.\n"..
    "  - Das TA4 Speichersystem wurde überarbeitet. Die Wärmetauscher (heatexchanger) haben eine neue Nummer bekommen\\,  da die Funktionalität vom unteren in den mittleren Block verschoben  wurde. Sofern diese ferngesteuert wurden\\, muss die Knotennummer angepasst  werden. Die Generatoren haben kein eigenes Menü mehr\\, sondern werden nur noch über den Wärmetauscher ein-/ausgeschaltet.  Wärmetauscher und Generator müssen jetzt am gleichen Netz hängen!\n"..
    "  - Mehrere Stromnetze können jetzt über einen TA4 Transformator Blöcke gekoppelt werden.\n"..
    "  - Neu ist auch ein TA4 Stromzähler Block für Unternetze.\n"..
    "\n",
    "Viele weitere Blöcke haben kleinere Änderungen bekommen. Daher kann es sein\\, dass Maschinen oder Anlagen nach der Umstellung  nicht gleich wieder anlaufen. Sollte es zu Störungen kommen\\, helfen folgende Tipps:\n"..
    "\n"..
    "  - Maschinen aus- und wieder eingeschalten\n"..
    "  - ein Stromkabel-Block entfernen und wieder setzen\n"..
    "  - den Block ganz entfernen und wieder setzen\n"..
    "  - mindestens ein Akkublock oder Speichersystem in jedes Netzwerk\n"..
    "\n",
    "Techage fügt dem Spiel einige neue Items hinzu:\n"..
    "\n"..
    "  - Meridium - eine Legierung zur Herstellung von leuchtenden Werkzeugen in TA1\n"..
    "  - Usmium - ein Erz\\, was in TA2 gefördert und für TA3 benötigt wird\n"..
    "  - Baborium - ein Metall\\, welches für Rezepte in TA3 benötigt wird\n"..
    "  - Erdöl - wird in TA3 benötigt\n"..
    "  - Bauxit - ein Aluminiumerz\\, was in TA4 zur Herstellung von Aluminium benötigt wird\n"..
    "  - Basalt - entsteht\\, wenn sich Wasser und Lave berühren\n"..
    "\n",
    "Meridium ist eine Legierung aus Stahl und Mesekristallen. Meridium Ingots können mit dem Kohlebrenner aus Stahl und Mesesplitter hergestellt werden. Meridium leuchtet im Dunkeln. Auch Werkzeuge aus Meridium leuchten und sind daher im Untertagebau sehr hilfreich.\n"..
    "\n"..
    "\n"..
    "\n",
    "Usmium kommt nur als Nuggets vor und kann nur beim Waschen von Kies mit der TA2/TA3 Kieswaschanlage gewonnen werden.\n"..
    "\n"..
    "\n"..
    "\n",
    "Barborium kann nur im Untertagebau gewonnen werden. Diesen Stoff findet man nur in einer Tiefe von -250 bis -340 Metern.\n"..
    "Baborium kann nur im TA3 Industrieofen geschmolzen werden.\n"..
    "\n"..
    "\n"..
    "\n",
    "Erdöl kann nur mithilfe des Explorers gefunden und mithilfe entsprechender TA3 Maschinen gefördert werden. Siehe TA3.\n"..
    "\n"..
    "\n"..
    "\n",
    "Bauxit wird nur im Untertagebau gewonnen. Bauxit findet man nur in Stein in einer Höhe zwischen -50 und -500 Metern.\n"..
    "Es wird zur Herstellung von Aluminium benötigt\\, was vor allem in TA4 Verwendung findet.\n"..
    "\n"..
    "\n"..
    "\n",
    "Basalt entsteht nur\\, wenn Lava und Wasser zusammen kommen.\n"..
    "Dazu sollte man am besten eine Anlage aufbauen\\, bei der eine Lava- und eine Wasserquelle zusammenfließen.\n"..
    "Dort wo sich beide Flüssigkeiten treffen\\, entsteht Basalt.\n"..
    "Einen automatisierten Basalt Generator kann man mit dem Sign Bot aufbauen.\n"..
    "\n"..
    "\n"..
    "\n",
  },
  images = {
    "techage_ta4",
    "",
    "",
    "",
    "",
    "meridium",
    "usmium",
    "baborium",
    "oil",
    "bauxite",
    "basalt",
  },
  plans = {
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
  }
}