# TA2: Edad del Vapor

TA2 trata de construir y operar las primeras máquinas para el procesamiento de minerales. Algunas máquinas deben ser accionadas mediante ejes de transmisión. Para ello, necesitas construir una máquina de vapor y calentarla con carbón o carbón vegetal.

En TA2 también hay una enjuagadora de grava que se puede usar para lavar minerales raros como las pepitas de Usmium. Necesitarás estas pepitas más adelante para otras recetas.

[techage_ta2|image]

## Máquina de Vapor

La máquina de vapor consta de varios bloques y debe ensamblarse como se muestra en el plano de la derecha. Se requieren los bloques: caja de fuego TA2, parte superior de la caldera TA2, base de la caldera TA2, cilindro TA2, volante de inercia TA2 y tuberías de vapor.

Además, se necesitan ejes de transmisión y cajas de cambios para cambiar de dirección. El volante de inercia debe conectarse a todas las máquinas que deban accionarse mediante los ejes de transmisión.

Presta siempre atención a la alineación de todos los bloques al colocarlos:

- Cilindro a la izquierda, volante de inercia a la derecha
- Conecta las tuberías de vapor donde haya un agujero correspondiente
- El eje de transmisión del volante de inercia solo a la derecha
- En todas las máquinas, los ejes de transmisión se pueden conectar por todos los lados que no estén ocupados por otras funciones, como los agujeros de ENTRADA y SALIDA en la trituradora y la criba

La caldera debe llenarse con agua. Llena hasta 10 cubos de agua en la caldera.
La caja de fuego debe llenarse con carbón o carbón vegetal.
Cuando el agua esté caliente (indicador de temperatura en la parte superior), la máquina de vapor puede iniciarse desde el volante de inercia.

La máquina de vapor tiene una capacidad de 25 ku, por lo que puede accionar varias máquinas al mismo tiempo.

[steamengine|plan]


### Caja de Fuego TA2

Parte de la máquina de vapor.

La caja de fuego debe llenarse con carbón o carbón vegetal. El tiempo de combustión depende de la potencia demandada por la máquina de vapor. El carbón arde durante 32 s y el carbón vegetal durante 96 s a plena carga.

[ta2_firebox|image]


### Caldera TA2

Parte de la máquina de vapor. Debe llenarse con agua. Esto se hace haciendo clic en la caldera con un cubo de agua. Cuando ya no haya agua o la temperatura baje demasiado, la máquina de vapor se apaga. Con la máquina de vapor, se pierde algo de agua como vapor con cada carrera del émbolo, por lo que hay que rellenar el agua regularmente.

[ta2_boiler|image]


### Cilindro TA2

Parte de la máquina de vapor.

[ta2_cylinder|image]


### Volante de Inercia TA2

Parte de accionamiento de la máquina de vapor. El volante de inercia debe conectarse a las máquinas mediante ejes de transmisión.

[ta2_flywheel|image]


### Tuberías de Vapor TA2

Parte de la máquina de vapor. La caldera debe conectarse al cilindro mediante las tuberías de vapor. La tubería de vapor no tiene ramificaciones, la longitud máxima es de 12 m (bloques).

[ta2_steampipe|image]


### Eje de Transmisión TA2 / Caja de Cambios TA2

Los ejes de transmisión se utilizan para transmitir potencia desde la máquina de vapor a otras máquinas. La longitud máxima de un eje de transmisión es de 10 bloques. Con las cajas de cambios TA2 se pueden salvar distancias mayores y realizar ramificaciones y cambios de dirección.

[ta2_driveaxle|image]


### Generador de Energía TA2

El Generador de Energía TA2 es necesario para operar lámparas u otros consumidores de energía en una máquina de vapor. El Generador de Energía TA2 debe conectarse a ejes de transmisión en un lado y luego suministra electricidad en el otro lado.

Si el Generador no recibe suficiente potencia, entra en estado de error y debe reactivarse con un clic derecho.

El Generador toma como máximo 25 ku de potencia del eje y proporciona en el otro lado como máximo 24 ku como electricidad. Por lo tanto, consume un ku para la conversión.

[ta2_generator|image]

## Almacenamiento de energía TA2

Para instalaciones más grandes con varios motores de vapor o muchas máquinas accionadas, se recomienda un sistema de almacenamiento de energía. El almacenamiento de energía en TA2 funciona con energía potencial. Para ello, el lastre (piedras, grava, arena) se eleva en un cofre con la ayuda de un cabrestante de cable. Si hay exceso de energía en la red de ejes, el cofre se eleva hacia arriba. Si se necesita más energía a corto plazo de la que puede suministrar la máquina de vapor, el almacén de energía libera la energía almacenada nuevamente y el cofre de pesas vuelve a bajar.
El almacenamiento de energía consta de varios bloques y debe ensamblarse como se muestra en el plano de la derecha.
Para lograr la capacidad máxima de almacenamiento, el cofre debe estar completamente lleno de pesas y el mástil incluyendo las dos cajas de engranajes debe tener 12 bloques de altura. También son posibles estructuras más pequeñas.

[ta2_storage|plan]



### Cabrestante TA2

El cabrestante de cable debe conectarse a una caja de engranajes y puede absorber el exceso de energía y así elevar un cofre de pesas hacia arriba.
Al ensamblar el cabrestante de cable, asegúrate de que la flecha en la parte superior del bloque apunte hacia la caja de engranajes.
La longitud máxima del cable es de 10 bloques.

[ta2_winch|image]



### Cofre de Pesas TA2

Este cofre debe colocarse debajo del cabrestante con una distancia de hasta 10 bloques y llenarse con adoquines, grava o arena. Si se alcanza el peso mínimo de una pila (99+ objetos) y hay exceso de energía, la caja se conecta automáticamente al cabrestante mediante un cable y se eleva hacia arriba.

[ta2_weight_chest|image]



### Embrague TA2

Con el embrague, los ejes y las máquinas pueden separarse del almacenamiento de energía. Esto significa que los ejes después del embrague se detienen y los sistemas de máquinas pueden reconstruirse. Al ensamblar el embrague, asegúrate de que la flecha en la parte superior del bloque apunte hacia el sistema de almacenamiento de energía.

[techage:ta2_clutch_off|image]



## Empujar y clasificar objetos

Para transportar objetos de una estación de procesamiento a la siguiente, se utilizan empujadores y tubos. Ver plano.

[itemtransport|plan]


### Tubo TechAge

Dos máquinas pueden conectarse con la ayuda de un empujador y un tubo. Los tubos no tienen ramificaciones. La longitud máxima es de 200 m (bloques).

Alternativamente, los tubos se pueden colocar usando la tecla Shift. Esto permite, por ejemplo, colocar tubos en paralelo sin que se conecten accidentalmente.

La capacidad de transporte de un tubo es ilimitada y solo está limitada por el empujador.

[tube|image]

### Concentrador de Tubos

Varios tubos pueden combinarse en un solo tubo a través del concentrador. La dirección en la que se pasan todos los objetos se indica con una flecha.

[concentrator|image]

### Empujador TA2

Un empujador puede extraer objetos de cajas o máquinas y empujarlos hacia otras cajas o máquinas. En otras palabras, debe haber exactamente un empujador entre dos bloques con inventario. No es posible tener varios empujadores seguidos.
En la dirección opuesta, sin embargo, un empujador es permeable a los objetos, de modo que una caja puede llenarse a través de un tubo y también enseñarse.

Un empujador entra en estado "en espera" si no tiene objetos que empujar. Si la salida está bloqueada o el inventario del receptor está lleno, el empujador entra en estado "bloqueado". El empujador sale automáticamente de ambos estados después de unos segundos si la situación ha cambiado.

La capacidad de procesamiento de un empujador TA2 es de 2 objetos cada 2 s.

[ta2_pusher|image]


### Distribuidor TA2

El distribuidor puede transportar los objetos de su inventario clasificados en hasta cuatro direcciones. Para ello, el distribuidor debe configurarse en consecuencia.

El distribuidor tiene un menú con 4 filtros de diferentes colores, correspondientes a las 4 salidas. Si se va a usar una salida, el filtro correspondiente debe activarse mediante la casilla de verificación "on". Todos los objetos configurados para este filtro se emiten a través de la salida asignada. Si se activa un filtro sin que se configuren objetos, se habla de una salida "no configurada", abierta.

**Atención: ¡El distribuidor también es un empujador en sus lados de salida. Por lo tanto, nunca saques objetos del distribuidor con un empujador!**

Hay dos modos de funcionamiento para una salida no configurada:

1) Emitir todos los objetos que no puedan emitirse por ninguna otra salida, incluso si están bloqueados.

2) Emitir solo los objetos que no se hayan configurado para ningún otro filtro.

En el primer caso, todos los objetos siempre se reenvían y el distribuidor no se llena. En el segundo caso, los objetos se retienen y el distribuidor puede llenarse y luego bloquearse.

El modo de funcionamiento puede configurarse mediante la casilla de verificación "modo de bloqueo".

La capacidad de procesamiento de un distribuidor TA2 es de 4 objetos cada 2 s, donde el distribuidor intenta distribuir los 4 objetos entre las salidas abiertas.

Si el mismo objeto se configura varias veces en un filtro, la proporción de distribución a largo plazo se verá influenciada en consecuencia.

Ten en cuenta que la distribución es un proceso probabilístico. Esto significa que las proporciones de distribución no se cumplirán exactamente, sino solo a largo plazo.

El tamaño máximo de pila en los filtros es 12; en total, no se pueden configurar más de 36 objetos.

[ta2_distributor|image]


## Lavador de Grava

El lavador de grava es una máquina más compleja con el objetivo de lavar pepitas de Usmium de la grava cribada. Para la instalación se requieren una enjuagadora TA2 con accionamiento por eje, una tolva, un cofre y agua corriente.

Estructura de izquierda a derecha (ver también el plano):

* Un bloque de tierra, encima de él la fuente de agua, rodeada por 3 lados con bloques de vidrio, por ejemplo
* Junto a ella la enjuagadora de grava, si es necesario con conexiones de tubo para la entrega y extracción de grava
* Luego la tolva con cofre

Todo el conjunto está rodeado de más bloques de vidrio, de modo que el agua fluye sobre la enjuagadora de grava y la tolva y las pepitas lavadas pueden ser recogidas nuevamente por la tolva.

[gravelrinser|plan]


### Enjuagadora de Grava TA2

El lavador de grava puede lavar los minerales de Usmium y cobre de la grava que ya ha sido cribada, siempre que esta sea enjuagada con agua.

Si la Enjuagadora de Grava funciona correctamente puede verificarse con palos si estos se colocan en el inventario de la Enjuagadora de Grava. Estos deben lavarse individualmente y ser recogidos por la tolva.

La capacidad de procesamiento es de un objeto de grava cada 2 s. El lavador de grava necesita 3 ku de energía.

[ta2_rinser|image]


## Excavar piedra, triturar y cribar

La trituración y el cribado de adoquines se usan para extraer minerales. La grava cribada también puede usarse para otros propósitos. La cantera, la trituradora y la criba deben ser accionadas y por tanto instaladas cerca de una máquina de vapor.

[ta2_grinder|image]


### Cantera TA2

La cantera se usa para extraer piedras y otros materiales del subsuelo. La cantera excava un agujero de 5x5 bloques. La profundidad es ajustable.
La capacidad de procesamiento es de un bloque cada 4 s. La cantera necesita 10 ku de energía. La profundidad máxima es de 20 metros. Para mayores profundidades ver TA3 / TA4.

[ta2_quarry|image]


### Trituradora TA2

La trituradora puede triturar varias rocas, pero también madera y otros objetos.
La capacidad de procesamiento es de un objeto cada 4 s. La trituradora necesita 4 ku de energía.

[ta2_grinder|image]


### Criba de Grava TA2

La criba de grava puede cribar la grava para extraer minerales. El resultado es parcialmente "grava cribada", que no puede cribarse de nuevo.
La capacidad de procesamiento es de un objeto cada 4 s. La criba de grava requiere 3 ku de energía.

[ta2_gravelsieve|image]


## Producir Objetos

Las máquinas TA2 no solo pueden extraer minerales, sino también producir objetos.


### Fabricante Automático TA2

El fabricante automático se usa para la producción automática de bienes. Todo lo que el jugador puede producir a través de la "Cuadrícula de Fabricación" también puede hacerlo el fabricante automático. Para ello, la receta debe introducirse en el menú del fabricante automático y añadirse los ingredientes necesarios.

Los ingredientes y los bienes fabricados pueden transportarse dentro y fuera del bloque mediante tubos y empujadores.

La capacidad de procesamiento es de un objeto cada 4 s. El fabricante automático requiere 4 ku de energía.

[ta2_autocrafter|image]


### Fábrica Electrónica TA2

La fábrica electrónica es una máquina especial y solo puede usarse para la producción de tubos de vacío. Los tubos de vacío son necesarios para las máquinas y bloques TA3.

La capacidad de procesamiento es de un tubo de vacío cada 6 s. La fábrica electrónica requiere 8 ku de energía.

[ta2_electronicfab|image]


## Otros bloques

### Muestreador de Líquidos TA2

Algunas recetas requieren agua. Para que estas recetas también puedan procesarse automáticamente con el fabricante automático, el agua debe suministrarse en cubos. El muestreador de líquidos se usa para esto. Necesita cubos vacíos y debe colocarse en el agua.

La capacidad de procesamiento es de un cubo de agua cada 8 s. El muestreador de líquidos requiere 3 ku de energía.

[ta2_liquidsampler|image]


### Cofre Protegido TA2

El cofre protegido solo puede ser usado por jugadores que puedan construir en esa ubicación, es decir, que tengan derechos de protección. No importa quién coloque el cofre.

[ta2_chest|image]


### Bloque de Carga Forzada Techage

Minetest divide el mapa en los llamados bloques de mapa. Estos son cubos con una longitud de arista de 16x16x16 bloques. Tal bloque de mapa siempre es cargado completamente por el servidor, pero solo los bloques alrededor de un jugador son cargados (aprox. 2-3 bloques en todas las direcciones). En la dirección de visión del jugador también hay más bloques de mapa. Solo esta parte del mundo está activa y solo aquí crecen plantas y árboles o funcionan las máquinas.

Con un bloque de carga forzada puedes forzar que el bloque de mapa en el que se encuentra el bloque de carga forzada permanezca cargado mientras estés en el servidor. Cuando todas tus granjas y máquinas estén cubiertas con bloques de carga forzada, todo estará siempre funcionando.

Los bloques de mapa con sus coordenadas están predefinidos, por ejemplo (0,0,0) a (15,15,15), o (16,16,16) a (31,31,31).
Puedes mover un bloque de carga forzada dentro de un bloque de mapa como quieras, la posición del bloque de mapa permanece sin cambios.

[ta2_forceload|image]

### Resumen de administración de carga forzada

Los administradores del servidor pueden usar el comando de chat `/forceload_admin` para abrir un resumen de todos los bloques de carga forzada en el servidor.
La tabla muestra el propietario, la posición del bloque y si el propietario está actualmente en línea.
Un doble clic en una fila teletransporta al administrador directamente a ese bloque de carga forzada.

[ta2_forceload|image]
