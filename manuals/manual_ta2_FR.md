# TA2 : Âge de la Vapeur

Dans TA2, il s'agit de construire et de faire fonctionner les premières machines pour le traitement des minerais. Certaines machines doivent être entraînées par des axes d'entraînement. Pour cela, vous devez construire une machine à vapeur et la chauffer avec du charbon ou du charbon de bois.

Dans TA2, un laveur de gravier est également disponible, avec lequel des minerais rares comme les pépites d'Usmium peuvent être lavés. Ces pépites seront nécessaires plus tard pour d'autres recettes.

[techage_ta2|image]

## Machine à vapeur

La machine à vapeur se compose de plusieurs blocs et doit être assemblée comme illustré dans le plan à droite. Pour cela, les blocs TA2 Boîte à feu, TA2 Chaudiere haut, TA2 Chaudiere bas, TA2 Cylindre, TA2 Volant d'inertie et Conduites de vapeur sont nécessaires.

En outre, des axes d'entraînement ainsi que des blocs d'engrenage pour les changements de direction sont nécessaires. Le volant d'inertie doit être connecté via les axes d'entraînement à toutes les machines qui doivent être entraînées.

Pour tous les blocs, lors du placement, faites également attention à l'orientation :

- Cylindre à gauche, volant d'inertie à droite à côté
- Connecter les conduites de vapeur là où il y a un trou correspondant
- Axe d'entraînement au volant d'inertie uniquement à droite
- pour toutes les machines, l'axe d'entraînement peut être connecté de tous les côtés qui ne sont pas occupés par d'autres fonctions, comme par exemple les trous IN et OUT dans le moulin et le tamis.

La chaudière doit être remplie d'eau. Pour cela, remplissez la chaudière avec jusqu'à 10 seaux d'eau.
La boîte à feu doit être remplie de charbon ou de charbon de bois.
Lorsque l'eau est chaude (indication de température tout en haut), la machine à vapeur peut être démarrée au volant d'inertie.

La machine à vapeur fournit 25 ku et peut ainsi entraîner plusieurs machines simultanément.

[steamengine|plan]

### TA2 Boîte à feu / Firebox

Partie de la machine à vapeur.

La boîte à feu doit être remplie de charbon ou de charbon de bois. La durée de combustion dépend de la puissance demandée par la machine à vapeur. À pleine charge, le charbon brûle pendant 32 s et le charbon de bois pendant 96 s.

[ta2_firebox|image]

### TA2 Chaudiere

Partie de la machine à vapeur. Doit être remplie d'eau. Cela se fait en cliquant avec un seau d'eau sur la chaudière. Si plus d'eau n'est disponible ou si la température descend trop bas, la machine à vapeur s'éteint. Avec la machine à vapeur, une certaine quantité d'eau est perdue sous forme de vapeur à chaque coup de piston, donc de l'eau doit être régulièrement ajoutée.

[ta2_boiler|image]

### TA2 Cylindre / Cylinder

Partie de la machine à vapeur.

[ta2_cylinder|image]

### TA2 Volant d'inertie / Flywheel

Partie d'entraînement de la machine à vapeur. Le volant d'inertie doit être connecté aux machines via des axes d'entraînement.

[ta2_flywheel|image]

### TA2 Conduites de vapeur / Steam Pipe

Partie de la machine à vapeur. La chaudière doit être connectée au cylindre via les conduites de vapeur (steam pipes). La conduite de vapeur n'a pas de branches, la longueur maximale est de 12 m (blocs).

[ta2_steampipe|image]

### TA2 Axes d'entraînement / TA2 Drive Axle

Les axes d'entraînement servent à transmettre la force de la machine à vapeur à d'autres machines. La longueur maximale d'un axe d'entraînement est de 10 blocs. Des blocs d'engrenage peuvent également être utilisés pour couvrir de plus grandes distances, ainsi que pour créer des branches et des changements de direction.

[ta2_driveaxle|image]

### TA2 Générateur électrique / TA2 Power Generator

Pour faire fonctionner des lampes ou d'autres consommateurs d'électricité sur une machine à vapeur, le générateur électrique TA2 est nécessaire. Le générateur électrique TA2 doit être connecté d'un côté aux axes d'entraînement et fournit alors de l'électricité de l'autre côté.

Si le générateur électrique n'est pas alimenté avec suffisamment de force, il passe en état d'erreur et doit être réactivé par un clic droit.

Le générateur électrique absorbe principalement un maximum de 25 ku de force d'axe et restitue secondairement un maximum de 24 ku sous forme d'électricité. Il consomme donc 1 ku pour la conversion.

[ta2_generator|image]

## TA2 Stockage d'énergie

Pour les grandes installations avec plusieurs machines à vapeur ou de nombreuses machines entraînées, un stockage d'énergie est recommandé. Le stockage d'énergie dans TA2 fonctionne avec de l'énergie potentielle. Pour cela, du ballast (pierres, gravier) est tiré vers le haut dans une caisse à l'aide d'un treuil. Si de l'énergie excédentaire est présente dans le réseau d'axes, la caisse est tirée vers le haut. Si plus d'énergie est nécessaire à court terme que ce que la machine à vapeur peut fournir, le stockage d'énergie restitue l'énergie stockée, et la caisse de ballast se déplace à nouveau vers le bas.

Le stockage d'énergie se compose de plusieurs blocs et doit être assemblé comme illustré dans le plan à droite.

Pour atteindre la capacité de stockage maximale, la caisse doit être complètement remplie de poids, et le mât, y compris les deux blocs d'engrenage, doit avoir une hauteur de 12 blocs. Des constructions plus petites sont également possibles.

[ta2_storage|plan]

### TA2 Treuil / TA2 Winch

Le treuil doit être connecté à un bloc d'engrenage et peut ainsi absorber l'énergie excédentaire et tirer une caisse de poids vers le haut. Lors de la construction du treuil, assurez-vous que la flèche sur le dessus du bloc pointe vers le bloc d'engrenage. La longueur maximale de la corde est de 10 blocs.

[ta2_winch|image]

### TA2 Caisse de poids / TA2 Weight Chest

Cette caisse doit être placée à une distance maximale de 10 blocs sous le treuil et remplie de pavés, de gravier ou de sable. Une fois le poids minimum d'un stack (99+ articles) atteint et de l'énergie excédentaire disponible, la caisse est automatiquement connectée par une corde au treuil et tirée vers le haut.

[ta2_weight_chest|image]

### TA2 Embrayage / TA2 Clutch

Avec l'embrayage, les axes et les machines peuvent être séparés du stockage d'énergie. Ainsi, les axes après l'embrayage s'arrêtent et les installations de machines peuvent être reconstruites. Lors de la construction de l'embrayage, assurez-vous que la flèche sur le dessus du bloc pointe vers le stockage d'énergie.

[techage:ta2_clutch_off|image]

## Pousser et trier les objets

Pour transporter des objets (items) d'une station de traitement à une autre, des poussoirs et des tubes sont utilisés. Voir le plan.

[itemtransport|plan]

### Tubes / TechAge Tube

Deux machines peuvent être connectées à l'aide d'un poussoir et d'un tube (tube). Les tubes n'ont pas de branches. La longueur maximale est de 200 m (blocs).

Les tubes peuvent également être placés à l'aide de la touche Shift. Cela permet, par exemple, de poser des tubes parallèlement sans qu'ils se connectent accidentellement.

La capacité de transport d'un tube est illimitée et n'est limitée que par les poussoirs.

[tube|image]

### Concentrateur de tubes / Tube Concentrator

Via le concentrateur, plusieurs tubes peuvent être combinés en un seul tube. La direction dans laquelle tous les items sont transmis est marquée par une flèche.

[concentrator|image]

### TA2 Poussoir / Pusher

Un poussoir est capable de tirer des items des coffres ou des machines et de les pousser dans d'autres coffres ou machines. En d'autres termes : entre deux blocs avec inventaire, il doit y avoir un et exactement un poussoir. Plusieurs poussoirs en série ne sont pas possibles.
Dans la direction opposée, un poussoir est cependant perméable aux items, de sorte qu'un coffre peut être rempli via un tube et également vidé.

Un poussoir passe en mode "standby" lorsqu'il n'a pas d'items à pousser. Si la sortie est bloquée ou si l'inventaire du récepteur est plein, le poussoir passe en mode "bloqué". Dans les deux cas, le poussoir sort automatiquement après quelques secondes, à condition que la situation ait changé.

La capacité de traitement d'un poussoir TA2 est de 2 items toutes les 2 s.

[ta2_pusher|image]

### TA2 Distributeur / Distributor

Le distributeur est capable de transporter les items de son inventaire de manière triée dans jusqu'à quatre directions. Pour cela, le distributeur doit être configuré en conséquence.

Le distributeur possède pour cela un menu avec 4 filtres de différentes couleurs, correspondant aux 4 sorties. Si une sortie doit être utilisée, le filtre correspondant doit être activé via la case à cocher "on". Tous les items configurés pour ce filtre sont émis via la sortie associée. Si un filtre est activé sans que des items soient configurés, nous parlons ici d'une sortie "non configurée", ouverte.

**Attention : Le distributeur est simultanément un poussoir à ses sorties. Par conséquent, ne jamais tirer les articles du distributeur avec un poussoir !**

Pour une sortie non configurée, il y a deux modes de fonctionnement :

1) Émettre tous les items qui ne peuvent pas être émis à d'autres sorties, même si celles-ci sont bloquées.

2) N'émettre que les items qui ne sont configurés pour aucun autre filtre.

Dans le premier cas, tous les items sont toujours transmis et le distributeur ne se remplit pas. Dans le deuxième cas, les items sont retenus et le distributeur peut se remplir et, par conséquent, se bloquer.

Le mode de fonctionnement peut être réglé via la case à cocher "bloquer".

La capacité de traitement d'un distributeur TA2 est de 4 items toutes les 2 s, le distributeur essayant de distribuer les 4 items sur les sorties ouvertes.

Si le même item est enregistré plusieurs fois dans un filtre, cela influence le rapport de distribution à long terme en conséquence.

Veuillez noter que la distribution est un processus probabiliste, c'est-à-dire que les rapports ne sont pas respectés exactement, mais seulement à long terme.

Dans les filtres, la taille maximale de la pile est de 12 ; au total, un maximum de 36 items peuvent être configurés.

[ta2_distributor|image]

## Installation de lavage de gravier

L'installation de lavage de gravier est une machine plus complexe visant à laver les pépites d'Usmium du gravier tamisé. Pour la construction, un laveur de gravier TA2 avec entraînement par axe, un entonnoir, une caisse, ainsi que de l'eau courante sont nécessaires.

Construction de gauche à droite (voir aussi le plan) :

* Un bloc de terre, dessus la source d'eau, entouré sur 3 côtés par exemple de blocs de verre
* à côté le laveur de gravier, éventuellement avec des raccords de tube pour le transport de gravier vers et depuis
* puis l'entonnoir avec la caisse

Le tout entouré d'autres blocs de verre, de sorte que l'eau coule sur le laveur de gravier et l'entonnoir et que les pépites lavées puissent être à nouveau collectées par l'entonnoir.

[gravelrinser|plan]

### TA2 Laveur de gravier / Gravel Rinser

Le laveur de gravier est capable de laver les minerais Usmium et cuivre du gravier déjà tamisé, à condition qu'il soit recouvert d'eau.

Pour tester si le laveur de gravier fonctionne correctement, des bâtons (sticks) peuvent être utilisés en les mettant dans l'inventaire du laveur de gravier. Ceux-ci doivent être lavés individuellement et capturés par l'entonnoir.

La capacité de traitement est d'un item de gravier toutes les 2 s. Le laveur de gravier nécessite 3 ku d'énergie.

[ta2_rinser|image]

## Concassage, broyage et tamisage de la pierre

Le concassage, le broyage et le tamisage des roches servent à l'extraction des minerais. Cependant, le gravier tamisé peut également être utilisé autrement. Le concasseur, le moulin et le tamis doivent être entraînés et donc construits à proximité d'une machine à vapeur.

[ta2_grinder|image]

### TA2 Concasseur / Quarry

Le concasseur sert à extraire des pierres et d'autres matériaux du sous-sol. Le concasseur creuse un trou de 5x5 blocs. La profondeur est réglable.
La capacité de traitement est d'un bloc toutes les 4 s. Le concasseur nécessite 10 ku d'énergie. La profondeur maximale est de 20 mètres. Pour des profondeurs plus grandes, voir TA3/TA4.

[ta2_quarry|image]

### TA2 Moulin / Grinder

Le moulin est capable de broyer diverses roches, mais aussi du bois et d'autres items.
La capacité de traitement est d'un item toutes les 4 s. Le moulin nécessite 4 ku d'énergie.

[ta2_grinder|image]

### TA2 Tamis à gravier / Gravel Sieve

Le tamis à gravier est capable de tamiser le gravier pour obtenir des minerais. En résultat, on obtient partiellement du "gravier tamisé", qui ne peut plus être tamisé.
La capacité de traitement est d'un item toutes les 4 s. Le tamis à gravier nécessite 3 ku d'énergie.

[ta2_gravelsieve|image]

## Production d'items

Avec les machines TA2, non seulement des minerais peuvent être obtenus, mais aussi des articles peuvent être fabriqués.

### TA2 Autocrafter

L'Autocrafter sert à la fabrication automatique de marchandises. Tout ce que le joueur peut fabriquer via la "Grille de crafting" peut également être fait par l'Autocrafter. Pour cela, la recette doit être entrée et les ingrédients nécessaires doivent être ajoutés dans le menu de l'Autocrafter.

Les ingrédients et les marchandises fabriquées peuvent être transportés dans et hors du bloc via des tubes et des poussoirs.

La capacité de traitement est d'un item toutes les 4 s. L'Autocrafter nécessite 4 ku d'énergie.

[ta2_autocrafter|image]

### TA2 Usine d'électronique / Electronic Fab

L'usine d'électronique est une machine spéciale et n'est utilisable que pour la fabrication des tubes à vide. Les tubes à vide sont nécessaires pour les machines et blocs TA3.

La capacité de traitement est d'un tube à vide toutes les 6 s. L'usine d'électronique nécessite 8 ku d'énergie.

[ta2_electronicfab|image]

## Autres blocs

### TA2 Collecteur de liquides / Liquid Sampler

Pour certaines recettes, de l'eau est nécessaire. Pour que ces recettes puissent également être traitées de manière automatisée avec l'Autocrafter, de l'eau doit être fournie dans des seaux. Pour cela, le collecteur de liquides est utilisé. Il nécessite des seaux vides et doit être placé dans l'eau.

La capacité de traitement est d'un seau d'eau toutes les 8 s. Le collecteur de liquides nécessite 3 ku d'énergie.

[ta2_liquidsampler|image]

### TA2 Coffre sécurisé / Protected Chest

Le coffre sécurisé ne peut être utilisé que par les joueurs qui peuvent également construire à cet endroit, c'est-à-dire qui possèdent des droits de protection. Il n'a pas d'importance qui place le coffre.

[ta2_chest|image]

### Techage Forceload Block

Minetest divise la carte en ce qu'on appelle des Map-Blocks. Ce sont des cubes avec une longueur d'arête de 16x16x16 blocs. Un tel Map-Block est toujours chargé complètement par le serveur, mais seuls les blocs autour d'un joueur sont chargés (environ 2-3 blocs dans toutes les directions). Dans la direction de vue du joueur, il y a aussi plus de Map-Blocks. Seule cette partie du monde est active et c'est ici que les plantes et les arbres poussent ou que les machines fonctionnent.

Avec un bloc Forceload, vous pouvez forcer le Map-Block dans lequel se trouve le bloc Forceload à toujours rester chargé tant que vous êtes sur le serveur. Si toutes vos fermes et machines sont couvertes par des blocs Forceload, tout est toujours en marche.

Les Map-Blocks avec leurs coordonnées sont prédéfinis, par exemple (0,0,0) à (15,15,15), ou (16,16,16) à (31,31,31).
On peut déplacer un bloc Forceload à l'intérieur d'un Map-Block comme on veut, la position du Map-Block reste inchangée.

[ta2_forceload|image]
