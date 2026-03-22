# TA5 : Futur

Les machines pour surmonter l'espace et le temps, de nouvelles sources d'énergie et d'autres réalisations façonnent votre vie.

Pour la fabrication et l'utilisation des machines et blocs TA5, des points d'expérience (experience points) sont nécessaires. Ceux-ci ne peuvent être obtenus que via l'accélérateur de particules de TA4.

[techage_ta5|image]

## Sources d'énergie

### TA5 Réacteur à fusion

La fusion nucléaire signifie la fusion de deux noyaux atomiques. Selon la réaction, de grandes quantités d'énergie peuvent être libérées. Les fusions nucléaires, qui libèrent de l'énergie, se déroulent sous forme de réactions en chaîne. Elles sont la source d'énergie des étoiles, y compris notre soleil. Un réacteur à fusion convertit l'énergie libérée lors d'une fusion nucléaire contrôlée en électricité.

**Comment fonctionne un réacteur à fusion ?**

Un réacteur à fusion fonctionne selon le principe classique d'une centrale thermique : l'eau est chauffée et entraîne une turbine à vapeur, dont l'énergie de mouvement est convertie en électricité par un générateur.

Une centrale de fusion nucléaire nécessite d'abord une grande quantité d'énergie, car un plasma doit être généré. On appelle "plasma" le quatrième état de la matière, après solide, liquide et gazeux. Pour cela, beaucoup d'électricité est nécessaire. Ce n'est que par cette concentration extrême d'énergie que la réaction de fusion s'amorce et, avec la chaleur dégagée, de l'électricité est produite via l'échangeur de chaleur. Le générateur fournit alors 800 ku d'électricité.

Le plan de droite montre une coupe à travers le réacteur à fusion.

Pour le fonctionnement du réacteur à fusion, 60 points d'expérience sont nécessaires. Le réacteur à fusion doit être entièrement construit dans une zone de bloc Forceload.

[ta5_fusion_reactor|plan]

#### TA5 Aimant du réacteur à fusion

Pour la construction du réacteur à fusion, 60 aimants TA5 Fusionreaktor sont nécessaires au total. Ceux-ci forment l'anneau dans lequel le plasma se forme. L'aimant TA5 Fusionreaktor nécessite de l'électricité et a deux connexions pour le refroidissement.

Il existe deux types d'aimants, de sorte que tous les côtés de l'aimant qui font face à l'anneau de plasma peuvent également être protégés par un bouclier thermique.

Pour les aimants d'angle à l'intérieur de l'anneau, un côté de connexion est respectivement couvert (électricité ou refroidissement) et ne peut donc pas être connecté. Cela n'est pas techniquement réalisable et n'a donc aucune influence sur la fonction du réacteur à fusion.

[ta5_magnet|image]

#### TA5 Pompe

La pompe est nécessaire pour remplir le circuit de refroidissement avec de l'isobutane. Environ 350 unités d'isobutane sont nécessaires.

La pompe a deux côtés de connexion :

- Côté gauche : connecteur jaune (GasPipe) – connecter le réservoir d'isobutane ici
- Côté droit : connecteur bleu (LiquidPipe) – connecter le circuit de refroidissement ici

Par défaut, la pompe déplace le liquide de gauche (jaune) vers la droite (bleu), c'est-à-dire du réservoir vers le circuit de refroidissement. La direction de la pompe peut être changée en « reverse » via le menu clé.

Remarque : La pompe TA5 ne peut être utilisée que pour remplir le circuit de refroidissement, il n'est pas possible de pomper le liquide de refroidissement. Par conséquent, la pompe ne doit être allumée que lorsque les aimants sont correctement placés et que tous les câbles électriques et les conduites de refroidissement sont connectés.

Si la pompe affiche « blocked », la destination est pleine ou non connectée.

[ta5_pump|image]

#### TA5 Échangeur de chaleur

L'échangeur de chaleur TA5 est nécessaire pour convertir d'abord la chaleur générée dans le réacteur à fusion en vapeur, puis en électricité. L'échangeur de chaleur lui-même nécessite 5 ku d'électricité. La construction est similaire à l'échangeur de chaleur du stockage d'énergie de TA4.

L'échangeur de chaleur se compose de 3 parties (de bas en haut : 1, 2, 3). Les parties 1 et 3 ont chacune deux côtés de connexion :

- Côté droit : connecteur jaune – connexion à la turbine (partie 1) ou au refroidisseur (partie 3)
- Côté gauche de la partie 1 : connecteur bleu – circuit de refroidissement vers l'anneau inférieur d'aimants (56 aimants)
- Côté gauche de la partie 3 : connecteur vert – circuit de refroidissement vers l'anneau supérieur (52 aimants)

Via le bouton de démarrage de l'échangeur de chaleur (partie 2), le circuit de refroidissement peut être vérifié pour son intégralité, même si aucun liquide de refroidissement n'a encore été rempli. Messages d'erreur possibles :

- "Turbine error" / "Cooler error" : Turbine ou refroidisseur non connecté via tuyau jaune
- "Blue/Green pipe connection error" : Aimants non correctement connectés via tuyaux bleus/verts
- "Blue/Green pipe coolant missing" : Aimants pas encore remplis d'isobutane (6 unités par aimant)

[ta5_heatexchanger|plan]

#### TA5 Contrôleur du réacteur à fusion

Via le contrôleur TA5 Fusionreaktor, le réacteur à fusion est allumé. Le réacteur à fusion et donc le contrôleur nécessite 400 ku d'électricité pour maintenir le plasma.

**Séquence de démarrage :**

1. Tous les aimants doivent être correctement placés et remplis d'isobutane
2. Circuit de refroidissement (tuyaux verts/jaunes) et conduites de vapeur (tuyaux bleus) doivent être complètement connectés
3. D'abord, allumer l'échangeur de chaleur (partie 2)
4. Puis allumer le contrôleur
5. Il faut environ 2 minutes pour que le réacteur atteigne 80° et produise de la vapeur/électricité

**Important :** L'échangeur de chaleur et le contrôleur doivent fonctionner en même temps.

[ta5_fr_controller|image]

#### TA5 Coque du réacteur à fusion

Le réacteur complet doit être entouré d'une coque qui absorbe l'énorme pression que les aimants exercent sur le plasma et protège l'environnement des radiations. Sans cette coque, le réacteur ne peut pas être démarré. Avec la truelle TechAge, les câbles électriques et les conduites de refroidissement du réacteur à fusion peuvent également être intégrés dans la coque.

[ta5_fr_shell|image]

#### TA5 Noyau du réacteur à fusion

Le noyau doit être situé au centre du réacteur. Voir l'illustration sous "TA5 Réacteur à fusion". La truelle TechAge est également nécessaire pour cela.

[ta5_fr_nucleus|image]

## Stockage d'énergie

### TA5 Stockage hybride (prévu)

## Blocs logiques

## Transport et trafic

### TA5 Contrôleur de vol

Le contrôleur de vol TA5 est similaire au contrôleur de mouvement TA4. Contrairement au contrôleur de mouvement TA4, plusieurs mouvements peuvent être combinés en un trajet de vol ici. Ce trajet de vol peut être défini dans le champ de saisie via plusieurs indications x,y,z (un mouvement par ligne). Via "Enregistrer", le trajet de vol est vérifié et enregistré. En cas d'erreur, un message d'erreur est affiché.

Avec le bouton "Test", le trajet de vol est affiché avec les coordonnées absolues pour vérification dans le chat.

La distance maximale pour l'ensemble du trajet de vol est de 1500 m. Jusqu'à 32 blocs peuvent être entraînés.

L'utilisation du contrôleur de vol TA5 nécessite 40 points d'expérience.

**Mode Téléportation**

Si le `Mode Téléportation` est activé (réglé sur `enable`), un joueur peut également être déplacé sans blocs. Pour cela, la position de départ doit être configurée via le bouton "Enregistrer". Une seule position peut être configurée ici. Le joueur qui doit être déplacé doit se tenir sur cette position.

[ta5_flycontroller|image]

### TA5 Hyperloop Caisse / TA5 Hyperloop Chest

La caisse Hyperloop TA5 permet le transport d'objets via un réseau Hyperloop.

Pour cela, la caisse Hyperloop TA5 doit être placée sur une jonction Hyperloop. La caisse possède un menu spécial avec lequel on peut effectuer l'appariement de deux caisses. Les objets qui sont dans la caisse sont téléportés vers le point de destination. La caisse peut également être remplie/vidée avec un poussoir.

Pour l'appariement, vous devez d'abord entrer un nom pour la caisse d'un côté, puis vous pouvez sélectionner ce nom pour l'autre caisse et ainsi connecter les deux blocs.

L'utilisation de la caisse Hyperloop TA5 nécessite 15 points d'expérience.

[ta5_chest|image]

### TA5 Hyperloop Réservoir / TA5 Hyperloop Tank

Le réservoir Hyperloop TA5 permet le transport de liquides via un réseau Hyperloop.

Pour cela, le réservoir Hyperloop TA5 doit être placé sur une jonction Hyperloop. Le réservoir possède un menu spécial avec lequel on peut effectuer l'appariement de deux réservoirs. Les liquides qui sont dans le réservoir sont téléportés vers le point de destination. Le réservoir peut également être rempli/vidé avec une pompe.

Pour l'appariement, vous devez d'abord entrer un nom pour le réservoir d'un côté, puis vous pouvez sélectionner ce nom pour l'autre réservoir et ainsi connecter les deux blocs.

L'utilisation du réservoir Hyperloop TA5 nécessite 15 points d'expérience.

[ta5_tank|image]

### TA5 Planeur spatial (prévu)

Grâce à une propulsion spéciale pour la vitesse de la lumière, de grandes distances peuvent également être franchies très rapidement avec le planeur spatial.

## Blocs de téléportation

Avec les blocs de téléportation, des objets peuvent être transférés entre deux blocs de téléportation, sans qu'il soit nécessaire d'avoir un tube ou une conduite entre eux. Pour l'appariement des blocs, vous devez d'abord entrer un nom pour le bloc d'un côté, puis vous pouvez sélectionner ce nom pour l'autre bloc et ainsi connecter les deux blocs. L'appariement ne peut être effectué que par un joueur (le nom du joueur est vérifié) et doit être terminé avant un redémarrage du serveur. Sinon, les données d'appariement sont perdues.

Le plan de droite montre comment les blocs peuvent être utilisés.

[ta5_teleport|plan]

### TA5 Bloc de téléportation d'objets / TA5 Teleport Block Items

Ces blocs de téléportation permettent la transmission d'objets et remplacent ainsi un tube. Des distances allant jusqu'à 500 blocs peuvent être franchies.

Un bloc de téléportation nécessite 12 ku d'électricité.

Pour l'utilisation des blocs de téléportation, 30 points d'expérience sont nécessaires.

[ta5_tele_tube|image]

### TA5 Bloc de téléportation de liquides / TA5 Teleport Block Liquids

Ces blocs de téléportation permettent la transmission de liquides et remplacent ainsi une conduite jaune. Des distances allant jusqu'à 500 blocs peuvent être franchies.

Un bloc de téléportation nécessite 12 ku d'électricité.

Pour l'utilisation des blocs de téléportation, 30 points d'expérience sont nécessaires.

[ta5_tele_pipe|image]

### Blocs de téléportation Hyperloop (prévu)

Les blocs de téléportation Hyperloop permettent la construction d'un réseau Hyperloop sans tubes Hyperloop.

L'utilisation des blocs de téléportation Hyperloop nécessite 60 points d'expérience.

## TA5 Numériseur / TA5 Digitizer

### TA5 Numériseur / TA5 Digitizer

Le TA5 Digitizer est un bloc de stockage d'objets haute capacité qui stocke numériquement les objets prélevés dans des inventaires adjacents. Il peut fonctionner dans deux modes (pull/push) et gère jusqu'à 8 types d'objets différents avec jusqu'à 100 000 objets par slot.

Le Digitizer dispose d'une connexion tube sur le côté droit et peut également être contrôlé via le réseau Techage. En mode pull, il prélève jusqu'à 50 objets par cycle d'un coffre connecté. En mode push, il restitue les objets stockés dans les inventaires adjacents.

Seuls les objets empilables sans métadonnées et sans usure peuvent être stockés. Les objets tels que les livres signés ou les outils usés sont rejetés.

Le Digitizer ne peut être retiré à la pioche que si le stockage interne est complètement vide. Utilisez le tournevis sans fil pour le retirer lorsqu'il est à l'arrêt - les objets stockés sont conservés en tant que métadonnées et restaurés automatiquement lors de la repose avec le tournevis sans fil.

Le TA5 Digitizer nécessite 24 ku d'électricité.

50 points d'expérience sont requis pour utiliser le TA5 Digitizer (configurable via `techage_ta5_digitizer_expoints`).

Le Digitizer peut également être configuré et démarré à l'aide d'un contrôleur Lua ou Beduino.

Voici les commandes supplémentaires pour le contrôleur Lua :

- `on` / `off` - Démarrer ou arrêter le Digitizer
- `state` - Interroger l'état actuel (ex. "running", "stopped")
- `pull` - Démarrer en mode pull ; prélève les objets du coffre adjacent
- `push` - Démarrer en mode push ; restitue les objets stockés dans le coffre adjacent
- `stop` - Arrêter le Digitizer
- `config` définit le type d'objet cible (arrête d'abord le Digitizer).
  Exemple : `$send_cmnd(NUM, "config", "default:stone")`
- `count` interroge le nombre total d'objets stockés.
  Exemple : `$send_cmnd(NUM, "count")` retourne un nombre
- `itemstring` interroge le type d'objet configuré.
  Exemple : `$send_cmnd(NUM, "itemstring")` retourne le nom de l'objet
- `mode` lit ou définit le mode de fonctionnement (1 = pull, 2 = push).
  Exemple : `$send_cmnd(NUM, "mode")` retourne 1 ou 2
  Exemple : `$send_cmnd(NUM, "mode", 2)` définit le mode push

Topics Beduino (cmnd) : 65 = définir le type d'objet, 67 = définir le mode (1=pull, 2=push)
Topics Beduino (request) : 154 = nombre total d'objets stockés, 155 = type d'objet configuré

[ta5_digitizer|image]

### TA5 Unité de contrôle / TA5 Control Unit

L'unité de contrôle TA5 est nécessaire pour fabriquer le TA5 Digitizer. Elle ne peut être fabriquée qu'à la Fab Électronique TA4 et nécessite 50 points d'expérience.

[ta5_controlunit|image]

### TA5 SSD

Le TA5 SSD est un composant intermédiaire nécessaire à la fabrication du TA5 Digitizer. Il ne peut être fabriqué qu'à la Fab Électronique TA4 à partir de 16 puces RAM TA4, d'un wafer silicium TA4, d'une feuille plastique et d'un profilé acier.

[ta5_ssd|image]

## Autres blocs/objets TA5

### TA5 Conteneur (prévu)

Le conteneur TA5 permet d'emballer et de déballer des installations Techage à un autre endroit.

Pour l'utilisation du conteneur TA5, 80 points d'expérience sont nécessaires.

### TA5 Puce IA / TA5 AI Chip

La puce IA TA5 est partiellement nécessaire pour la fabrication de blocs TA5. La puce IA TA5 ne peut être fabriquée que sur la fabrique d'électronique TA4. Pour cela, 10 points d'expérience sont nécessaires.

[ta5_aichip|image]

### TA5 Puce IA II / TA5 AI Chip II

La puce IA TA5 II est nécessaire pour la fabrication du réacteur à fusion TA5. La puce IA TA5 II ne peut être fabriquée que sur la fabrique d'électronique TA4. Pour cela, 25 points d'expérience sont nécessaires.

[ta5_aichip2|image]
