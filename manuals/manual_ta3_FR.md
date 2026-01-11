# TA3 : Âge du Pétrole

À TA3, il est important de remplacer les machines à vapeur par des machines plus puissantes et alimentées par l'électricité.

Pour ce faire, vous devez construire des centrales électriques au charbon et des générateurs. Vous verrez bientôt que vos besoins en électricité ne peuvent être satisfaits qu'avec des centrales électriques alimentées au pétrole. Vous partez donc à la recherche de pétrole. Les derricks de forage et les pompes à pétrole aident à obtenir le pétrole. Les voies ferrées sont utilisées pour transporter le pétrole vers les centrales électriques.

L'âge industriel est à son apogée.

[techage_ta3|image]

## Centrale électrique au charbon / Centrale électrique au pétrole

La centrale électrique au charbon se compose de plusieurs blocs et doit être assemblée comme indiqué dans le plan à droite. Les blocs TA3 boîte à feu de la centrale électrique, TA3 chaudière haut, TA3 chaudière bas, TA3 turbine, TA3 générateur et TA3 réfrigérant sont nécessaires.

La chaudière doit être remplie d'eau. Remplissez jusqu'à 10 seaux d'eau dans la chaudière ou connectez un tuyau liquide au sommet de la chaudière pour alimenter automatiquement en eau via une pompe.
La boîte à feu doit être remplie de charbon ou de charbon de bois.
Lorsque l'eau est chaude, le générateur peut alors être démarré.

Alternativement, la centrale électrique peut être équipée d'un brûleur à pétrole et fonctionner avec du pétrole.
Le pétrole peut être réapprovisionné à l'aide d'une pompe et d'une conduite de pétrole.

La centrale électrique fournit une puissance de 80 ku.

[coalpowerstation|plan]

### TA3 Boîte à feu de la centrale électrique

Partie de la centrale électrique.
La boîte à feu doit être remplie de charbon ou de charbon de bois. Le temps de combustion dépend de la puissance demandée par la centrale électrique. Le charbon brûle pendant 20 s et le charbon de bois pendant 60 s à pleine charge. Correspondamment plus longtemps à charge partielle (50% de charge = double temps).

[ta3_firebox|image]

### TA3 Brûleur à pétrole de la centrale électrique

Partie de la centrale électrique.

Le brûleur à pétrole peut être rempli de pétrole brut, de fioul, de naphta ou d'essence. Le temps de combustion dépend de la puissance demandée par la centrale électrique. À pleine charge, le pétrole brut brûle pendant 15 s, le fioul pendant 20 s, le naphta pendant 22 s et l'essence pendant 25 s.

Correspondamment plus longtemps à charge partielle (50% de charge = double temps).

Le brûleur à pétrole ne peut contenir que 50 unités de carburant. Un réservoir de pétrole supplémentaire et une pompe à pétrole sont donc conseillés.

[ta3_oilbox|image]

### TA3 Chaudiere bas/haut

Partie de la centrale électrique. Doit être remplie d'eau. Si plus d'eau n'est disponible ou si la température descend trop bas, la centrale électrique s'éteint.

La chaudière peut être remplie d'eau de deux manières :
- Manuellement en cliquant sur le haut de la chaudière avec un seau d'eau (jusqu'à 10 seaux)
- Automatiquement via un tuyau liquide connecté au sommet de la chaudière en utilisant une pompe TA3/TA4

La consommation d'eau de la chaudière TA3 est beaucoup plus faible que celle de la machine à vapeur grâce au circuit de vapeur fermé.
Avec la machine à vapeur, une certaine quantité d'eau est perdue sous forme de vapeur à chaque coup de piston.

[ta3_boiler|image]

### TA3 Turbine

La turbine fait partie de la centrale électrique. Elle doit être placée à côté du générateur et connectée à la chaudière et au réfrigérant via des conduites de vapeur, comme indiqué dans le plan.

[ta3_turbine|image]

### TA3 Générateur

Le générateur est utilisé pour produire de l'électricité. Il doit être connecté aux machines via des câbles électriques et des boîtes de jonction.

[ta3_generator|image]

### TA3 Réfrigérant

Utilisé pour refroidir la vapeur chaude de la turbine. Doit être connecté à la chaudière et à la turbine via des conduites de vapeur, comme indiqué dans le plan.

[ta3_cooler|image]

## Courant électrique

Dans TA3 (et TA4), les machines sont alimentées par l'électricité. Pour cela, les machines, les systèmes de stockage et les générateurs doivent être connectés avec des câbles électriques.
TA3 possède 2 types de câbles électriques :

- Câbles isolés (TA Stromkabel) pour le câblage local dans le sol ou dans les bâtiments. Ces câbles peuvent être cachés dans le mur ou dans le sol (peuvent être "enduits" avec la truelle).
- Lignes aériennes (TA Stromleitung) pour le câblage extérieur sur de longues distances. Ces câbles sont protégés et ne peuvent pas être retirés par d'autres joueurs.

Plusieurs consommateurs, systèmes de stockage et générateurs peuvent être utilisés ensemble dans un réseau électrique. Des réseaux peuvent être mis en place avec l'aide des boîtes de jonction.
Si trop peu d'électricité est fournie, les consommateurs s'éteignent.
Dans ce contexte, il est également important de comprendre le fonctionnement des blocs Forceload, car les générateurs, par exemple, ne fournissent de l'électricité que lorsque le bloc de carte correspondant est chargé. Cela peut être forcé avec un bloc Forceload.

Dans TA4, il y a également un câble pour le système solaire.

[ta3_powerswitch|image]

### Importance des systèmes de stockage

Les systèmes de stockage dans le réseau électrique remplissent deux tâches :

- Pour faire face aux pics de demande : Tous les générateurs fournissent toujours exactement la quantité d'électricité nécessaire. Cependant, si des consommateurs sont allumés/éteints ou s'il y a des fluctuations de demande pour d'autres raisons, les consommateurs peuvent tomber en panne pendant un court instant. Pour éviter cela, il doit toujours y avoir au moins un bloc de batterie dans chaque réseau. Celui-ci sert de tampon et compense ces fluctuations dans la plage de secondes.
- Pour stocker l'énergie renouvelable : Le solaire et l'éolien ne sont pas disponibles 24 heures sur 24. Pour que l'alimentation électrique ne tombe pas en panne lorsque aucune électricité n'est produite, un ou plusieurs systèmes de stockage doivent être installés dans le réseau. Alternativement, les lacunes peuvent également être comblées avec l'électricité du pétrole/charbon.

Un système de stockage indique sa capacité en kud, c'est-à-dire ku par jour. Par exemple, un système de stockage de 100 kud fournit 100 ku pendant une journée de jeu, ou 10 ku pendant 10 jours de jeu.

Toutes les sources d'énergie TA3/TA4 ont des caractéristiques de charge réglables. Par défaut, cela est réglé sur "80% - 100%". Cela signifie que lorsque le système de stockage est rempli à 80%, la puissance est réduite de plus en plus jusqu'à ce qu'il s'éteigne complètement à 100%. Si de l'électricité est nécessaire dans le réseau, 100% ne seront jamais atteints, car la puissance du générateur a à un moment donné chuté à la demande d'électricité dans le réseau et le système de stockage n'est plus chargé, mais seulement les consommateurs sont servis.

Cela présente plusieurs avantages :

- Les caractéristiques de charge sont réglables. Cela signifie, par exemple, que les sources d'énergie pétrole/charbon peuvent être réduites à 60% et les sources d'énergie renouvelable seulement à 80%. Cela signifie que le pétrole/charbon n'est brûlé que s'il n'y a pas assez de sources d'énergie renouvelable disponibles.
- Plusieurs sources d'énergie peuvent être utilisées en parallèle et sont chargées de manière presque égale, car toutes les sources d'énergie fonctionnent, par exemple, jusqu'à 80% de la capacité de charge du système de stockage à leur pleine capacité et réduisent ensuite leur capacité en même temps.
- Tous les systèmes de stockage dans un réseau forment un grand tampon. La capacité de charge et le niveau de remplissage de l'ensemble du système de stockage peuvent toujours être lus en pourcentage sur chaque système de stockage, mais aussi sur le terminal électrique.

[power_reduction|image]

### TA Câble électrique

Pour le câblage local dans le sol ou dans les bâtiments.
Les branches peuvent être réalisées à l'aide de boîtes de jonction. La longueur maximale de câble entre les machines ou les boîtes de jonction est de 1000 m. Un maximum de 1000 nœuds peuvent être connectés dans un réseau électrique. Tous les blocs avec une connexion électrique, y compris les boîtes de jonction, comptent comme des nœuds.

Comme les câbles électriques ne sont pas automatiquement protégés, les lignes aériennes (TA Stromleitung) sont recommandées pour les longues distances.

Les câbles électriques peuvent être enduits avec la truelle afin qu'ils puissent être cachés dans le mur ou dans le sol. Tous les blocs de pierre, d'argile et autres blocs sans "intelligence" peuvent être utilisés comme matériau d'enduit. La terre ne fonctionne pas car elle peut être convertie en herbe ou similaire, ce qui détruirait la ligne.

Pour l'enduit, il faut cliquer sur le câble avec la truelle. Le matériau avec lequel le câble doit être enduit doit être tout à gauche dans l'inventaire du joueur.
Les câbles peuvent être rendus à nouveau visibles en cliquant sur le bloc avec la truelle.

En plus des câbles, la boîte de jonction TA et la boîte de commutateur électrique TA peuvent également être enduits.

[ta3_powercable|image]

### TA Boîte de jonction électrique

Avec la boîte de jonction, l'électricité peut être distribuée dans jusqu'à 6 directions. Les boîtes de jonction peuvent également être enduites (cachées) avec une truelle et rendues à nouveau visibles.

[ta3_powerjunction|image]

### TA Ligne électrique

Avec la ligne électrique TA et les poteaux électriques, des lignes aériennes raisonnablement réalistes peuvent être réalisées. Les têtes de poteaux électriques servent également à protéger la ligne électrique (protection). Un poteau doit être placé tous les 16 m ou moins. La protection ne s'applique cependant qu'à la ligne électrique et aux poteaux, tous les autres blocs de cette zone ne sont pas protégés.

[ta3_powerline|image]

### TA Poteau électrique

Utilisé pour construire des poteaux électriques. Est protégé contre la destruction par la tête de poteau électrique et ne peut être retiré que par le propriétaire.

[ta3_powerpole|image]

### TA Tête de poteau électrique

Possède jusqu'à quatre bras et permet ainsi de distribuer l'électricité dans jusqu'à 6 directions.
La tête de poteau électrique protège les lignes électriques et les poteaux dans un rayon de 8 m.

[ta3_powerpole4|image]

### TA Tête de poteau électrique 2

Cette tête de poteau électrique possède deux bras fixes et est utilisée pour les lignes aériennes. Cependant, elle peut également transmettre le courant vers le bas et vers le haut.
La tête de poteau électrique protège les lignes électriques et les poteaux dans un rayon de 8 m.

[ta3_powerpole2|image]

### TA Interrupteur électrique

L'interrupteur peut être utilisé pour allumer et éteindre l'électricité. Pour cela, l'interrupteur doit être placé sur une boîte de commutateur électrique. La boîte de commutateur électrique doit être connectée au câble électrique des deux côtés.

[ta3_powerswitch|image]

### TA Petit interrupteur électrique

L'interrupteur peut être utilisé pour allumer et éteindre l'électricité. Pour cela, l'interrupteur doit être placé sur une boîte de commutateur électrique. La boîte de commutateur électrique doit être connectée au câble électrique des deux côtés.

[ta3_powerswitchsmall|image]

### TA Boîte de commutateur électrique

voir TA interrupteur électrique.

[ta3_powerswitchbox|image]

### TA3 Petit générateur électrique

Le petit générateur électrique fonctionne à l'essence et peut être utilisé pour des petits consommateurs jusqu'à 12 ku. L'essence brûle pendant 150 s à pleine charge. Correspondamment plus longtemps à charge partielle (50% de charge = double temps).

Le générateur électrique ne peut contenir que 50 unités d'essence. Un réservoir supplémentaire et une pompe sont donc conseillés.

[ta3_tinygenerator|image]

### TA3 Bloc accumulateur

Le bloc accumulateur (batterie rechargeable) est utilisé pour stocker l'énergie excédentaire et fournit automatiquement de l'électricité en cas de panne de courant (si disponible).
Plusieurs blocs accumulateurs ensemble forment un système de stockage d'énergie TA3. Chaque bloc accumulateur a un affichage pour l'état de charge et pour la charge stockée.
Les valeurs pour l'ensemble du réseau sont toujours affichées ici. La charge stockée est affichée en "kud" ou "ku-days" (analogue au kWh) 5 kud correspondent ainsi, par exemple, à 5 ku pour une journée de jeu (20 min) ou 1 ku pour 5 jours de jeu.

Un bloc accumulateur a 3,33 kud

[ta3_akkublock|image]

### TA3 Terminal électrique

Le terminal électrique doit être connecté au réseau électrique. Il affiche les données du réseau électrique.

Les chiffres les plus importants sont affichés dans la moitié supérieure :

- puissance actuelle/maximale du générateur
- consommation actuelle de courant de tous les consommateurs
- courant de charge actuel dans/du système de stockage
- État de charge actuel du système de stockage en pourcentage

Le nombre de blocs de réseau est affiché dans la moitié inférieure.

Des données supplémentaires sur les générateurs et les systèmes de stockage peuvent être interrogées via l'onglet "console".

[ta3_powerterminal|image]

### TA3 Moteur électrique

Le moteur électrique TA3 est nécessaire pour pouvoir faire fonctionner les machines TA2 via le réseau électrique. Le moteur électrique TA3 convertit l'électricité en puissance d'axe.
Si le moteur électrique n'est pas alimenté avec suffisamment de courant, il passe en mode d'erreur et doit être réactivé avec un clic droit.

Le moteur électrique prend un maximum de 40 ku d'électricité et fournit de l'autre côté un maximum de 39 ku de puissance d'axe. Il consomme donc un ku pour la conversion.

[ta3_motor|image]

## Four industriel TA3

Le four industriel TA3 sert de complément aux fours normaux. Cela signifie que toutes les marchandises peuvent être produites avec des recettes de "cuisson", même dans un four industriel. Mais il existe également des recettes spéciales qui ne peuvent être réalisées que dans un four industriel.
Le four industriel a son propre menu pour la sélection des recettes. Selon les marchandises dans l'inventaire du four industriel à gauche, le produit de sortie peut être sélectionné à droite.

Le four industriel nécessite de l'électricité (pour le ventilateur) et du fioul / de l'essence pour le brûleur. Le four industriel doit être assemblé comme indiqué dans le plan à droite.

Voir aussi TA4 chauffage.

[ta3_furnace|plan]

### TA3 Brûleur à fioul

Fait partie du four industriel TA3.

Le brûleur à fioul peut fonctionner avec du pétrole brut, du fioul, du naphta ou de l'essence. Le temps de combustion est de 64 s pour le pétrole brut, 80 s pour le fioul, 90 s pour le naphta et 100 s pour l'essence.

Le brûleur à fioul ne peut contenir que 50 unités de carburant. Un réservoir supplémentaire et une pompe sont donc conseillés.

[ta3_furnacefirebox|image]

### TA3 Partie supérieure du four

Fait partie du four industriel TA3. Voir Four industriel TA3.

[ta3_furnace|image]

### TA3 Ventilateur

Fait partie du four industriel TA3. Voir Four industriel TA3.

[ta3_booster|image]

## Liquides

Les liquides tels que l'eau ou le pétrole ne peuvent être pompés que dans des conduites spéciales et stockés dans des réservoirs. Comme pour l'eau, il existe des conteneurs (bidons, fûts) dans lesquels le liquide peut être stocké et transporté.

Il est également possible de connecter plusieurs réservoirs à l'aide des tuyaux jaunes et des connecteurs. Cependant, les réservoirs doivent avoir le même contenu et il doit toujours y avoir au moins un tuyau jaune entre le réservoir, la pompe et le tuyau de distribution.

Par exemple, il n'est pas possible de connecter directement deux réservoirs à un tuyau de distribution.

Le remplisseur de liquide est utilisé pour transférer des liquides des conteneurs aux réservoirs. Le plan montre comment des bidons ou des fûts avec des liquides sont poussés dans un remplisseur de liquide via des poussoirs. Le conteneur est vidé dans le remplisseur de liquide et le liquide est conduit vers le bas dans le réservoir.

Le remplisseur de liquide peut également être placé sous un réservoir pour vider le réservoir.

[ta3_tank|plan]

### TA3 Réservoir

Les liquides peuvent être stockés dans un réservoir. Un réservoir peut être rempli ou vidé à l'aide d'une pompe. Pour cela, la pompe doit être connectée au réservoir via un tuyau (tuyaux jaunes).

Un réservoir peut également être rempli ou vidé manuellement en cliquant sur le réservoir avec un conteneur de liquide plein ou vide (fût, bidon). Il convient de noter que les fûts ne peuvent être remplis ou vidés que complètement. Par exemple, s'il y a moins de 10 unités dans le réservoir, ce reste doit être retiré avec des bidons ou vidé par pompage.

Un réservoir TA3 peut contenir 1000 unités ou 100 fûts de liquide.

[ta3_tank|image]

### TA3 Pompe

La pompe peut être utilisée pour pomper des liquides de réservoirs ou de conteneurs vers d'autres réservoirs ou conteneurs. La direction de la pompe (flèche) doit être observée pour la pompe. Les lignes jaunes et les connecteurs permettent également de disposer plusieurs réservoirs de chaque côté de la pompe. Cependant, les réservoirs doivent avoir le même contenu.

La pompe TA3 pompe 4 unités de liquide toutes les deux secondes.

Remarque 1 : La pompe ne doit pas être placée directement à côté du réservoir. Il doit toujours y avoir au moins un morceau de tuyau jaune entre eux.

[ta3_pump|image]

### TA Remplisseur de liquide

Le remplisseur de liquide est utilisé pour transférer des liquides entre des conteneurs et des réservoirs.

- Si le remplisseur de liquide est placé sous un réservoir et que des fûts vides sont mis dans le remplisseur de liquide avec un poussoir ou à la main, le contenu du réservoir est transféré dans les fûts et les fûts peuvent être retirés du côté de la sortie
- Si le remplisseur de liquide est placé sur un réservoir et que des conteneurs pleins sont mis dans le remplisseur de liquide avec un poussoir ou à la main, le contenu est transféré dans le réservoir et les conteneurs vides peuvent être retirés du côté de la sortie

Il convient de noter que les fûts ne peuvent être remplis ou vidés que complètement. Par exemple, s'il y a moins de 10 unités dans le réservoir, ce reste doit être retiré avec des bidons ou vidé par pompage.

[ta3_filler|image]

### TA4 Tuyau

Les tuyaux jaunes sont utilisés pour la transmission de gaz et de liquides.
La longueur maximale du tuyau est de 100 m.

[ta3_pipe|image]

### TA3 Blocs d'entrée de tuyau dans le mur

Les blocs servent de passages de mur pour les tuyaux, de sorte qu'aucun trou ne reste ouvert.

[ta3_pipe_wall_entry|image]

### TA Vanne

Il y a une vanne pour les tuyaux jaunes, qui peut être ouverte et fermée avec un clic de souris.
La vanne peut également être contrôlée via des commandes on/off.

[ta3_valve|image]

## Production de pétrole

Pour faire fonctionner vos générateurs et vos poêles avec du pétrole, vous devez d'abord chercher du pétrole et construire un derrick, puis extraire le pétrole.
Pour cela, vous utilisez le TA3 Oil Explorer, le TA3 Oil Drill Box et le TA3 Pump Jack.

[techage_ta3|image]

### TA3 Oil Explorer

Vous pouvez rechercher du pétrole avec l'explorateur de pétrole. Pour cela, placez le bloc sur le sol et cliquez avec le bouton droit pour démarrer la recherche. L'explorateur de pétrole peut être utilisé en surface et en sous-sol à toutes les profondeurs.
La sortie du chat vous montre la profondeur à laquelle le pétrole a été recherché et la quantité de pétrole (pétrole) trouvée.
Vous pouvez cliquer plusieurs fois sur le bloc pour rechercher du pétrole dans des zones plus profondes. Les champs pétrolifères ont une taille de 4 000 à 20 000 unités.

Si la recherche a été infructueuse, vous devez déplacer le bloc d'environ 16 m plus loin.
L'explorateur de pétrole recherche toujours du pétrole dans tout le bloc de carte et en dessous, où il a été placé. Une nouvelle recherche dans le même bloc de carte (champ de 16x16) n'a donc aucun sens.

Si du pétrole est trouvé, l'emplacement pour le derrick est affiché. Vous devez ériger le derrick dans la zone indiquée, il est préférable de marquer l'emplacement avec un panneau et de protéger toute la zone contre les autres joueurs.

Ne renoncez pas trop vite à la recherche de pétrole. Si vous avez de la malchance, cela peut prendre beaucoup de temps pour trouver un puits de pétrole.
Il est également inutile de rechercher une zone qu'un autre joueur a déjà explorée. La chance de trouver du pétrole quelque part est la même pour tous les joueurs.

L'explorateur de pétrole peut toujours être utilisé pour rechercher du pétrole.

[ta3_oilexplorer|image]

### TA3 Oil Drill Box

La boîte de forage pétrolier doit être placée à l'endroit indiqué par l'explorateur de pétrole. Forer pour du pétrole ailleurs est inutile.
Si le bouton de la boîte de forage pétrolier est cliqué, le derrick est érigé au-dessus de la boîte. Cela prend quelques secondes.
La boîte de forage pétrolier a 4 côtés, à l'entrée, le train de tiges de forage doit être livré via un poussoir et à la sortie, le matériau de forage doit être retiré. La boîte de forage pétrolier doit être alimentée en électricité via l'un des deux autres côtés.

La boîte de forage pétrolier fore jusqu'au champ pétrolifère (1 mètre en 16 s) et nécessite 16 ku d'électricité.
Une fois le champ pétrolifère atteint, le derrick peut être démonté et la boîte retirée.

[ta3_drillbox|image]

### TA3 Oil Pumpjack

La pompe à pétrole (pump-jack) doit maintenant être placée à la place de la boîte de forage pétrolier. La pompe à pétrole nécessite également de l'électricité (16 ku) et fournit une unité de pétrole toutes les 8 s. Le pétrole doit être collecté dans un réservoir. Pour cela, la pompe à pétrole doit être connectée au réservoir via des tuyaux jaunes.
Une fois tout le pétrole pompé, la pompe à pétrole peut également être retirée.

[ta3_pumpjack|image]

### TA3 Drill Pipe

Le train de tiges de forage est nécessaire pour le forage. Autant d'articles de train de tiges de forage sont nécessaires que la profondeur spécifiée pour le champ pétrolifère. Le train de tiges de forage est inutile après le forage, mais il ne peut pas non plus être démonté et reste dans le sol. Cependant, il existe un outil pour retirer les blocs de train de tiges de forage (-> Outils -> Pince pour train de tiges de forage TA3).

[ta3_drillbit|image]

### Réservoir de pétrole

Le réservoir de pétrole est la grande version du réservoir TA3 (voir liquides -> Réservoir TA3).

Le grand réservoir peut contenir 4000 unités de pétrole, mais aussi tout autre type de liquide.

[oiltank|image]

## Transport de pétrole

### Transport de pétrole par wagons-citernes

Des wagons-citernes peuvent être utilisés pour transporter le pétrole du puits de pétrole à l'usine de traitement du pétrole. Un wagon-citerne peut être rempli ou vidé directement à l'aide de pompes. Dans les deux cas, les tuyaux jaunes doivent être connectés au wagon-citerne par le haut.

Les étapes suivantes sont nécessaires :

- Placer le wagon-citerne devant le bloc de butoir de rail. Le bloc de butoir ne doit pas encore être programmé avec un temps afin que le wagon-citerne ne démarre pas automatiquement
- Connecter le wagon-citerne à la pompe à l'aide de tuyaux jaunes
- Allumer la pompe
- Programmer le butoir avec un temps (10 - 20 s)

Cette séquence doit être respectée des deux côtés (remplissage / vidange).

[tank_cart | image]

### Transport de pétrole avec des fûts via des Minecarts

Des bidons et des fûts peuvent être chargés dans les Minecarts. Pour cela, le pétrole doit d'abord être transvasé dans des fûts. Les fûts de pétrole peuvent être poussés directement dans le Minecart avec un poussoir et des tubes (voir plan). Les fûts vides, qui reviennent de la station de déchargement par Minecart, peuvent être déchargés à l'aide d'un entonnoir, qui est placé sous le rail à l'arrêt.

Il n'est pas possible avec l'entonnoir de **décharger les fûts vides et de charger les fûts pleins à un arrêt**. L'entonnoir décharge immédiatement les fûts pleins. Il est donc conseillé de configurer 2 stations du côté du chargement et du déchargement et de programmer le Minecart en conséquence à l'aide d'un trajet d'enregistrement.

Le plan montre comment le pétrole peut être pompé dans un réservoir et rempli dans des fûts via un remplisseur de liquide et chargé dans des Minecarts.

Pour que les Minecarts redémarrent automatiquement, les blocs de butoir doivent être configurés avec le nom de la station et le temps d'attente. 5 s suffisent pour le déchargement. Cependant, comme les poussoirs passent toujours en mode veille pendant plusieurs secondes lorsqu'il n'y a pas de Minecart, un temps de 15 s ou plus doit être saisi pour le chargement.

[ta3_loading|plan]

### Wagon-citerne

Le wagon-citerne est utilisé pour transporter des liquides. Comme les réservoirs, il peut être rempli avec des pompes ou vidé. Dans les deux cas, le tube jaune doit être connecté au wagon-citerne par le haut.

200 unités tiennent dans le wagon-citerne.

[tank_cart | image]

### Wagon à caisses

Le wagon à caisses est utilisé pour transporter des objets. Comme les caisses, il peut être rempli ou vidé à l'aide d'un poussoir.

4 piles tiennent dans le wagon à caisses.

[chest_cart | image]

## Traitement du pétrole

Le pétrole est un mélange de substances et se compose de nombreux composants. Le pétrole peut être décomposé en ses principaux composants tels que le bitume, le fioul, le naphta, l'essence et le gaz propane via une tour de distillation.
Le traitement ultérieur en produits finis se fait dans le réacteur chimique.

[techage_ta31|image]

### Tour de distillation

La tour de distillation doit être installée comme indiqué dans le plan en haut à droite.
Le bitume est drainé via le bloc de base. La sortie est sur l'arrière du bloc de base (notez la direction de la flèche).
Les blocs "tour de distillation" avec les numéros : 1, 2, 3, 2, 3, 2, 3, 4 sont placés sur ce bloc de base
Le fioul, le naphta et l'essence sont drainés des ouvertures de bas en haut. Le gaz propane est capturé en haut.
Toutes les ouvertures de la tour doivent être connectées à des réservoirs.
Le réchauffeur doit être connecté au bloc "tour de distillation 1".

Le réchauffeur a besoin d'électricité (non montré dans le plan) !

[ta3_distiller|plan]

#### Réchauffeur

Le réchauffeur chauffe le pétrole à environ 400 °C. Il s'évapore en grande partie et est conduit dans la tour de distillation pour refroidissement.

Le réchauffeur nécessite 14 unités d'électricité et produit une unité de bitume, de fioul, de naphta, d'essence et de propane toutes les 16 s.
Pour cela, le réchauffeur doit être alimenté en pétrole via une pompe.

[reboiler|image]

## Blocs logiques/commutateurs

En plus des tubes pour le transport de marchandises, ainsi que des conduites de gaz et d'électricité, il existe également un niveau de communication sans fil via lequel les blocs peuvent échanger des données entre eux. Aucune ligne ne doit être tracée pour cela, la connexion entre l'émetteur et le récepteur est uniquement établie via le numéro de bloc.

**Info :** Un **numéro de bloc** est un nombre unique généré par Techage lors du placement de nombreux blocs Techage. Le numéro de bloc est utilisé pour l'adressage lors de la communication entre les contrôleurs Techage et les machines. Tous les blocs qui peuvent participer à cette communication affichent le numéro de bloc comme texte d'information si vous fixez le bloc avec le curseur de la souris.

Les commandes qu'un bloc prend en charge peuvent être lues et affichées avec l'outil d'information TechAge (clé à molette).
Les commandes les plus simples, prises en charge par presque tous les blocs, sont :

- `on` - pour allumer le bloc/machine/lampe
- `off` - pour éteindre le bloc/machine/lampe

Avec l'aide du terminal TA3, ces commandes peuvent être essayées très facilement. Supposons qu'une lampe de signalisation soit le numéro 123.
Alors avec :

    cmd 123 on

la lampe peut être allumée et avec :

    cmd 123 off

la lampe peut être éteinte à nouveau. Ces commandes doivent être saisies dans le champ de saisie du terminal TA3.

Des commandes comme `on` et `off` sont envoyées au destinataire sans qu'une réponse ne revienne. Ces commandes peuvent donc être envoyées à plusieurs destinataires en même temps, par exemple avec un bouton-poussoir/interrupteur, si plusieurs numéros sont saisis dans le champ de saisie.

Une commande comme `state` demande l'état d'un bloc. Le bloc envoie ensuite son état en retour. Ce type de commande confirmée ne peut être envoyé qu'à un seul destinataire à la fois.
Cette commande peut également être testée avec le terminal TA3 sur un poussoir, par exemple :

    cmd 123 state

Les réponses possibles du poussoir sont :
- `running` -> je travaille
- `stopped` -> éteint
- `standby` -> rien à faire car l'inventaire source est vide
- `blocked` -> je ne peux rien faire car l'inventaire cible est plein

Cet état et d'autres informations sont également affichés lorsque l'on clique sur le bloc avec la clé à molette.

[ta3_logic|image]

### TA3 Bouton/Interrupteur

Le bouton/interrupteur envoie des commandes `on`/`off` aux blocs qui ont été configurés via les numéros.
Le bouton/interrupteur peut être configuré comme un bouton ou un interrupteur. S'il est configuré comme un bouton, le temps entre les commandes `on` et `off` peut être réglé. Avec le mode de fonctionnement "on button", seule une commande `on` et aucune commande `off` n'est envoyée.

Via la case à cocher "public", il peut être réglé si le bouton peut être utilisé par tout le monde (coché) ou seulement par le propriétaire lui-même (non coché).

Remarque : Avec le programmeur, les numéros de bloc peuvent être facilement collectés et configurés.

[ta3_button|image]

### TA3 Convertisseur de commandes

Avec le convertisseur de commandes TA3, les commandes `on` / `off` peuvent être converties en d'autres commandes, et la transmission peut être empêchée ou retardée.
Le numéro du bloc cible ou les numéros des blocs cibles, les commandes à envoyer et les temps de retard en secondes doivent être saisis. Si aucune commande n'est saisie, rien n'est envoyé.

Les numéros peuvent également être programmés à l'aide du programmeur Techage.

[ta3_command_converter|image]

### TA3 Flip-Flop

Le flip-flop TA3 change d'état avec chaque commande `on` reçue. Les commandes `off` reçues sont ignorées. Ainsi, en fonction du changement d'état, des commandes `on` / `off` sont envoyées en alternance. Le numéro du bloc cible ou les numéros des blocs cibles doivent être saisis. Les numéros peuvent également être programmés à l'aide du programmeur Techage.

Par exemple, des lampes peuvent être allumées et éteintes à l'aide de boutons.

[ta3_flipflop|image]

### TA3 Bloc logique

Le bloc logique TA3 peut être programmé de sorte qu'une ou plusieurs commandes d'entrée soient liées à une commande de sortie et envoyées. Ce bloc peut donc remplacer divers éléments logiques tels que AND, OR, NOT, XOR, etc.
Les commandes d'entrée pour le bloc logique sont des commandes `on` / `off`.
Les commandes d'entrée sont référencées via le numéro, par exemple `1234` pour la commande de l'émetteur avec le numéro 1234.
La même chose s'applique aux commandes de sortie.

Une règle est structurée comme suit :

```
<output> = on/off if <input-expression> is true
```

`<output>` est le numéro du bloc auquel la commande doit être envoyée.
`<input-expression>` est une expression booléenne où les numéros d'entrée sont évalués.

**Exemples pour l'expression d'entrée**

Signal négatif (NOT) :

    1234 == off

ET logique (AND) :

    1234 == on and 2345 == on

OU logique (OR) :

    1234 == on or 2345 == on

Les opérateurs suivants sont autorisés : `and` `or` `on` `off` `me` `==` `~=` `(` `)`

Si l'expression est vraie, une commande est envoyée au bloc avec le numéro `<output>`.
Jusqu'à quatre règles peuvent être définies, toutes les règles étant toujours vérifiées lorsqu'une commande est reçue.
Le temps de traitement interne de toutes les commandes est de 100 ms.

Via le mot-clé `me`, le propre numéro de nœud peut être référencé. Cela permet au bloc de s'envoyer une commande à lui-même (fonction flip-flop).

Le temps de blocage définit une pause après une commande, pendant laquelle le bloc logique n'accepte plus de commandes externes. Les commandes reçues pendant le temps de blocage sont ainsi rejetées. Le temps de blocage peut être défini en secondes.

[ta3_logic|image]

### TA3 Répéteur

Le répéteur envoie le signal reçu à tous les numéros configurés.
Cela peut être utile, par exemple, si vous souhaitez contrôler de nombreux blocs en même temps. Le répéteur peut être configuré avec le programmeur, ce qui n'est pas possible avec tous les blocs.

[ta3_repeater|image]

### TA3 Séquenceur

Le séquenceur peut envoyer une série de commandes `on` / `off`, le délai entre les commandes devant être spécifié en secondes. Vous pouvez, par exemple, faire clignoter une lampe.
Jusqu'à 8 commandes peuvent être configurées, chacune avec le numéro du bloc cible et le délai avant la commande suivante.
Le séquenceur répète les commandes sans fin lorsque "Run endless" est activé.
Si rien n'est sélectionné, seul le temps spécifié en secondes est attendu.

[ta3_sequencer|image]

### TA3 Minuterie

La minuterie peut envoyer des commandes de manière contrôlée par le temps. L'heure, le(s) numéro(s) de cible et la commande elle-même peuvent être spécifiés pour chaque ligne de commande. Cela permet d'allumer les lampes le soir et de les éteindre à nouveau le matin.

[ta3_timer|image]

### TA3 Terminal

Le terminal sert principalement à tester l'interface de commande d'autres blocs (voir "Blocs logiques/commutateurs"), ainsi qu'à l'automatisation des systèmes à l'aide du langage de programmation BASIC.
Vous pouvez également attribuer des commandes à des touches et utiliser le terminal de manière productive.

    set <button-num> <button-text> <command>

Avec `set 1 ON cmd 123 on`, par exemple, la touche utilisateur 1 peut être programmée avec la commande `cmd 123 on`. Si la touche est pressée, la commande est envoyée et la réponse est affichée à l'écran.

Le terminal possède les commandes locales suivantes :
- `clear` effacer l'écran
- `help` afficher une page d'aide
- `pub` passer en mode public
- `priv` passer en mode privé

En mode privé, le terminal ne peut être utilisé que par les joueurs qui peuvent construire à cet endroit, c'est-à-dire qui possèdent des droits de protection.
En mode public, tous les joueurs peuvent utiliser les touches préconfigurées.

Vous pouvez passer en mode BASIC à l'aide du menu de la clé à molette. Vous pouvez trouver plus d'informations sur le mode BASIC [ici](https://github.com/joe7575/techage/tree/master/manuals/ta3_terminal.md)

[ta3_terminal|image]

### Lampe colorée TechAge

La lampe de signalisation peut être allumée ou éteinte avec la commande `on` / `off`. Cette lampe n'a pas besoin d'électricité et peut être colorée avec l'outil de peinture de la mod "Unified Dyes" et via des commandes Lua/Beduino.

Avec la commande de chat `/ta_color`, la palette de couleurs avec les valeurs pour les commandes Lua/Beduino est affichée et avec `/ta_send color <num>`, la couleur peut être changée.

[ta3_colorlamp|image]

### Blocs de porte/portail

Avec ces blocs, vous pouvez réaliser des portes et des portails qui peuvent être ouverts (les blocs disparaissent) et refermés via des commandes. Un contrôleur de porte est nécessaire pour chaque porte ou portail.

L'apparence des blocs peut être ajustée via le menu du bloc.
Cela permet de réaliser des portes secrètes qui ne s'ouvrent que pour certains joueurs (avec l'aide du détecteur de joueurs).

[ta3_doorblock|image]

### TA3 Contrôleur de porte

Le contrôleur de porte sert à commander les blocs de porte/portail TA3. Avec le contrôleur de porte, les numéros des blocs de porte/portail doivent être saisis. Si une commande `on` / `off` est envoyée au contrôleur de porte, celui-ci ouvre/ferme la porte ou le portail.

[ta3_doorcontroller|image]

### TA3 Contrôleur de porte II

Le contrôleur de porte II peut retirer et replacer tous les types de blocs. Pour enseigner le contrôleur de porte II, le bouton "Enregistrer" doit être pressé. Ensuite, tous les blocs qui doivent faire partie de la porte/du portail doivent être cliqués. Ensuite, le bouton "Terminé" doit être pressé. Jusqu'à 16 blocs peuvent être sélectionnés. Les blocs retirés sont sauvegardés dans l'inventaire du contrôleur. La fonction du contrôleur peut être testée manuellement à l'aide du bouton "Échanger". Si une commande `on` / `off` est envoyée au contrôleur de porte II, il retire ou replace également les blocs.

Avec `$send_cmnd(node_number, "exchange", 2)`, des blocs individuels peuvent être placés, retirés ou remplacés par d'autres blocs de l'inventaire.

Avec `$send_cmnd(node_number, "set", 2)`, un bloc de l'inventaire peut être explicitement placé, à condition que l'emplacement de l'inventaire ne soit pas vide.

Avec `$send_cmnd(node_number, "dig", 2)`, un bloc peut être à nouveau retiré, à condition que l'emplacement de l'inventaire soit vide.

Avec `$send_cmnd(node_number, "get", 2)`, le nom du bloc placé est renvoyé.

Le numéro de l'emplacement de l'inventaire (1 .. 16) doit être transmis comme charge utile dans les trois cas.

Avec `$send_cmnd(node_number, "reset")`, le contrôleur de porte est réinitialisé.

Cela permet également de simuler des escaliers escamotables et similaires.

[ta3_doorcontroller|image]

### TA3 Bloc sonore

Différents sons peuvent être joués avec le bloc sonore. Tous les sons des mods Techage, Signs Bot, Hyperloop, Unified Inventory, TA4 Jetpack et Minetest Game sont disponibles.

Les sons peuvent être sélectionnés et joués via le menu et via une commande.

- Commande `on` pour jouer un son
- Commande `sound <idx>` pour sélectionner un son via l'index
- Commande `gain <volume>` pour ajuster le volume via la valeur `<volume>` (1 à 5).

[ta3_soundblock|image]

### TA3 Convertisseur Mesecons

Le convertisseur Mesecons sert à convertir les commandes on/off de Techage en signaux Mesecons et vice versa.
Pour cela, un ou plusieurs numéros de nœud doivent être saisis et le convertisseur doit être connecté à des blocs Mesecons via des câbles Mesecons. Le convertisseur Mesecons peut également être configuré avec le programmeur.
Le convertisseur Mesecons accepte jusqu'à 5 commandes par seconde ; il s'éteint à des charges plus élevées.

**Ce nœud n'existe que si le mod mesecons est actif !**

[ta3_mesecons_converter|image]

## Détecteurs

Les détecteurs scannent leur environnement et envoient une commande `on` lorsque la recherche est reconnue.

[ta3_nodedetector|image]

### TA3 Détecteur d'objets

Le détecteur est un bloc de tube spécial qui détecte lorsque des objets sont transmis via le tube. Pour cela, il doit être connecté aux tubes des deux côtés. Si des objets sont poussés dans le détecteur avec un poussoir, ils sont automatiquement transmis.
Il envoie un `on` lorsqu'un objet est reconnu, suivi d'un `off` une seconde plus tard.
Ensuite, d'autres commandes sont bloquées pendant 8 secondes.
Le temps d'attente et les objets qui doivent déclencher une commande peuvent être configurés à l'aide du menu de la clé à molette.

[ta3_detector|image]

### TA3 Détecteur de wagon

Le détecteur de wagon envoie une commande `on` s'il a reconnu un wagon (Minecart) directement devant lui. De plus, le détecteur peut également redémarrer le wagon lorsqu'une commande `on` est reçue.

Le détecteur peut également être programmé avec son propre numéro. Dans ce cas, il pousse tous les wagons qui s'arrêtent à proximité (un bloc dans toutes les directions).

[ta3_cartdetector|image]

### TA3 Détecteur de nœuds

Le détecteur de nœuds envoie une commande `on` s'il détecte que des nœuds (blocs) apparaissent ou disparaissent devant lui, mais doit être configuré en conséquence. Après avoir remis le détecteur dans l'état standard (bloc gris), une commande `off` est envoyée. Les blocs valides sont tous les types de blocs et de plantes, mais pas les animaux ou les joueurs. La portée du capteur est de 3 blocs/mètres dans la direction de la flèche.

[ta3_nodedetector|image]

### TA3 Détecteur de joueurs

Le détecteur de joueurs envoie une commande `on` s'il détecte un joueur dans un rayon de 4 m autour du bloc. Si le joueur quitte à nouveau la zone, une commande `off` est envoyée.
Si la recherche doit être limitée à certains joueurs, ces noms de joueurs peuvent également être saisis.

[ta3_playerdetector|image]

### TA3 Détecteur de lumière

Le détecteur de lumière envoie une commande `on` si le niveau de lumière du bloc au-dessus dépasse un certain niveau, qui peut être réglé via le menu de clic droit.
Si vous avez un contrôleur Lua TA4, vous pouvez obtenir le niveau de lumière exact avec $get_cmd(num, 'light_level')

[ta3_lightdetector|image]

## Machines TA3

TA3 possède les mêmes machines que TA2, mais elles sont ici plus puissantes et nécessitent de l'électricité au lieu d'un entraînement par axe.
Par conséquent, seules les différentes données techniques sont indiquées ci-dessous.

[ta3_grinder|image]

### TA3 Poussoir

La fonction correspond à celle de TA2.
La capacité de traitement est de 6 objets toutes les 2 s.

[ta3_pusher|image]

### TA3 Distributeur

La fonction du distributeur TA3 correspond à celle de TA2.
La capacité de traitement est de 12 objets toutes les 4 s.

[ta3_distributor|image]

### TA3 Autocrafter

La fonction correspond à celle de TA2.
La capacité de traitement est de 2 objets toutes les 4 s. L'autocrafter nécessite 6 ku d'électricité.

[ta3_autocrafter|image]

### TA3 Usine d'électronique

La fonction correspond à celle de TA2, mais ici des puces WLAN TA4 sont produites.
La capacité de traitement est d'une puce toutes les 6 s. Le bloc nécessite 12 ku d'électricité pour cela.

[ta3_electronicfab|image]

### TA3 Concasseur

La fonction correspond à celle de TA2.
La profondeur maximale est de 40 mètres. Le concasseur nécessite 12 ku d'électricité.

[ta3_quarry|image]

### TA3 Tamis à gravier

La fonction correspond à celle de TA2.
La capacité de traitement est de 2 objets toutes les 4 s. Le bloc nécessite 4 ku d'électricité.

[ta3_gravelsieve|image]

### TA3 Laveur de gravier

La fonction correspond à celle de TA2.
La probabilité est également la même que pour TA2. Le bloc nécessite également 3 ku d'électricité.
Mais contrairement à TA2, l'état du bloc TA3 peut être lu (contrôleur)

[ta3_gravelrinser|image]

### TA3 Moulin

La fonction correspond à celle de TA2.
La capacité de traitement est de 2 objets toutes les 4 s. Le bloc nécessite 6 ku d'électricité.

[ta3_grinder|image]

### TA3 Injecteur

L'injecteur est un poussoir TA3 avec des propriétés spéciales. Il possède un menu pour la configuration. Jusqu'à 8 objets peuvent être configurés ici. Il ne prend que ces objets d'une caisse pour les transmettre à des machines avec des recettes (autocrafter, four industriel et usine d'électronique).

Lors de la transmission, une seule position dans l'inventaire est utilisée dans la machine cible. Par exemple, si seules les trois premières entrées sont configurées dans l'injecteur, seules les trois premières places de stockage dans l'inventaire de la machine sont utilisées. Ainsi, un débordement dans l'inventaire de la machine est évité.

L'injecteur peut également être commuté en "mode de traction". Il ne tire alors que les objets des positions de la caisse qui sont définies dans la configuration de l'injecteur. Dans ce cas, le type d'objet et la position doivent correspondre. Cela permet de vider des entrées d'inventaire spécifiques d'une caisse.

La capacité de traitement est jusqu'à 8 fois un objet toutes les 4 secondes.

[ta3_injector|image]

## Outils

### Outil d'information Techage

L'outil d'information Techage (clé à molette) a plusieurs fonctions. Il affiche l'heure, la position, la température et le biome lorsqu'un bloc inconnu est cliqué.
Si vous cliquez sur un bloc TechAge avec une interface de commande, toutes les données disponibles seront affichées (voir aussi "Blocs logiques/commutateurs").

Avec Maj + clic droit, un menu étendu peut être ouvert pour certains blocs. Selon le bloc, d'autres données peuvent être appelées ou des réglages spéciaux peuvent être effectués ici. Dans le cas d'un générateur, par exemple, la courbe de charge/arrêt peut être programmée.

[ta3_end_wrench|image]

### Programmeur TechAge

Avec le programmeur, les numéros de bloc peuvent être collectés avec un clic droit de plusieurs blocs et écrits dans un bloc comme un bouton/interrupteur avec un clic gauche.
Si vous cliquez dans l'air, la mémoire interne est effacée.

[ta3_programmer|image]

### Truelle TechAge / Truelle

La truelle est utilisée pour enduire les câbles électriques. Voir aussi "TA câble électrique".

[ta3_trowel|image]

### Pince pour train de tiges de forage TA3

Cet outil peut être utilisé pour retirer les blocs de train de tiges de forage si, par exemple, un tunnel doit y passer.

[ta3_drill_pipe_wrench|image]

### Tournevis Techage

Le tournevis Techage sert de remplacement au tournevis normal. Il a les fonctions suivantes :

- Clic gauche : tourner le bloc vers la gauche
- Clic droit : tourner le côté visible du bloc vers le haut
- Maj + clic gauche : sauvegarder l'alignement du bloc cliqué
- Maj + clic droit : appliquer l'alignement sauvegardé au bloc cliqué

[ta3_screwdriver|image]

### Outil d'assemblage TechAge

L'outil d'assemblage TechAge est utilisé pour retirer et repositionner les blocs TechAge sans que ces blocs ne perdent leur numéro de bloc ou ne reçoivent un nouveau numéro lors du placement. Cela est utile, par exemple, pour les carrières, car elles doivent souvent être déplacées.

- Bouton gauche : Retirer un bloc
- Bouton droit : Placer un bloc

Le bloc qui a été précédemment retiré avec l'outil d'assemblage et qui doit être replacé doit être tout à gauche de l'inventaire du joueur.

[techage:assembly_tool|image]
