# TA4 : Présent

Les sources d'énergie renouvelables comme le vent, le soleil et les biocarburants vous aident à quitter l'âge du pétrole. Avec des technologies modernes et des machines intelligentes, vous vous lancez dans l'avenir.

[techage_ta4|image]

## Éolienne

Une éolienne fournit de l'électricité lorsqu'il y a du vent. Dans le jeu, il n'y a pas de vent, mais le mod simule cela en faisant tourner les éoliennes uniquement le matin (5:00 - 9:00) et le soir (17:00 - 21:00). Une éolienne ne fournit de l'électricité que si elle est installée à un endroit approprié.

Les éoliennes TA sont des installations purement offshore, ce qui signifie qu'elles doivent être construites en mer. Cela signifie que les éoliennes ne peuvent être construites que dans un biome de mer (océan) et qu'il doit y avoir suffisamment d'eau et une vue dégagée autour du mât.

Pour trouver un endroit approprié, vous devez cliquer sur l'eau avec la clé à molette (outil d'information TechAge). Si cet endroit est adapté pour le mât de l'éolienne, cela vous sera indiqué par un message de chat.

L'électricité doit être conduite du bloc du rotor vers le bas à travers le mât. Pour cela, tirez d'abord le câble électrique vers le haut et "enduisez" le câble électrique avec des blocs de colonnes TA4. En bas, une plateforme de travail peut être construite. Le plan de droite montre la structure dans la partie supérieure.

L'éolienne fournit une puissance de 70 ku, mais seulement pendant 8 heures par jour (voir ci-dessus).

[ta4_windturbine|plan]

### TA4 Éolienne / Wind Turbine

Le bloc de l'éolienne (rotor) est le cœur de l'éolienne. Ce bloc doit être placé en haut du mât. Idéalement à Y = 15, afin de rester juste à l'intérieur d'un bloc de carte/Forceload.
Lors du démarrage de l'éolienne, toutes les conditions de fonctionnement de l'éolienne sont vérifiées. Si toutes les conditions sont remplies, les pales du rotor (ailes) apparaissent également automatiquement. Sinon, un message d'erreur est affiché.

[ta4_windturbine|image]

### TA4 Nacelle d'éolienne / Wind Turbine Nacelle

Ce bloc doit être placé à l'extrémité noire du bloc de la turbine éolienne.

[ta4_nacelle|image]

### TA4 Signal Lamp d'éolienne / Wind Turbine Signal Lamp

Cette lumière clignotante est uniquement à des fins décoratives et peut être placée en haut du bloc de la turbine éolienne.

[ta4_blinklamp|image]

### TA4 Colonne / Pillar

Cela permet de construire le mât pour l'éolienne. Cependant, ces blocs ne sont pas placés à la main mais doivent être placés à l'aide de la truelle, de sorte que le câble électrique soit remplacé par ces blocs (voir sous TA Stromkabel).

[ta4_pillar|image]

## Installation solaire

L'installation solaire ne produit de l'électricité que lorsque le soleil brille. Dans le jeu, c'est chaque jour de jeu du matin 6:00 au soir 18:00.
Pendant cette période, la même puissance est toujours disponible. Après 18:00, les modules solaires s'éteignent complètement.

Pour la puissance des modules solaires, la température du biome est décisive. Plus la température est élevée, plus le rendement est élevé.
La température du biome peut être déterminée avec l'outil d'information TechAge (clé à molette). Elle varie typiquement entre 0 et 100 :

- à 100, la pleine puissance est disponible
- à 50, la moitié de la puissance est disponible
- à 0, aucune puissance n'est disponible

Il est donc recommandé de rechercher des steppes et des déserts chauds pour l'installation solaire.
Pour le transport de l'électricité, les lignes aériennes sont disponibles.
Cependant, de l'hydrogène peut également être produit, qui peut être transporté et à nouveau converti en électricité à destination.

La plus petite unité d'une installation solaire est composée de deux modules solaires et d'un module porteur. Le module porteur doit d'abord être placé, puis les deux modules solaires à gauche et à droite (pas au-dessus !).

Le plan de droite montre 3 unités avec chacune deux modules solaires et un module porteur, connectés par des câbles rouges à l'onduleur.

Les modules solaires fournissent du courant continu, qui ne peut pas être directement injecté dans le réseau électrique. Par conséquent, les unités solaires doivent d'abord être connectées à l'onduleur via le câble rouge. Celui-ci se compose de deux blocs, un pour le câble rouge vers les modules solaires (DC) et un pour le câble électrique gris vers le réseau électrique (AC).

La zone de la carte où se trouve l'installation solaire doit être complètement chargée. Cela s'applique également à la position directe au-dessus du module solaire, car la luminosité y est mesurée régulièrement. Il est donc recommandé de placer d'abord un bloc Forceload, puis de placer les modules à l'intérieur de cette zone.

[ta4_solarplant|plan]

### TA4 Module solaire / Solar Module

Le module solaire doit être placé sur le module porteur. Deux modules solaires sont toujours nécessaires.
En paire, les modules solaires fournissent jusqu'à 3 ku, selon la température.
Pour le module solaire, il faut veiller à ce qu'il ait la pleine lumière du jour et ne soit pas ombragé par des blocs ou des arbres. Cela peut être testé avec l'outil d'information (clé à molette).

[ta4_solarmodule|image]

### TA4 Module porteur solaire / Carrier Module

Le module porteur existe en deux hauteurs de construction (1m et 2m). Fonctionnellement, les deux sont identiques.
Les modules porteurs peuvent être placés directement les uns à côté des autres et ainsi connectés en une rangée de modules. La connexion à l'onduleur ou à d'autres rangées de modules doit être établie avec les câbles basse tension rouges ou les boîtes de distribution basse tension.

[ta4_solarcarrier|image]

### TA4 Onduleur solaire / Solar Inverter

L'onduleur convertit le courant solaire (DC) en courant alternatif (AC), de sorte qu'il peut être injecté dans le réseau électrique.
Un onduleur peut injecter un maximum de 100 ku de courant, ce qui correspond à 33 modules solaires ou plus.

[ta4_solar_inverter|image]

### TA4 Câble basse tension / Low Power Cable

Le câble basse tension sert à connecter les rangées de modules solaires à l'onduleur. Le câble ne doit pas être utilisé à d'autres fins.

La longueur maximale de la ligne est de 200 m.

[ta4_powercable|image]

### TA4 Boîte de distribution basse tension / Low Power Box

La boîte de distribution doit être placée sur le sol. Elle ne possède que 4 connexions (dans les 4 directions cardinales).

[ta4_powerbox|image]

### TA4 Cellule solaire de lampadaire / Streetlamp Solar Cell

La cellule solaire de lampadaire sert, comme son nom l'indique, à alimenter en électricité un lampadaire. Une cellule solaire peut alimenter deux lampes. La cellule solaire stocke l'énergie solaire pendant la journée et fournit l'électricité la nuit aux lampes. Cela signifie que la lampe ne s'allume que dans l'obscurité.

Cette cellule solaire ne peut pas être combinée avec les autres modules solaires.

[ta4_minicell|image]

## Stockage d'énergie

Le stockage d'énergie TA4 remplace le bloc de batterie de TA3.

Le stockage d'énergie se compose d'une coque en béton (Concrete Block) remplie de gravier. Il existe 5 tailles de stockage :

- Coque de 5x5x5 Concrete Blocks, remplie de 27 Gravel, capacité de stockage : 22,5 kud
- Coque de 7x7x7 Concrete Blocks, remplie de 125 Gravel, capacité de stockage : 104 kud
- Coque de 9x9x9 Concrete Blocks, remplie de 343 Gravel, capacité de stockage : 286 kud
- Coque de 11x11x11 Concrete Blocks, remplie de 729 Gravel, capacité de stockage : 610 kud
- Coque de 13x13x13 Concrete Blocks, remplie de 1331 Gravel, capacité de stockage : 1112 kud

Dans la coque en béton, il peut y avoir une fenêtre en bloc de verre d'obsidienne. Celle-ci doit être placée assez au centre du mur. À travers cette fenêtre, on peut voir si le stockage est chargé à plus de 80 %. Dans le plan de droite, on voit la structure composée de 3 blocs TA4 Échangeur de chaleur, de la turbine TA4 et du générateur TA4. Pour l'échangeur de chaleur, il faut faire attention à l'orientation (la flèche du bloc 1 doit pointer vers la turbine).

Contrairement au plan de droite, les connexions sur le bloc de stockage doivent être au même niveau (disposées horizontalement, donc pas en bas et en haut). Les arrivées de tuyaux (TA4 Pipe Inlet) doivent être exactement au centre du mur et se font donc face. Les tuyaux jaunes TA4 sont utilisés comme tuyaux. Les tuyaux de vapeur TA3 ne peuvent pas être utilisés ici.
Le générateur ainsi que l'échangeur de chaleur ont une connexion électrique et doivent être connectés au réseau électrique.

En principe, le système de stockage de chaleur fonctionne exactement comme les batteries, mais avec une capacité de stockage beaucoup plus grande.

Pour que le système de stockage de chaleur fonctionne, tous les blocs (y compris la coque en béton et le gravier) doivent être chargés à l'aide d'un bloc Forceload.

[ta4_storagesystem|plan]

### TA4 Échangeur de chaleur / Heat Exchanger

L'échangeur de chaleur se compose de 3 parties qui doivent être placées les unes sur les autres, la flèche du premier bloc devant pointer vers la turbine. Les conduites doivent être construites avec les tuyaux jaunes TA4.
L'échangeur de chaleur doit être connecté au réseau électrique. Via l'échangeur de chaleur, le stockage d'énergie est à nouveau chargé, à condition qu'il y ait suffisamment d'électricité disponible.

[ta4_heatexchanger|image]

### TA4 Turbine

La turbine fait partie du stockage d'énergie. Elle doit être placée à côté du générateur et connectée à l'échangeur de chaleur via des tuyaux TA4, comme illustré dans le plan.

[ta4_turbine|image]

### TA4 Générateur

Le générateur fait partie du stockage d'énergie. Il sert à produire de l'électricité et restitue ainsi l'énergie du stockage d'énergie. Par conséquent, le générateur doit également être connecté au réseau électrique.

Important : L'échangeur de chaleur et le générateur doivent être connectés au même réseau électrique !

[ta4_generator|image]

### TA4 Entrée de tuyau / TA4 Pipe Inlet

Un bloc d'entrée de tuyau doit être installé des deux côtés du bloc de stockage. Les blocs doivent se faire face exactement.

Les blocs d'entrée de tuyau ne peuvent pas être utilisés comme des passages de mur normaux, pour cela, utilisez les blocs TA3 Rohr/Wanddurchbruch / TA3 Pipe Wall Entry.

[ta4_pipeinlet|image]

### TA4 Tuyau / Pipe

Les tuyaux jaunes servent à TA4 pour la transmission de gaz et de liquides.
La longueur maximale de la conduite est de 100 m.

[ta4_pipe|image]

## Distribution d'électricité

Avec l'aide de câbles électriques et de boîtes de distribution, des réseaux électriques de jusqu'à 1000 blocs/nœuds peuvent être construits. Cependant, il faut noter que les boîtes de distribution doivent également être comptées. Ainsi, jusqu'à 500 générateurs/systèmes de stockage/machines/lampes peuvent être connectés à un réseau électrique.

Avec l'aide d'un transformateur d'isolement et d'un compteur électrique, des réseaux peuvent être connectés pour former des structures encore plus grandes.

[ta4_transformer|image]

### TA4 Transformateur d'isolement / TA4 Isolation Transformer

Avec l'aide d'un transformateur d'isolement, deux réseaux électriques peuvent être connectés pour former un réseau plus grand. Le transformateur d'isolement peut transmettre l'électricité dans les deux directions.

Le transformateur d'isolement peut transmettre jusqu'à 300 ku. La valeur maximale peut être réglée via le menu de la clé à molette.

[ta4_transformer|image]

### TA4 Compteur électrique / TA4 Electric Meter

Avec l'aide d'un compteur électrique, deux réseaux électriques peuvent être connectés pour former un réseau plus grand. Le compteur électrique ne transmet l'électricité que dans une direction (faire attention à la flèche). La quantité d'énergie électrique transmise (en kud) est mesurée et affichée. Cette valeur peut également être interrogée via la commande `consumption` par un contrôleur Lua. Le courant électrique actuel peut être interrogé via `current`.

Le compteur électrique peut transmettre jusqu'à 200 ku. La valeur maximale peut être réglée via le menu de la clé à molette.

Via le menu de la clé à molette, un compte à rebours pour la fourniture de puissance peut également être saisi. Lorsque ce compte à rebours atteint zéro, le compteur électrique s'éteint. Le compte à rebours peut être interrogé via la commande `countdown`.

[ta4_electricmeter|image]

### TA4 Laser

Le laser TA4 sert à la transmission d'électricité sans fil. Pour cela, deux blocs sont nécessaires : l'émetteur de faisceau laser TA4 et le récepteur de faisceau laser TA4. Entre les deux blocs, il doit y avoir un espace d'air, de sorte que le faisceau laser puisse être établi de l'émetteur au récepteur.

D'abord, l'émetteur doit être placé. Celui-ci active immédiatement le faisceau laser et indique ainsi les positions possibles du récepteur. Les positions possibles pour le récepteur sont également affichées via un message de chat. Avec le laser, des distances jusqu'à 96 blocs peuvent être franchies.

Si la connexion est établie (il n'est pas encore nécessaire que le courant circule), cela est indiqué via le texte d'information de l'émetteur et également du récepteur.

Les blocs laser eux-mêmes n'ont pas besoin d'électricité.

[ta4_laser|image]

## Hydrogène

L'eau peut être divisée en hydrogène et en oxygène par électrolyse en utilisant l'électricité. D'un autre côté, l'hydrogène peut être à nouveau converti en électricité avec de l'oxygène de l'air via une pile à combustible.
Ainsi, les pics de courant ou un excès d'électricité peuvent être convertis en hydrogène et ainsi stockés.

Dans le jeu, l'électricité peut être convertie en hydrogène avec l'aide de l'électrolyseur et de l'eau. L'hydrogène peut ensuite être à nouveau converti en électricité via la pile à combustible.
Ainsi, l'électricité (sous forme d'hydrogène) peut non seulement être stockée dans des réservoirs, mais aussi transportée avec le wagon-citerne.

Cependant, la conversion de l'électricité en hydrogène et vice versa est associée à des pertes. Sur 100 unités d'électricité, seulement 95 unités d'électricité sont à nouveau obtenues après la conversion en hydrogène et vice versa.

[ta4_hydrogen|image]

### Électrolyseur

L'électrolyseur convertit l'électricité et l'eau en hydrogène.
Il doit être alimenté en électricité par la gauche. L'eau doit être fournie via des tuyaux. À droite, l'hydrogène peut être prélevé via des tuyaux et des pompes.

L'électrolyseur peut absorber jusqu'à 35 ku d'électricité et génère alors une unité d'hydrogène toutes les 4 s.
Dans l'électrolyseur, 200 unités d'hydrogène peuvent tenir.

L'électrolyseur possède un menu de clé à molette pour régler l'absorption d'électricité et le point d'arrêt.

Si la puissance stockée dans le réseau électrique descend en dessous de la valeur spécifiée du point d'arrêt, l'électrolyseur s'éteint automatiquement. Ainsi, un vidage des systèmes de stockage peut être évité.

[ta4_electrolyzer|image]

### Pile à combustible

La pile à combustible convertit l'hydrogène en électricité.
Elle doit être alimentée en hydrogène par la gauche via une pompe. À droite se trouve la connexion électrique.

La pile à combustible peut fournir jusqu'à 34 ku d'électricité et nécessite pour cela une unité d'hydrogène toutes les 4 s.

Normalement, la pile à combustible fonctionne comme un générateur de catégorie 2 (comme les autres systèmes de stockage).
Dans ce cas, d'autres blocs de catégorie 2 comme le bloc de batterie ne peuvent pas être chargés.
Via la case à cocher, la pile à combustible peut également être utilisée comme un générateur de catégorie 1.

[ta4_fuelcell|image]

## Réacteur chimique / chemical reactor

Le réacteur sert à transformer les ingrédients obtenus via la tour de distillation ou d'autres recettes en nouveaux produits. Le plan de gauche montre seulement une variante possible, car l'agencement des silos et des réservoirs dépend des recettes.

Le produit de sortie primaire est toujours émis sur le côté du support de réacteur, indépendamment du fait qu'il s'agisse d'une poudre ou d'un liquide. Le produit de déchet (secondaire) est toujours émis en bas du support de réacteur.

Un réacteur se compose de :
- divers réservoirs et silos avec les ingrédients, qui sont connectés au doseur via des conduites
- optionnellement d'un socle de réacteur, qui évacue les déchets du réacteur (nécessaire uniquement pour les recettes avec deux substances de sortie)
- du support de réacteur, qui doit être placé sur le socle (le cas échéant). Le support a une connexion électrique et tire 8 ku en fonctionnement.
- du réacteur proprement dit, qui doit être placé sur le support de réacteur
- de la tubulure de remplissage qui doit être placée sur le réacteur
- du doseur, qui doit être connecté aux réservoirs ou silos ainsi qu'à la tubulure de remplissage via des conduites

Remarque 1 : Les liquides sont uniquement stockés dans des réservoirs, les substances solides et les substances sous forme de poudre uniquement dans des silos. Cela s'applique aux ingrédients et aux substances de sortie.

Remarque 2 : Les réservoirs ou silos avec différents contenus ne doivent pas être connectés à un système de conduites. Plusieurs réservoirs ou silos avec le même contenu peuvent en revanche être connectés en parallèle à une conduite.

Lors du craquage, les longues chaînes d'hydrocarbures sont cassées en chaînes courtes à l'aide d'un catalyseur. Le catalyseur utilisé est la poudre de gibbsite (non consommée). Ainsi, le bitume peut être transformé en fioul lourd, le fioul lourd en naphta et le naphta en essence.

Lors de l'hydrogénation, des paires d'atomes d'hydrogène sont ajoutées à une molécule pour transformer des hydrocarbures à chaîne courte en hydrocarbures à chaîne longue.
Ici, de la poudre de fer est nécessaire comme catalyseur (non consommée). Ainsi, le gaz propane peut être transformé en isobutane, l'isobutane en essence, l'essence en naphta, le naphta en fioul lourd et le fioul lourd en bitume.

[ta4_reactor|plan]

### TA4 Doseur / doser

Partie du réacteur chimique.
Sur les 4 côtés du doseur, des conduites pour les matériaux d'entrée peuvent être connectées. Vers le haut, les matériaux pour le réacteur sont émis.

Via le doseur, la recette peut être réglée et le réacteur démarré.

Comme pour les autres machines :
- si le doseur passe en mode standby, un ou plusieurs ingrédients manquent
- si le doseur passe en mode bloqué, le réservoir ou silo de sortie est plein, défectueux ou mal connecté

Le doseur n'a pas besoin d'électricité. Une recette est traitée toutes les 10 s.

[ta4_doser|image]

### TA4 Réacteur / reactor

Partie du réacteur chimique. Le réacteur dispose d'un inventaire pour les objets catalyseurs (pour les recettes de craquage et d'hydrogénation).

[ta4_reactor|image]

### TA4 Tubulure de remplissage / fillerpipe

Partie du réacteur chimique. Doit être placée sur le réacteur. Si cela ne fonctionne pas, éventuellement retirer et replacer le tuyau à la position au-dessus.

[ta4_fillerpipe|image]

### TA4 Support de réacteur / reactor stand

Partie du réacteur chimique. Ici se trouve également la connexion électrique pour le réacteur. Le réacteur nécessite 8 ku d'électricité.

Le support a deux connexions de conduite, à droite pour le produit de sortie primaire et en bas pour les déchets, comme par exemple la boue rouge lors de la production d'aluminium.

[ta4_reactorstand|image]

### TA4 Socle de réacteur / reactor base

Partie du réacteur chimique. Nécessaire pour l'évacuation du produit de déchet.

[ta4_reactorbase|image]

### TA4 Silo / silo

Partie du réacteur chimique. Nécessaire pour le stockage des substances sous forme de poudre ou de granulés.

[ta4_silo|image]

## Contrôleur ICTA

Le contrôleur ICTA (ICTA signifie "If Condition Then Action") sert à surveiller et à contrôler les machines. Avec le contrôleur, on peut lire les données des machines et d'autres blocs et, en fonction de cela, allumer/éteindre d'autres machines et blocs.

La lecture des données des machines ainsi que le contrôle des blocs et des machines se font via des commandes. Pour comprendre comment fonctionnent les commandes, le chapitre TA3 -> Blocs logiques/commutateurs est important.

Le contrôleur a besoin d'une batterie pour fonctionner. L'affichage sert à afficher les données, la tour de signalisation à afficher les erreurs.

[ta4_icta_controller|image]

### TA4 Contrôleur ICTA

Le contrôleur fonctionne sur la base de règles ```IF <condition> THEN <action>```. Jusqu'à 8 règles peuvent être créées par contrôleur.

Exemples de règles :

- Si un distributeur est bloqué (```blocked```), le poussoir devant doit être éteint
- Si une machine affiche une erreur, celle-ci doit être affichée sur l'écran

Le contrôleur vérifie ces règles de manière cyclique. Pour cela, un temps de cycle en secondes (```Cycle/s```) doit être indiqué pour chaque règle (1..1000).

Pour les règles qui évaluent une entrée on/off, par exemple d'un interrupteur ou d'un détecteur, le temps de cycle doit être indiqué comme 0. La valeur 0 signifie que cette règle doit être exécutée chaque fois que le signal d'entrée a changé, par exemple lorsque le bouton a envoyé une nouvelle valeur.

Toutes les règles ne doivent être exécutées que aussi souvent que nécessaire. Cela présente deux avantages :

- la batterie du contrôleur dure plus longtemps (chaque contrôleur nécessite une batterie)
- la charge pour le serveur est plus faible (donc moins de lags)

Pour chaque action, un temps de retard (```after/s```) doit être réglé. Si l'action doit être exécutée immédiatement, il faut entrer 0.

Le contrôleur a une aide et des indications sur toutes les commandes via le menu du contrôleur.

[ta4_icta_controller|image]

### Batterie

La batterie doit être placée à proximité immédiate du contrôleur, donc à l'une des 26 positions autour du contrôleur.

[ta4_battery|image]

### TA4 Affichage

L'affichage affiche son numéro après le placement. Via ce numéro, l'affichage peut être adressé. Des textes peuvent être affichés sur l'affichage, l'affichage pouvant représenter 5 lignes et donc 5 textes différents.

Les lignes de texte sont toujours affichées alignées à gauche. Si le texte doit être centré horizontalement, le caractère "	" (tabulation) doit être placé devant le texte.

L'affichage est mis à jour au maximum une fois par seconde.

[ta4_display|image]

### TA4 Affichage XL

Le TA4 Affichage XL a la taille double du TA4 Affichage.

Les lignes de texte sont toujours affichées alignées à gauche. Si le texte doit être centré horizontalement, le caractère "	" (tabulation) doit être placé devant le texte.

L'affichage est mis à jour au maximum toutes les deux secondes.

[ta4_displayXL|image]

### TA4 Tour de signalisation

La tour de signalisation peut afficher rouge, vert et orange. Une combinaison des 3 couleurs n'est pas possible.

[ta4_signaltower|image]

## TA4 Contrôleur Lua

Le contrôleur Lua doit, comme son nom l'indique, être programmé dans le langage de programmation Lua. De plus, il est utile de connaître un peu l'anglais (ou d'utiliser Google), car le manuel pour cela n'existe qu'en anglais :

https://github.com/joe7575/techage/blob/master/manuals/ta4_lua_controller_EN.md

Le contrôleur Lua a également besoin d'une batterie. La batterie doit être placée à proximité immédiate du contrôleur, donc à l'une des 26 positions autour du contrôleur.

[ta4_lua_controller|image]

### TA4 Serveur Lua

Le serveur sert au stockage central des données de plusieurs contrôleurs Lua. Il stocke également les données au-delà d'un redémarrage du serveur.

[ta4_lua_server|image]

### TA4 Coffre capteur / Sensor Chest

Le TA4 Coffre capteur sert à construire des entrepôts automatiques ou des distributeurs automatiques en combinaison avec le contrôleur Lua.
Si quelque chose est placé dans le coffre, ou retiré, ou si l'un des boutons "F1"/"F2" est pressé, un signal d'événement est envoyé au contrôleur Lua.
Le coffre capteur prend en charge les commandes suivantes :

- Via `state = $send_cmnd(<num>, "state")`, l'état du coffre peut être interrogé. Les réponses possibles sont : "empty", "loaded", "full"
- Via `name, action = $send_cmnd(<num>, "action")`, la dernière action du joueur peut être interrogée. `name` est le nom du joueur, `action` renvoie : "put", "take", "f1", "f2".
- Via `stacks = $send_cmnd(<num>, "stacks")`, le contenu du coffre peut être lu. Voir à ce sujet : https://github.com/joe7575/techage/blob/master/manuals/ta4_lua_controller_EN.md#sensor-chest
- Via `$send_cmnd(<num>, "text", "press both buttons and\nput something into the chest")`, le texte dans le menu du coffre capteur peut être défini.

Via la case à cocher "Permettre l'accès public", il peut être réglé si le coffre peut être utilisé par tout le monde, ou seulement par les joueurs qui ont des droits d'accès ici.

[ta4_sensor_chest|image]

### TA4 Terminal du contrôleur Lua

Le terminal sert à l'entrée/sortie pour le contrôleur Lua.

[ta4_terminal|image]

## Modules logiques/commutateurs TA4

### TA4 Bouton/Interrupteur / Button/Switch

Pour le TA4 Bouton/Interrupteur, seul l'apparence a changé. La fonctionnalité est la même que pour le TA3 Bouton/Interrupteur. Avec le menu de la clé à molette, les données peuvent être modifiées ultérieurement.

[ta4_button|image]

### TA4 2x Bouton / 2x Button

Ce bloc a deux boutons qui peuvent être configurés individuellement via le menu de la clé à molette. Pour les deux boutons, l'étiquette et l'adresse du bloc cible peuvent être configurées. De plus, la commande à envoyer peut être configurée pour les deux boutons.

[ta4_button_2x|image]

### TA4 4x Bouton / 4x Button

Ce bloc a quatre boutons qui peuvent être configurés individuellement via le menu de la clé à molette. Pour chaque bouton, l'étiquette et l'adresse du bloc cible peuvent être configurées. De plus, la commande à envoyer peut être configurée pour chaque bouton.

[ta4_button_4x|image]

### TA4 2x Lampe de signalisation / 2x Signal Lamp

Ce bloc a deux lampes qui peuvent être commandées individuellement. Chaque lampe peut afficher les couleurs "rouge", "verte" et "orange". Via le menu de la clé à molette, l'étiquette peut être configurée pour les deux lampes. Les lampes peuvent être commandées via les commandes suivantes :

- Allumer la lampe 1 en rouge : `$send_cmnd(1234, "red", 1)`
- Allumer la lampe 2 en vert : `$send_cmnd(1234, "green", 2)`
- Allumer la lampe 1 en orange : `$send_cmnd(1234, "amber", 1)`
- Éteindre la lampe 2 : `$send_cmnd(1234, "off", 2)`

[ta4_signallamp_2x|image]

### TA4 4x Lampe de signalisation / 4x Signal Lamp

Ce bloc a quatre lampes qui peuvent être commandées individuellement. Chaque lampe peut afficher les couleurs "rouge", "verte" et "orange". Via le menu de la clé à molette, l'étiquette peut être configurée pour toutes les lampes. Les lampes peuvent être commandées via les commandes suivantes :

- Allumer la lampe 1 en rouge : `$send_cmnd(1234, "red", 1)`
- Allumer la lampe 2 en vert : `$send_cmnd(1234, "green", 2)`
- Allumer la lampe 3 en orange : `$send_cmnd(1234, "amber", 3)`
- Éteindre la lampe 4 : `$send_cmnd(1234, "off", 4)`

[ta4_signallamp_4x|image]

### TA4 Détecteur de joueur / Player Detector

Pour le TA4 Détecteur de joueur, seul l'apparence a changé. La fonctionnalité est la même que pour le TA3 Détecteur de joueur.

[ta4_playerdetector|image]

### TA4 Collecteur d'état / State Collector

[ta4_collector|image]

Le collecteur d'état interroge successivement tous les machines configurées pour leur état. Si l'une des machines a atteint ou dépassé un état préconfiguré, une commande "on" est envoyée. Ainsi, par exemple, de nombreuses machines peuvent être surveillées pour des perturbations à partir d'un contrôleur Lua.

### TA4 Détecteur d'objets / Item Detector

La fonctionnalité est la même que pour le TA3 Détecteur / Detector. En plus, le détecteur compte les objets transmis.
Ce compteur peut être interrogé via la commande 'count' et réinitialisé via 'reset'.

[ta4_detector|image]

### TA4 Détecteur de blocs / Node Detector

La fonctionnalité est la même que pour le TA3 Détecteur de blocs.

Contrairement au TA3 Détecteur de blocs, les positions à surveiller peuvent être configurées individuellement ici. Pour cela, le bouton "Enregistrer" doit être pressé. Ensuite, tous les blocs doivent être cliqués, dont la position doit être vérifiée. Ensuite, le bouton "Terminé" doit être pressé.

Jusqu'à 4 blocs peuvent être sélectionnés.

[ta4_nodedetector|image]

### TA4 Détecteur de charge du stockage d'énergie / Energy Storage Charge Detector

Le détecteur de charge mesure toutes les 8 s l'état de charge du stockage d'énergie du réseau électrique.

Si la valeur descend en dessous d'un seuil configurable (point de commutation), une commande (par défaut : "off") est envoyée. Si la valeur remonte au-dessus de ce point de commutation, une deuxième commande (par défaut : "on") est envoyée. Ainsi, les consommateurs peuvent être déconnectés du réseau lorsque l'état de charge du stockage d'énergie descend en dessous du point de commutation spécifié.

Pour cela, le détecteur de charge doit être connecté au réseau électrique via une boîte de distribution. La configuration du détecteur de charge se fait via le menu de la clé à molette.

[ta4_chargedetector|image]

### TA4 Capteur de regard / Gaze Sensor

Le capteur de regard TA4 génère une commande lorsque le bloc est regardé/focalisé par le propriétaire ou d'autres joueurs configurés et envoie une deuxième commande lorsque le bloc n'est plus focalisé. Il sert ainsi de remplacement pour les boutons/interrupteurs, par exemple pour ouvrir/fermer des portes.

Le capteur de regard TA4 ne peut être programmé qu'avec le menu de la clé à molette. Si l'on a une clé à molette en main, le capteur ne se déclenche pas, même s'il est focalisé.

[ta4_gaze_sensor|image]

### TA4 Séquenceur

Via le séquenceur TA4, des séquences entières peuvent être programmées. Voici un exemple :

```
-- this is a comment
[1] send 1234 a2b
[30] send 1234 b2a
[60] goto 1
```

- Chaque ligne commence par un numéro qui correspond à un moment `[<num>]`
- Pour les moments, des valeurs de 1 à 50000 sont autorisées
- 1 correspond à 100 ms, 50000 correspond à environ 4 jours de jeu
- Les lignes vides ou les commentaires sont autorisés (`-- comment`)
- Avec `send <num> <command> <data>`, une commande peut être envoyée à un bloc
- Avec `goto <num>`, on peut sauter à une autre ligne/moment
- Avec `stop`, on peut arrêter le séquenceur de manière différée, de sorte qu'il n'accepte plus de nouvelle commande d'un bouton ou d'un autre bloc (pour terminer un mouvement)
  Sans `stop`, le séquenceur passe immédiatement en mode arrêté après la dernière commande.

Le séquenceur TA4 prend en charge les commandes techage suivantes :

- `goto <num>` Sauter à une ligne de commande et ainsi démarrer le séquenceur
- `stop` Arrêter le séquenceur
- `on` et `off` comme alias pour `goto 1` et `stop`

La commande `goto` n'est acceptée que si le séquenceur est arrêté.

Via le menu de la clé à molette, le temps de cycle du séquenceur peut être modifié (normal : 100 ms).

[ta4_sequencer|image]

## Contrôleur de mouvement/rotation

### TA4 Contrôleur de mouvement

Le contrôleur de mouvement TA4 est similaire au "Door Controller 2", mais les blocs sélectionnés ne sont pas retirés, mais peuvent être déplacés.
Comme les blocs déplacés peuvent emporter des joueurs et des mobs qui se trouvent sur le bloc, des ascenseurs et des systèmes de transport similaires peuvent être construits.

Instructions :

- Placer le contrôleur et entraîner les blocs qui doivent être déplacés via le menu (bouton "Enregistrer") (jusqu'à 16 blocs peuvent être entraînés)
- la "distance de vol" doit être saisie via une indication x,y,z (relative) (la distance maximale est de 1000 m)
- avec les boutons de menu "Déplacer A-B" et "Déplacer B-A", le mouvement peut être testé
- on peut également voler à travers des murs ou d'autres blocs
- la position cible pour les blocs peut également être occupée. Les blocs sont alors stockés "invisibles". Cela est prévu pour les portes coulissantes et similaires

Le contrôleur de mouvement prend en charge les commandes techage suivantes :

- `a2b` Déplacer le bloc de A à B
- `b2a` Déplacer le bloc de B à A
- `move` Déplacer le bloc de l'autre côté

Via le menu de la clé à molette, on peut passer en mode de fonctionnement `move xyz`. Après la commutation, les commandes techage suivantes sont prises en charge :

- `move2` Avec la commande, la distance de vol doit être indiquée en plus comme vecteur x,y,z.
  Exemple de contrôleur Lua : `$send_cmnd(MOVE_CTLR, "move2", "0,12,0")`
- `moveto` déplace le bloc vers la position cible indiquée (la position cible se réfère au premier bloc marqué, les autres blocs sont déplacés par rapport à cette position)
- `reset` Déplacer le(s) bloc(s) en position de départ

**Remarques importantes :**

- Si plusieurs blocs doivent être déplacés, le bloc qui doit emporter les joueurs/mobs doit être cliqué en premier lors de l'entraînement.
- Si la commande `moveto` est utilisée, la position cible indiquée s'applique au bloc qui a été cliqué en premier lors de l'entraînement.
- Si le bloc qui doit emporter les joueurs/mobs a une hauteur réduite, la hauteur doit être réglée dans le contrôleur via le menu de la clé à molette (par exemple, hauteur = 0,5). Sinon, le joueur/mob n'est pas "trouvé" et donc pas emporté.

[ta4_movecontroller|image]

### TA4 Contrôleur de rotation / Turn Controller

Le contrôleur de rotation TA4 est similaire au "Move Controller", mais les blocs sélectionnés ne sont pas déplacés, mais tournés vers la droite ou la gauche autour de leur centre.

Instructions :

- Placer le contrôleur et entraîner les blocs qui doivent être déplacés via le menu (jusqu'à 16 blocs peuvent être entraînés)
- avec les boutons de menu "Tourner à gauche" et "Tourner à droite", le mouvement peut être testé

Le contrôleur de rotation prend en charge les commandes techage suivantes :

- `left` Tourner à gauche
- `right` Tourner à droite
- `uturn` Tourner de 180 degrés

[ta4_turncontroller|image]

## Lampes TA4

TA4 comprend une série de lampes puissantes qui permettent un meilleur éclairage ou remplissent des tâches spéciales.

### TA4 Lampe de culture LED / TA4 LED Grow Light

La lampe de culture LED TA4 permet une croissance rapide et vigoureuse de toutes les plantes de la mod `farming`. La lampe éclaire un champ de 3x3, de sorte que les plantes peuvent également être cultivées sous terre.
La lampe doit être placée à une distance d'un bloc au-dessus du sol au centre du champ de 3x3.

En plus, la lampe peut également être utilisée pour la culture de fleurs. Si la lampe est placée au-dessus d'un parterre de fleurs de 3x3 en "Garden Soil" (mod `compost`), les fleurs y poussent toutes seules (au-dessus et en dessous du sol).

Les fleurs peuvent être récoltées avec le Signs Bot, qui dispose également d'un signe correspondant qui doit être placé devant le champ de fleurs.

La lampe nécessite 1 ku d'électricité.

[ta4_growlight|image]

### TA4 Lampe de rue LED / TA4 LED Street Lamp

La lampe de rue LED TA4 est une lampe avec un éclairage particulièrement puissant. La lampe se compose des blocs de boîtier de lampe, de bras de lampe et de mât de lampe.

Le courant doit être conduit de bas en haut à travers le mât jusqu'au boîtier de la lampe. Pour cela, tirez d'abord le câble électrique vers le haut et "enduisez" le câble électrique avec des blocs de mât de lampe.

La lampe nécessite 1 ku d'électricité.

[ta4_streetlamp|image]

### TA4 Lampe industrielle LED / TA4 LED Industrial Lamp

La lampe industrielle LED TA4 est une lampe avec un éclairage particulièrement puissant. La lampe doit être alimentée en électricité par le haut.

La lampe nécessite 1 ku d'électricité.

[ta4_industriallamp|image]

### TA4 Feu de circulation / TA4 Traffic Light

Le feu de circulation TA4 existe en deux versions : en noir (version européenne) et en jaune (version américaine). En plus, il y a un mât, un bras et un bloc de connecteur. Le feu de circulation peut être monté sur ou à un mât. Il ne peut cependant pas être monté à un bras. Cela a des raisons techniques. Pour cela, il y a le bloc de connecteur, qui est placé entre le bras et le feu de circulation.

Le feu de circulation peut être commandé via des commandes comme pour la tour de signalisation TA4.
Si le détecteur de joueur TA4 est également utilisé, le feu de circulation peut également réagir aux piétons ou aux véhicules.

Le feu de circulation n'a pas besoin d'électricité.

[ta4_trafficlight|image]

## Filtre à liquide TA4

Dans le filtre à liquide, la boue rouge est filtrée.
Cela produit soit de la lessive, qui peut être collectée dans un réservoir en bas, soit des pavés de tête de désert, qui se déposent dans le filtre.
Si le filtre est trop obstrué, il doit être vidé et rempli à nouveau.
Le filtre se compose d'un niveau de fondation, sur lequel sont placées 7 couches de filtre identiques.
Tout en haut se trouve le niveau de remplissage.

[ta4_liquid_filter|image]

### Niveau de fondation

La structure de ce niveau peut être prise du plan.

Dans le réservoir, la lessive est collectée.

[ta4_liquid_filter_base|plan]

### Niveau de gravier

Ce niveau doit être rempli de gravier comme montré dans le plan.
Au total, sept couches de gravier doivent être superposées.
Au fil du temps, le filtre se salit, de sorte que le matériau de remplissage doit être renouvelé.

[ta4_liquid_filter_gravel|plan]

### Niveau de remplissage

Ce niveau sert à remplir le filtre avec de la boue rouge.
De la boue rouge doit être conduite dans la tubulure de remplissage à l'aide d'une pompe.

[ta4_liquid_filter_top|plan]

## Accélérateur de particules TA4 / Collider

L'accélérateur de particules est une installation de recherche où la recherche fondamentale est menée. Ici, des points d'expérience (experience points) peuvent être collectés, qui sont nécessaires pour TA5 (Future Age).

L'accélérateur de particules doit être construit souterrain comme son original au CERN à Genève. Le réglage standard est Y <= -28. La valeur peut cependant être modifiée par le personnel du serveur via la configuration. Il est préférable de demander ou d'essayer avec le bloc "TA4 Collider Detector Worker".

Par joueur, un seul accélérateur de particules peut être exploité. Il est donc inutile de construire deux ou plusieurs accélérateurs de particules. Les points d'expérience sont crédités au joueur à qui appartient l'accélérateur de particules. Les points d'expérience ne peuvent pas être transférés.

Un accélérateur de particules se compose d'un "anneau" de tubes et d'aimants ainsi que du détecteur avec système de refroidissement.

- Le détecteur est le cœur de l'installation. C'est ici que se déroulent les expériences scientifiques. Le détecteur mesure 3x3x7 blocs.
- 22 aimants TA4 Collider (pas les aimants TA4 Collider Detector !) doivent être connectés entre eux via respectivement 5 blocs du tube à vide TA4. L'ensemble forme (comme illustré à droite dans le plan) un carré avec une longueur de côté de 37 mètres.

Le plan montre l'installation de dessus :

- le bloc gris est le détecteur avec le bloc Worker au centre
- les blocs rouges sont les aimants, les bleus sont les tubes à vide

[techage_collider_plan|plan]

### Détecteur

Le détecteur est construit automatiquement à l'aide du bloc "TA4 Collider Detector Worker" (similaire à la tour de forage). Tous les matériaux nécessaires doivent être placés au préalable dans le bloc Worker. Le détecteur est symboliquement représenté sur le bloc Worker. Le détecteur est construit au-dessus du bloc Worker en direction transversale.

Le détecteur peut également être démonté à l'aide du bloc Worker.

Sur les deux côtés frontaux du détecteur se trouvent les connexions pour l'électricité, le gaz et le tube à vide. En haut, une pompe TA4 doit être connectée pour aspirer le tube/ créer le vide.

Sur le côté arrière du détecteur, le système de refroidissement doit être connecté. Dans le plan de droite, le système de refroidissement est illustré. Ici, en plus de l'échangeur de chaleur TA4 d'un stockage d'énergie (qui est utilisé ici pour le refroidissement), un bloc de refroidisseur TA4 est également nécessaire.

Remarque : La flèche de l'échangeur de chaleur doit pointer loin du détecteur. L'échangeur de chaleur doit également être alimenté en électricité.

[ta4_cooler|plan]

### Commande / TA4 Terminal

L'accélérateur de particules est commandé via un terminal TA4 (pas via le terminal du contrôleur Lua TA4).

Ce terminal doit être connecté au détecteur. Le numéro du détecteur est affiché comme texte d'information sur le bloc Worker.

Le terminal prend en charge les commandes suivantes :

- `connect <number>` (connecter au détecteur)
- `start` (démarrer le détecteur)
- `stop` (arrêter le détecteur)
- `test <number>` (vérifier un aimant)
- `points` (interroger les points d'expérience déjà atteints)

Si une erreur se produit lors du `start` sur un aimant, le numéro de l'aimant est affiché. Via la commande `test`, des informations supplémentaires sur l'erreur de l'aimant peuvent être demandées.

[ta4_terminal|image]

### Refroidissement et électricité

Chaque aimant TA4 Collider doit en plus (comme illustré à droite dans le plan) être alimenté en électricité ainsi qu'en isobutane pour le refroidissement :

- La connexion pour l'électricité est sur le dessus de l'aimant.
- La connexion pour le refroidissement est sur le devant de l'aimant.
- Pour le refroidissement de l'installation entière, une pompe TA4 et un réservoir TA4 avec au moins 250 unités d'isobutane sont nécessaires en plus.
- L'installation nécessite également une quantité importante d'électricité. Par conséquent, une alimentation électrique propre avec au moins 145 ku est judicieuse.

[techage_collider_plan2|plan]

### Construction

Lors de la construction de l'accélérateur de particules, l'ordre suivant est recommandé :

- Placer un bloc Forceload. Seul le détecteur avec le système de refroidissement doit se trouver dans la zone du bloc Forceload.
- Placer le bloc Worker, le remplir d'objets et construire le détecteur via le menu
- Construire l'anneau avec des tubes et des aimants
- Connecter tous les aimants et le détecteur avec des câbles électriques
- Connecter tous les aimants et le détecteur avec les tuyaux jaunes et pomper l'isobutane dans le système de tuyaux avec une pompe.
- Installer et allumer une pompe TA4 comme pompe à vide sur le détecteur (aucun réservoir supplémentaire n'est nécessaire). Lorsque la pompe passe en "standby", le vide est établi. Cela prend quelques secondes
- Construire le refroidisseur (échangeur de chaleur) et le connecter avec le câble électrique
- Placer le terminal TA4 devant le détecteur et le connecter au détecteur via `connect <numéro>`
- Établir/activer l'alimentation électrique
- Allumer le refroidisseur (échangeur de chaleur)
- Allumer le détecteur via `start` sur le terminal TA4. Le détecteur passe en mode de fonctionnement normal après quelques étapes de test ou affiche une erreur.
- L'accélérateur de particules doit fonctionner en continu et fournit alors progressivement des points d'expérience. Pour 10 points, l'accélérateur de particules doit déjà fonctionner pendant plusieurs heures.

[techage_ta4c|image]

## Autres blocs TA4

### TA4 Bloc de recette

Dans le bloc de recette, jusqu'à 10 recettes peuvent être stockées. Ces recettes peuvent ensuite être récupérées via une commande TA4 Autocrafter. Cela permet une configuration de recette de l'Autocrafter via une commande. Les recettes du bloc de recette peuvent également être interrogées directement par commande.

`input <index>` lit une recette du bloc de recette TA4. `<index>` est le numéro de la recette. Le bloc renvoie une liste d'ingrédients de recette.

Exemple : `$send_cmnd(1234, "input", 1)`

[ta4_recipeblock|image]

### TA4 Autocrafter

La fonction correspond à celle de TA3.

La capacité de traitement est de 4 objets toutes les 4 s. L'Autocrafter nécessite 9 ku d'électricité.

En plus, l'Autocrafter TA4 prend en charge la sélection de différentes recettes via les commandes suivantes :

`recipe "<number>.<index>"` passe l'Autocrafter à une recette du bloc de recette TA4. `<number>` est le numéro du bloc de recette, `<index>` le numéro de la recette. Exemple : `$send_cmnd(1234, "recipe", "5467.1")`

Alternativement, une recette peut également être sélectionnée via la liste des ingrédients, comme par exemple :
`$send_cmnd(1234, "recipe", "default:coal_lump,,,default:stick")`
Ici, tous les noms techniques d'une recette doivent être indiqués, séparés par des virgules. Voir également la commande `input` dans le bloc de recette TA4.

La commande `flush` déplace tous les articles de l'inventaire d'entrée vers l'inventaire de sortie. La commande renvoie `true` si l'inventaire d'entrée est complètement vidé. Si `false` est renvoyé (l'inventaire de sortie est plein), la commande doit être répétée à un moment ultérieur.

[ta4_autocrafter|image]

### TA4 Réservoir / TA4 Tank

Voir TA3 Réservoir.

Dans un réservoir TA4, 2000 unités ou 200 fûts d'un liquide peuvent tenir.

[ta4_tank|image]

### TA4 Pompe / TA4 Pump

Voir TA3 Pompe.

La pompe TA4 pompe 8 unités de liquide toutes les deux secondes.

En mode "limiteur de débit", le nombre d'unités pompées par la pompe peut être limité. Le mode limiteur de débit peut être activé via le menu de la clé à molette, en configurant le nombre d'unités dans le menu. Dès que le nombre configuré d'unités a été pompé, la pompe s'éteint. Si la pompe est rallumée, elle pompe à nouveau le nombre configuré d'unités et s'éteint ensuite.

La pompe TA4 peut également être configurée et démarrée par un contrôleur Lua ou Beduino.

En plus, la pompe prend en charge la commande `flowrate`. Ainsi, le débit total à travers la pompe peut être interrogé.

[ta4_pump|image]

### TA4 Chauffage de four / furnace heater

Avec TA4, le four industriel a également son chauffage électrique. Le brûleur à pétrole et également le ventilateur peuvent être remplacés par le chauffage de four.

Le chauffage de four nécessite 14 ku d'électricité.

[ta4_furnaceheater|image]

### TA4 Pompe à eau / Water Pump (obsolète)

Ce bloc ne peut plus être fabriqué et est remplacé par le bloc TA4 Entrée d'eau.

### TA4 Entrée d'eau / TA4 Water Inlet

Pour certaines recettes, de l'eau est nécessaire. L'eau doit être pompée de la mer (eau à y = 1) avec une pompe. Un "bassin" de quelques blocs d'eau n'est pas suffisant !

Pour cela, le bloc d'entrée d'eau doit être placé dans l'eau et connecté à la pompe via des tuyaux. Si le bloc est placé dans l'eau, il faut veiller à ce qu'il y ait de l'eau sous le bloc (l'eau doit avoir au moins 2 blocs de profondeur).

[ta4_waterinlet|image]

### TA4 Tubes / TA4 Tube

TA4 a également ses propres tubes dans le design TA4. Ceux-ci peuvent être utilisés comme des tubes standard.
Mais : les poussoirs TA4 et les distributeurs TA4 atteignent leur pleine capacité de performance uniquement lors de l'utilisation avec des tubes TA4.

[ta4_tube|image]

### TA4 Poussoir / Pusher

La fonction correspond fondamentalement à celle de TA2/TA3. En plus, il peut être configuré via un menu quels objets doivent être prélevés d'une caisse TA4 et transportés plus loin.
La capacité de traitement est de 12 objets toutes les 2 s, à condition que des tubes TA4 soient utilisés des deux côtés. Sinon, ce n'est que 6 objets toutes les 2 s.

En mode "limiteur de débit", le nombre d'objets déplacés par le poussoir peut être limité. Le mode limiteur de débit peut être activé via le menu de la clé à molette, en configurant le nombre d'objets dans le menu. Dès que le nombre configuré d'objets a été déplacé, le poussoir s'éteint. Si le poussoir est rallumé, il déplace à nouveau le nombre configuré d'objets et s'éteint ensuite.

Le poussoir TA4 peut également être configuré et démarré par un contrôleur Lua ou Beduino.

Voici les commandes supplémentaires pour le contrôleur Lua :

- `config` sert à configurer le poussoir, de manière analogue à la configuration manuelle via le menu.
  Exemple : `$send_cmnd(1234, "config", "default:dirt")`
  Avec `$send_cmnd(1234, "config", "")`, la configuration est supprimée
- `limit` sert à définir le nombre d'objets pour le mode limiteur de débit :
  Exemple : `$send_cmnd(1234, "init", 7)`

[ta4_pusher|image]

### TA4 Caisse / TA4 Chest

La fonction correspond à celle de TA3. La caisse peut cependant contenir plus de contenu.

En plus, la caisse TA4 possède un inventaire fantôme pour la configuration. Ici, certains emplacements de stockage peuvent être pré-remplis avec un objet. Les emplacements de stockage pré-remplis ne sont remplis que avec ces objets lors du remplissage. Pour vider un emplacement de stockage pré-rempli, un poussoir TA4 ou un injecteur TA4 avec la configuration correspondante est nécessaire.

[ta4_chest|image]

### TA4 Caisse 8x2000 / TA4 8x2000 Chest

La caisse TA4 8x2000 n'a pas d'inventaire normal comme les autres caisses, mais dispose de 8 stockages, chaque stockage pouvant contenir jusqu'à 2000 objets d'un type. Via les boutons orange, des objets peuvent être déplacés dans le stockage ou en être retirés. La caisse peut également être remplie ou vidée comme d'habitude avec un poussoir (TA2, TA3 ou TA4).

Si la caisse est remplie avec un poussoir, tous les emplacements de stockage sont remplis de gauche à droite. Si les 8 stockages sont pleins et que d'autres objets ne peuvent plus être ajoutés, les objets supplémentaires sont rejetés.

**Fonction de rangée**

Plusieurs caisses TA4 8x2000 peuvent être connectées pour former une grande caisse avec plus de contenu. Pour cela, les caisses doivent être placées en rangée les unes derrière les autres.

D'abord, la caisse avant doit être placée, puis les caisses de pile sont placées derrière avec la même orientation (toutes les caisses ont l'avant en direction du joueur). Avec 2 caisses en rangée, la taille passe à 8x4000, etc.

Les caisses alignées ne peuvent plus être retirées. Pour pouvoir à nouveau démonter les caisses, il y a deux possibilités :

- Vider et retirer la caisse avant. Ainsi, la caisse suivante est déverrouillée et peut être retirée.
- Vider la caisse avant de sorte que tous les emplacements de stockage contiennent au maximum 2000 objets. Ainsi, la caisse suivante est déverrouillée et peut être retirée.

Les caisses ont une case à cocher "Ordre". Si cette case à cocher est activée, les emplacements de stockage ne sont plus complètement vidés par un poussoir. Le dernier objet reste comme pré-remplissage dans l'emplacement de stockage. Ainsi, une affectation fixe des objets aux emplacements de stockage est obtenue.

La caisse ne peut être utilisée que par les joueurs qui peuvent également construire à cet endroit, c'est-à-dire qui possèdent des droits de protection. Il n'a pas d'importance qui place la caisse.

La caisse possède une commande supplémentaire pour le contrôleur Lua :

- `count` sert à demander combien d'objets se trouvent dans la caisse.
  Exemple 1 : `$send_cmnd(CHEST, "count")` --> Somme des objets sur les 8 stockages
  Exemple 2 : `$send_cmnd(CHEST, "count", 2)` --> Nombre d'objets dans le stockage 2 (deuxième depuis la gauche)
- `storesize` est utilisé pour lire la taille de l'un des huit stockages
  Exemple : `$send_cmnd(CHEST, "storesize")` -> La fonction renvoie par exemple 6000

[ta4_8x2000_chest|image]

### TA4 Distributeur / Distributor

La fonction correspond à celle de TA2.
La capacité de traitement est de 24 objets toutes les 4 s, à condition que des tubes TA4 soient utilisés de tous les côtés. Sinon, ce n'est que 12 objets toutes les 4 s.

[ta4_distributor|image]

### TA4 Distributeur haute performance / High Performance Distributor

La fonction correspond au distributeur TA4 normal, avec deux différences :
La capacité de traitement est de 36 objets toutes les 4 s, à condition que des tubes TA4 soient utilisés de tous les côtés. Sinon, ce n'est que 18 objets toutes les 4 s.
De plus, jusqu'à 8 objets peuvent être configurés par sortie.

[ta4_high_performance_distributor|image]

### TA4 Tamis à gravier / Gravel Sieve

La fonction correspond à celle de TA2.
La capacité de traitement est de 4 objets toutes les 4 s. Le bloc nécessite 5 ku d'électricité.

[ta4_gravelsieve|image]

### TA4 Moulin / Grinder

La fonction correspond à celle de TA2.
La capacité de traitement est de 4 objets toutes les 4 s. Le bloc nécessite 9 ku d'électricité.

[ta4_grinder|image]

### TA4 Concasseur / Quarry

La fonction correspond largement à celle de TA2.

En plus, la taille du trou peut être réglée entre 3x3 et 11x11 blocs.
La profondeur maximale est de 80 mètres. Le concasseur nécessite 14 ku d'électricité.

[ta4_quarry|image]

### TA4 Élimine-eau / Water Remover

L'élimine-eau élimine l'eau d'une surface allant jusqu'à 21 x 21 x 80 m.
Le but principal est l'assèchement des grottes. Il peut également être utilisé pour "percer" un trou dans la mer.

L'élimine-eau nécessite de l'électricité et une connexion de tuyau à un réservoir de liquide.

L'élimine-eau est placé au point le plus élevé de la grotte et élimine l'eau de la grotte vers le point le plus bas. L'élimine-eau creuse un bloc d'eau toutes les deux secondes.
L'appareil nécessite 10 Ku d'électricité.

Techniquement, l'élimine-eau remplace les blocs d'eau par un bloc d'air spécial, qui n'est pas visible et ne peut pas être traversé, mais empêche l'eau de revenir.

[ta4_waterremover|image]

### TA4 Usine d'électronique / Electronic Fab

La fonction correspond à celle de TA2, mais ici différents puces sont produites.
La capacité de traitement est d'une puce toutes les 6 s. Le bloc nécessite 12 ku d'électricité.

[ta4_electronicfab|image]

### TA4 Injecteur / Injector

La fonction correspond à celle de TA3.

La capacité de traitement est jusqu'à 8 fois quatre objets toutes les 4 secondes.

[ta4_injector|image]

### TA4 Recycleur

Le recycleur est une machine qui traite toutes les recettes Techage à l'envers, c'est-à-dire qu'il peut décomposer les machines et les blocs en leurs composants. La machine peut ainsi décomposer presque tous les blocs Techage et Hyperloop.
Mais tous les ingrédients/matériaux des recettes ne peuvent pas être recyclés :

- Le bois devient des bâtons
- La pierre devient du sable ou du gravier
- Les semi-conducteurs/puces ne peuvent pas être recyclés
- Les outils ne peuvent pas être recyclés

La capacité de traitement est d'un objet toutes les 8 s. Le bloc nécessite 16 ku d'électricité.

[ta4_recycler|image]
