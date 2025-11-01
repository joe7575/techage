# TA1 : Âge du Fer

Dans TA1, il s'agit d'extraire suffisamment de minerais et de produire du charbon de bois avec des outils et des équipements simples, afin de pouvoir fabriquer et faire fonctionner des machines TA2.

Bien sûr, pour un âge du fer, il doit y avoir du fer et pas seulement de l'acier (steel), comme dans "Minetest Game". Par conséquent, certaines recettes ont été modifiées, de sorte que le fer doit d'abord être produit, puis plus tard l'acier.

La durabilité des outils est également adaptée aux époques et ne correspond donc pas au jeu original Minetest.
La durabilité/dureté, par exemple, pour une hache est :

* Bronze : 20
* Acier : 30

[techage_ta1|image]

## Charbonnier / Tas de Charbon

Le charbonnier est nécessaire pour produire du charbon de bois. Le charbon de bois est nécessaire pour le brûleur, mais aussi, par exemple, dans TA2 pour la machine à vapeur.

Pour le charbonnier, vous avez besoin de :

- un bloc d'allumeur (`techage:lighter`)
- 26 blocs de bois (wood), empilés en un cube. Le type de bois n'a pas d'importance.
- de la terre (dirt) pour couvrir le tas de bois.
- un briquet (nom technique : `fire:flint_and_steel`) pour allumer le bloc d'allumeur.

Instructions de construction (voir aussi le plan) :

- Construisez une surface de 5x5 en terre (dirt)
- Placez un allumeur (lighter) au centre
- Placez 7 blocs de bois (wood) autour de l'allumeur, mais laissez un trou vers l'allumeur libre
- Construisez deux autres couches de bois par-dessus, de sorte à former un cube de bois de 3x3x3
- Couvrez le tout avec une couche de terre pour former un cube de 5x5x5, mais laissez le trou vers l'allumeur libre
- Allumez l'allumeur et fermez immédiatement le trou avec un bloc de bois et de terre
- Si vous avez tout fait correctement, le charbonnier commencera à fumer après quelques secondes
- N'ouvrez le charbonnier que lorsque la fumée a disparu (environ 20 min)

Vous pouvez alors retirer les 9 blocs de charbon de bois et remplir à nouveau le charbonnier.

[coalpile|plan]

## Brûleur à Charbon / Coal Burner

Le brûleur à charbon est nécessaire, par exemple, pour fondre du fer et d'autres minerais dans le creuset (Melting Pot). Il existe différentes recettes qui nécessitent différentes températures. Plus la tour est haute, plus la flamme est chaude. Une hauteur de 11 blocs au-dessus de la plaque de base est suffisante pour toutes les recettes, mais un brûleur de cette hauteur consomme également plus de charbon de bois.

Instructions de construction (voir aussi le plan) :

* Construisez une tour en pierre (cobble) avec une base de 3x3 (7-11 blocs de haut)
* Laissez un trou ouvert d'un côté en bas
* Placez un allumeur (lighter) à l'intérieur
* Remplissez la tour de charbon de bois jusqu'au bord en laissant tomber le charbon de bois par le trou supérieur
* Allumez l'allumeur à travers le trou
* Placez le creuset (Melting Pot) en haut de la tour directement dans la flamme, un bloc au-dessus du bord de la tour
* Pour arrêter le brûleur, fermez temporairement le trou, par exemple avec un bloc de terre.

Le creuset (Melting Pot) a son propre menu avec des recettes et un inventaire où vous placez les minerais.

[coalburner|plan]

## Moulin à Eau

Avec le moulin à eau, vous pouvez moudre du blé et d'autres céréales en farine, puis les cuire au four pour faire du pain. Le moulin est entraîné par la force hydraulique. Pour cela, un ruisseau de moulin doit être dirigé vers la roue du moulin via un canal.
Une écluse peut contrôler le flux d'eau et ainsi la roue du moulin.
L'écluse se compose d'un vannage et d'une poignée d'écluse.

L'image de droite (cliquez sur "Plan") montre la structure du moulin à eau.

[watermill1|plan]

### Moulin TA1

Avec le moulin à eau, vous pouvez moudre du blé et d'autres céréales en farine, puis les cuire au four pour faire du pain.
Le moulin doit être connecté à la roue du moulin avec un axe TA1. La puissance de la roue du moulin suffit pour un seul moulin.

Le moulin peut être automatisé à l'aide d'un Minecart Hopper, de sorte que la farine est transportée directement du moulin à un four, par exemple, pour en faire du pain.

[watermill2|plan]

### Vannage TA1 / TA1 Sluice Gate

Le vannage doit être placé à la même hauteur que la surface de l'eau, directement sur un étang ou dans un ruisseau.
Lorsque l'écluse est ouverte, l'eau s'écoule à travers le vannage. Cette eau doit ensuite être dirigée vers la roue du moulin et actionner le moulin.

[ta1_sluice|image]

### Poignée d'écluse TA1 / TA1 Sluice Handle

La poignée d'écluse TA1 doit être placée sur le vannage. À l'aide de la poignée d'écluse (clic droit), le vannage peut être ouvert.

[ta1_sluice_handle|image]

### Planche en bois de pommier TA1 / TA1 Apple Wood Board

Bloc en différentes essences de bois pour construire le canal du ruisseau de moulin. Cependant, tout autre matériau peut également être utilisé.

[ta1_board1|image]

### Planche de canal de moulin en pommier TA1 / TA1 Apple Millrace Board

Bloc en différentes essences de bois pour construire le canal du ruisseau de moulin. Ce bloc est particulièrement adapté en combinaison avec les poteaux de la clôture en bois pour construire un support pour le canal.

[ta1_board2|image]

## Minerais et Outils

TA1 a ses propres outils comme le marteau et le tamis à gravier, mais le Minecart Hopper peut également être utilisé.

[ta1_gravelsieve|image]

### Marteau

Avec le marteau TA1, vous pouvez écraser des pierres (stone) et des pavés (cobble) en gravier (gravel). Le marteau est disponible en différentes versions et donc avec différentes propriétés : Bronze, Acier, Mese et Diamant.

[hammer|image]

### Tamis à Gravier / Gravel Sieve

Avec le tamis à gravier, vous pouvez tamiser les minerais du gravier. Pour ce faire, cliquez sur le tamis avec le gravier (gravel). Le gravier tamisé et les minerais tombent en bas.

Pour ne pas rester des heures devant le tamis, le tamisage peut être automatisé avec l'entonnoir (hopper).

[ta1_gravelsieve|image]

### Entonnoir / Hopper

L'entonnoir de la mod "Minecart" sert principalement à charger et décharger les Minecarts. Il aspire les objets (items) par le haut et les transmet vers la droite. Lors du placement de l'entonnoir, il faut donc faire attention à la direction de sortie.

L'entonnoir peut également tirer des objets des coffres (chest), à condition que le coffre soit à côté ou sur l'entonnoir.

L'entonnoir peut également placer des objets dans des coffres, à condition que le coffre soit à côté de l'entonnoir.

[ta1_hopper|image]

### Tamisage du Gravier avec l'Entonnoir

À l'aide de deux coffres, de deux entonnoirs et d'un tamis à gravier, le processus de tamisage peut être automatisé. Le plan de droite montre la structure.

Pour les coffres, assurez-vous qu'il s'agit de "chest_locked", sinon quelqu'un pourrait voler vos minerais précieux du coffre du bas.

[hoppersieve|plan]

### Meridium

TA1 a son propre alliage métallique, le Meridium. Les lingots de Meridium peuvent être fabriqués avec le brûleur à charbon à partir d'acier et de fragments de mese. Le Meridium brille dans le noir. Les outils en Meridium brillent également et sont donc très utiles dans l'exploitation minière souterraine.

[meridium|image]
