# Mod Tech Age

Tech Age est un mod technologique avec 5 étapes de développement :

TA1 : Âge du Fer
Utilisez des outils et des aides tels que des brûleurs à charbon, des tamis à gravier, des marteaux et des trémies pour extraire et traiter les minerais et métaux nécessaires.

TA2 : Âge de la Vapeur
Construisez un moteur à vapeur avec des axes d'entraînement et utilisez-le pour faire fonctionner vos premières machines de traitement de minerais.

TA3 : Âge du Pétrole
Trouvez et extrayez du pétrole, construisez des voies ferrées pour le transport du pétrole. Une centrale électrique fournit l'électricité nécessaire à vos machines. L'éclairage électrique illumine vos installations industrielles.

TA4 : Présent
Les sources d'énergie renouvelables telles que le vent, le soleil et les biocarburants vous aident à quitter l'âge du pétrole. Avec des technologies modernes et des machines intelligentes, vous vous lancez dans l'avenir.

TA5 : Futur
Des machines pour surmonter l'espace et le temps, de nouvelles sources d'énergie et d'autres réalisations façonnent votre vie.

Note : Avec un clic sur le signe plus, vous accédez aux sous-chapitres de ce manuel.

[techage_ta4|image]

## Conseils

Cette documentation est disponible à la fois "en jeu" (plan de construction de bloc) et sur GitHub sous forme de fichiers MD.

- Lien : https://github.com/joe7575/techage/wiki

Les plans de construction (diagrammes) pour la construction des machines et les images ne sont disponibles qu'en jeu.

Avec Tech Age, vous devez recommencer à zéro. Vous ne pouvez créer des blocs TA2 qu'avec les éléments de TA1, pour TA3 vous avez besoin des résultats de TA2, etc.

Dans TA2, les machines ne fonctionnent qu'avec des axes d'entraînement.

À partir de TA3, les machines fonctionnent à l'électricité et ont une interface de communication pour le contrôle à distance.

TA4 ajoute plus de sources d'énergie, mais aussi des défis logistiques plus élevés (lignes électriques, transport d'objets).

## Changements depuis la version 1.0

À partir de la V1.0 (07/17/2021), les changements suivants ont été apportés :

- L'algorithme de calcul de la distribution de puissance a changé. Cela rend les systèmes de stockage d'énergie plus importants. Ceux-ci compensent les fluctuations, ce qui est important dans les grands réseaux avec plusieurs générateurs.
- Pour cette raison, TA2 a obtenu son propre stockage d'énergie.
- Les blocs de batterie de TA3 servent également de stockage d'énergie. Leur fonctionnalité a été adaptée en conséquence.
- Le système de stockage de TA4 a été révisé. Les échangeurs de chaleur ont reçu un nouveau numéro car la fonctionnalité a été déplacée du bloc inférieur au bloc central. Si ceux-ci étaient contrôlés à distance, le numéro de nœud doit être adapté. Les générateurs n'ont plus leur propre menu, mais sont uniquement allumés/éteints via l'échangeur de chaleur. L'échangeur de chaleur et le générateur doivent maintenant être connectés au même réseau !
- Plusieurs réseaux électriques peuvent maintenant être couplés via des blocs transformateurs TA4.
- Un bloc compteur d'électricité TA4 pour les sous-réseaux est également nouveau.
- Au moins un bloc de batterie ou un système de stockage dans chaque réseau

### Conseils pour la transition

Beaucoup plus de blocs ont reçu des modifications mineures. Il est donc possible que les machines ou les systèmes ne redémarrent pas immédiatement après le changement. En cas de dysfonctionnements, les conseils suivants vous aideront :

- Éteignez et rallumez les machines
- Retirez un bloc de câble d'alimentation et remettez-le en place
- Retirez complètement le bloc et remettez-le en place

## Minerais et Minéraux

Techage ajoute quelques nouveaux éléments au jeu :

- Meridium - un alliage pour la production d'outils lumineux dans TA1
- Usmium - un minerai qui est extrait dans TA2 et nécessaire pour TA3
- Baborium - un métal nécessaire pour les recettes dans TA3
- Pétrole - nécessaire dans TA3
- Bauxite - un minerai d'aluminium nécessaire dans TA4 pour produire de l'aluminium
- Basalte - se forme lorsque l'eau et la lave se touchent

### Meridium

Le Meridium est un alliage d'acier et de cristaux de mesecons. Les lingots de Meridium peuvent être fabriqués avec le brûleur à charbon à partir d'acier et de cristaux de mesecons. Le Meridium brille dans le noir. Les outils en Meridium s'allument également et sont donc très utiles pour l'exploitation minière souterraine.

[meridium|image]

### Usmium

L'Usmium n'apparaît que sous forme de pépites et ne peut être obtenu qu'en lavant le gravier avec le système de lavage de gravier TA2/TA3.

[usmium|image]

### Baborium

Le Baborium ne peut être obtenu que par l'exploitation minière souterraine. Cette substance ne peut être trouvée qu'à une profondeur de -250 à -340 mètres.

Le Baborium ne peut être fondu que dans le Four Industriel TA3.

[baborium|image]

### Pétrole

Le pétrole ne peut être trouvé qu'avec l'aide de l'Explorateur et extrait avec l'aide de machines TA3 appropriées. Voir TA3.

[oil|image]

### Bauxite

La bauxite n'est extraite que dans l'exploitation minière souterraine. La bauxite ne se trouve que dans la pierre à une hauteur entre -50 et -500 mètres.
Elle est nécessaire pour la production d'aluminium, qui est principalement utilisé dans TA4.

[bauxite|image]

### Basalte

Le basalte ne se forme que lorsque la lave et l'eau se rencontrent.
La meilleure chose à faire est de mettre en place un système où une source de lave et une source d'eau coulent ensemble.
Le basalte se forme là où les deux liquides se rencontrent.
Vous pouvez construire un générateur de basalte automatisé avec le Sign Bot.

[basalt|image]

## Historique

- 28.09.2019 : Système solaire ajouté
- 05.10.2019 : Données sur le système solaire et description de l'onduleur et du terminal d'alimentation modifiées
- 18.11.2019 : Chapitre pour les minerais, réacteur, aluminium, silo, bauxite, chauffage du four, système de lavage de gravier ajouté
- 22.02.2020 : corrections et chapitres sur la mise à jour
- 29.02.2020 : Contrôleur ICTA ajouté et autres corrections
- 14.03.2020 : Contrôleur Lua ajouté et autres corrections
- 22.03.2020 : Plus de blocs TA4 ajoutés
