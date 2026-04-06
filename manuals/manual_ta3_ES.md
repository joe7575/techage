# TA3: Edad del Petróleo

En TA3 es importante reemplazar las máquinas de vapor por máquinas más potentes y eléctricas.

Para ello, tienes que construir centrales eléctricas de carbón y generadores. Pronto verás que tus necesidades de electricidad solo pueden satisfacerse con centrales eléctricas de petróleo. Así que te pones a buscar petróleo. Las torres de perforación y las bombas de petróleo te ayudan a obtenerlo. Los ferrocarriles se usan para transportar el petróleo a las centrales eléctricas.

La era industrial está en su apogeo.

[techage_ta3|image]


## Central Eléctrica de Carbón / Central Eléctrica de Petróleo

La central eléctrica de carbón consta de varios bloques y debe ensamblarse como se muestra en el plano de la derecha. Se requieren los bloques: caja de fuego de la central TA3, parte superior de la caldera TA3, base de la caldera TA3, turbina TA3, generador TA3 y enfriador TA3.

La caldera debe llenarse con agua. Llena hasta 10 cubos de agua en la caldera o conecta una tubería de líquido a la parte superior de la caldera para suministrar agua automáticamente mediante bomba.
La caja de fuego debe llenarse con carbón o carbón vegetal.
Cuando el agua esté caliente, el generador puede entonces iniciarse.

Alternativamente, la central puede equiparse con un quemador de petróleo y luego operarse con petróleo.
El petróleo puede reponerse usando una bomba y una tubería de petróleo.

La central eléctrica entrega una potencia de 80 ku.

[coalpowerstation|plan]


### Caja de Fuego de la Central TA3

Parte de la central eléctrica.
La caja de fuego debe llenarse con carbón o carbón vegetal. El tiempo de combustión depende de la potencia que requiere la central. El carbón arde 20 s y el carbón vegetal 60 s a plena carga. Proporcionalmente más tiempo bajo carga parcial (50% de carga = el doble de tiempo).

[ta3_firebox|image]


### Quemador de Petróleo de la Central TA3

Parte de la central eléctrica.

El quemador de petróleo puede llenarse con petróleo crudo, fuel-oil, nafta o gasolina. El tiempo de combustión depende de la potencia que requiere la central. A plena carga, el petróleo crudo arde 15 s, el fuel-oil 20 s, la nafta 22 s y la gasolina 25 s.

Proporcionalmente más tiempo bajo carga parcial (50% de carga = el doble de tiempo).

El quemador de petróleo solo puede contener 50 unidades de combustible. Por ello, es aconsejable disponer de un depósito de petróleo adicional y una bomba de petróleo.

[ta3_oilbox|image]


### Base / Parte Superior de la Caldera TA3

Parte de la central eléctrica. Debe llenarse con agua. Si ya no hay agua o la temperatura baja demasiado, la central se apaga.

La caldera puede llenarse con agua de dos maneras:
- Manualmente haciendo clic en la parte superior de la caldera con un cubo de agua (hasta 10 cubos)
- Automáticamente a través de una tubería de líquido conectada a la parte superior de la caldera usando una bomba TA3/TA4

El consumo de agua de la caldera TA3 es mucho menor que el de la máquina de vapor debido al circuito de vapor cerrado.
Con la máquina de vapor, se pierde algo de agua como vapor con cada carrera del émbolo.

[ta3_boiler|image]


### Turbina TA3

La turbina es parte de la central eléctrica. Debe colocarse junto al generador y conectarse a la caldera y al enfriador mediante tuberías de vapor como se muestra en el plano.

[ta3_turbine|image]


### Generador TA3

El generador se usa para generar electricidad. Debe conectarse a las máquinas mediante cables eléctricos y cajas de conexiones.

[ta3_generator|image]


### Enfriador TA3

Se usa para enfriar el vapor caliente de la turbina. Debe conectarse a la caldera y a la turbina mediante tuberías de vapor como se muestra en el plano.

[ta3_cooler|image]


## Corriente Eléctrica

En TA3 (y TA4) las máquinas funcionan con electricidad. Para ello, las máquinas, los sistemas de almacenamiento y los generadores deben conectarse con cables eléctricos.
TA3 tiene 2 tipos de cables eléctricos:

- Cables aislados (cables eléctricos TA) para el cableado local en el suelo o en edificios. Estos cables pueden ocultarse en la pared o en el suelo (pueden "enlucirse" con la paleta).
- Líneas aéreas (líneas eléctricas TA) para el cableado exterior a largas distancias. Estos cables están protegidos y no pueden ser retirados por otros jugadores.

Varios consumidores, sistemas de almacenamiento y generadores pueden operarse juntos en una red eléctrica. Las redes pueden configurarse con la ayuda de las cajas de conexiones.
Si se proporciona muy poca electricidad, los consumidores se quedan sin suministro.
En este contexto, también es importante entender la funcionalidad de los bloques de carga forzada, porque los generadores, por ejemplo, solo suministran electricidad cuando el bloque de mapa correspondiente está cargado. Esto puede forzarse con un bloque de carga forzada.

En TA4 también hay un cable para el sistema solar.

[ta3_powerswitch|image]


### Importancia de los sistemas de almacenamiento

Los sistemas de almacenamiento en la red eléctrica cumplen dos tareas:

- Para hacer frente a los picos de demanda: Todos los generadores siempre producen exactamente tanta energía como se necesita. Sin embargo, si los consumidores se encienden/apagan o hay fluctuaciones en la demanda por otras razones, los consumidores pueden fallar por un corto tiempo. Para evitar esto, siempre debe haber al menos un bloque de batería en cada red. Este sirve como amortiguador y compensa estas fluctuaciones en el rango de segundos.
- Para almacenar energía regenerativa: El sol y el viento no están disponibles las 24 horas del día. Para que el suministro eléctrico no falle cuando no se produce electricidad, uno o más sistemas de almacenamiento deben instalarse en la red. Alternativamente, los huecos también pueden cubrirse con electricidad de petróleo/carbón.

Un sistema de almacenamiento indica su capacidad en kud, es decir, ku por día. Por ejemplo, un sistema de almacenamiento con 100 kud entrega 100 ku durante un día de juego, o 10 ku durante 10 días de juego.

Todas las fuentes de energía TA3/TA4 tienen características de carga ajustables. Por defecto está configurado en "80% - 100%". Esto significa que cuando el sistema de almacenamiento está al 80% de capacidad, la salida se reduce cada vez más hasta que se apaga completamente al 100%. Si se requiere electricidad en la red, nunca se alcanzará el 100%, ya que la potencia del generador ha caído en algún momento hasta la demanda de electricidad en la red y el sistema de almacenamiento ya no se carga, sino que solo se atiende a los consumidores.

Esto tiene varias ventajas:

- Las características de carga son ajustables. Esto significa, por ejemplo, que las fuentes de energía de petróleo/carbón pueden reducirse al 60% y las fuentes de energía renovables solo al 80%. Esto significa que el petróleo/carbón solo se quema si no hay suficientes fuentes de energía renovables disponibles.
- Varias fuentes de energía pueden operarse en paralelo y se cargan casi uniformemente, porque todas las fuentes de energía trabajan, por ejemplo, hasta el 80% de la capacidad de carga del sistema de almacenamiento a su plena capacidad y luego reducen su capacidad al mismo tiempo.
- Todos los sistemas de almacenamiento en una red forman un gran amortiguador. La capacidad de carga y el nivel de llenado de todo el sistema de almacenamiento siempre puede leerse en porcentaje en cada sistema de almacenamiento, pero también en el terminal de electricidad.

[power_reduction|image]


### Cable Eléctrico TA

Para el cableado local en el suelo o en edificios.
Las ramificaciones pueden realizarse usando cajas de conexiones. La longitud máxima de cable entre máquinas o cajas de conexiones es de 1000 m. Se pueden conectar un máximo de 1000 nodos en una red eléctrica. Todos los bloques con conexión eléctrica, incluidas las cajas de conexiones, cuentan como nodos.

Dado que los cables eléctricos no están protegidos automáticamente, se recomiendan las líneas aéreas (líneas eléctricas TA) para distancias más largas.

Los cables eléctricos pueden enlucirse con la paleta para que puedan ocultarse en la pared o en el suelo. Todos los bloques de piedra, arcilla y otros sin "inteligencia" pueden usarse como material de enlucido. La tierra no funciona porque la tierra puede convertirse en hierba o similar, lo que destruiría la línea.

Para enlucir, el cable debe hacer clic con la paleta. El material con el que se va a enlucir el cable debe estar en el extremo izquierdo del inventario del jugador.
Los cables pueden volver a hacerse visibles haciendo clic en el bloque con la paleta.

Además de los cables, la caja de conexiones TA y la caja del interruptor eléctrico TA también pueden enlucirse.

[ta3_powercable|image]


### Caja de Conexiones Eléctrica TA

Con la caja de conexiones, la electricidad puede distribuirse en hasta 6 direcciones. Las cajas de conexiones también pueden enlucirse (ocultarse) con una paleta y volver a hacerse visibles.

[ta3_powerjunction|image]


### Línea Eléctrica TA

Con la línea eléctrica TA y los postes de electricidad, se pueden realizar líneas aéreas razonablemente realistas. Los cabezales de los postes de electricidad también sirven para proteger la línea eléctrica (protección). Debe colocarse un poste cada 16 m o menos. La protección solo se aplica a la línea eléctrica y los postes; sin embargo, todos los demás bloques en esta área no están protegidos.

[ta3_powerline|image]


### Poste Eléctrico TA

Se usa para construir postes de electricidad. Está protegido contra la destrucción por la parte superior del poste de electricidad y solo puede ser retirado por el propietario.

[ta3_powerpole|image]


### Parte Superior del Poste Eléctrico TA

Tiene hasta cuatro brazos y así permite distribuir la electricidad en hasta 6 direcciones.
La parte superior del poste eléctrico protege las líneas eléctricas y los postes dentro de un radio de 8 m.

[ta3_powerpole4|image]


### Parte Superior del Poste Eléctrico TA 2

Este bloque tiene dos brazos fijos y se usa para las líneas aéreas. Sin embargo, también puede transmitir corriente hacia abajo y hacia arriba.
La parte superior del poste eléctrico protege las líneas eléctricas y los postes dentro de un radio de 8 m.

[ta3_powerpole2|image]


### Interruptor Eléctrico TA

El interruptor se puede usar para encender y apagar la electricidad. Para ello, el interruptor debe colocarse sobre una caja del interruptor eléctrico. La caja del interruptor eléctrico debe estar conectada al cable eléctrico en ambos lados.

[ta3_powerswitch|image]


### Interruptor Eléctrico Pequeño TA

El interruptor se puede usar para encender y apagar la electricidad. Para ello, el interruptor debe colocarse sobre una caja del interruptor eléctrico. La caja del interruptor eléctrico debe estar conectada al cable eléctrico en ambos lados.

[ta3_powerswitchsmall|image]


### Caja del Interruptor Eléctrico TA

Ver interruptor eléctrico TA.

[ta3_powerswitchbox|image]


### Generador Pequeño de Energía TA3

El generador pequeño funciona con gasolina y puede usarse para pequeños consumidores de hasta 12 ku. La gasolina arde 150 s a plena carga. Proporcionalmente más tiempo bajo carga parcial (50% de carga = el doble de tiempo).

El generador solo puede contener 50 unidades de gasolina. Por ello, es aconsejable disponer de un depósito adicional y una bomba.

[ta3_tinygenerator|image]


### Caja de Acumuladores TA3

La caja de acumuladores (batería recargable) se usa para almacenar el exceso de energía y suministra automáticamente energía en caso de un fallo del suministro (si está disponible).
Varias cajas de acumuladores juntas forman un sistema de almacenamiento de energía TA3. Cada caja de acumuladores tiene una pantalla para el estado de carga y la carga almacenada.
Aquí siempre se muestran los valores de toda la red. La carga almacenada se muestra en "kud" o "ku-días" (análogo a kWh). 5 kud corresponden, por ejemplo, a 5 ku durante un día de juego (20 min) o 1 ku durante 5 días de juego.

Una caja de acumuladores tiene 3.33 kud.

[ta3_akkublock|image]


### Terminal de Energía TA3

El terminal de energía debe conectarse a la red eléctrica. Muestra datos de la red eléctrica.

Las cifras más importantes se muestran en la mitad superior:

- potencia actual/máxima del generador
- consumo de energía actual de todos los consumidores
- corriente de carga actual entrada/salida del sistema de almacenamiento
- Estado de carga actual del sistema de almacenamiento en porcentaje

El número de bloques de red se muestra en la mitad inferior.

Los datos adicionales sobre los generadores y sistemas de almacenamiento pueden consultarse a través de la pestaña "consola".

[ta3_powerterminal|image]


### Motor Eléctrico TA3

El Motor Eléctrico TA3 es necesario para poder operar máquinas TA2 a través de la red eléctrica. El Motor Eléctrico TA3 convierte electricidad en potencia de eje.
Si el motor eléctrico no recibe suficiente energía, entra en estado de error y debe reactivarse con un clic derecho.

El motor eléctrico toma como máximo 40 ku de electricidad y proporciona en el otro lado como máximo 39 ku como potencia de eje. Por lo tanto, consume un ku para la conversión.

[ta3_motor|image]


## Horno Industrial TA3

El horno industrial TA3 sirve como complemento a los hornos normales. Esto significa que todos los bienes pueden producirse con recetas de "cocción", incluso en un horno industrial. Pero también hay recetas especiales que solo pueden hacerse en un horno industrial.
El horno industrial tiene su propio menú para la selección de recetas. Dependiendo de los bienes en el inventario del horno industrial a la izquierda, el producto de salida puede seleccionarse a la derecha.

El horno industrial requiere electricidad (para el potenciador) y fuel-oil / gasolina para el quemador. El horno industrial debe ensamblarse como se muestra en el plano de la derecha.

Ver también calentador TA4.

[ta3_furnace|plan]


### Quemador de Petróleo del Horno TA3

Es parte del horno industrial TA3.

El quemador de petróleo puede operarse con petróleo crudo, fuel-oil, nafta o gasolina. El tiempo de combustión es de 64 s para el petróleo crudo, 80 s para el fuel-oil, 90 s para la nafta y 100 s para la gasolina.

El quemador de petróleo solo puede contener 50 unidades de combustible. Por ello, es aconsejable disponer de un depósito adicional y una bomba.

[ta3_furnacefirebox|image]


### Parte Superior del Horno TA3

Es parte del horno industrial TA3. Ver horno industrial TA3.

[ta3_furnace|image]


### Potenciador TA3

Es parte del horno industrial TA3. Ver horno industrial TA3.

[ta3_booster|image]


## Líquidos

Los líquidos como el agua o el petróleo solo pueden bombearse a través de tuberías especiales y almacenarse en depósitos. Al igual que con el agua, hay recipientes (bidones, barriles) en los que el líquido puede almacenarse y transportarse.

También es posible conectar varios depósitos usando las tuberías amarillas y conectores. Sin embargo, los depósitos deben tener el mismo contenido y siempre debe haber al menos una tubería amarilla entre el depósito, la bomba y la tubería distribuidora.

Por ejemplo, no es posible conectar dos depósitos directamente a una tubería distribuidora.

El rellenador de líquidos se usa para transferir líquidos de recipientes a depósitos. El plano muestra cómo los bidones o barriles con líquidos son empujados hacia un rellenador de líquidos mediante empujadores. El recipiente se vacía en el rellenador de líquidos y el líquido se dirige hacia abajo al depósito.

El rellenador de líquidos también puede colocarse debajo de un depósito para vaciarlo.

[ta3_tank|plan]


### Depósito TA3

Los líquidos pueden almacenarse en un depósito. Un depósito puede llenarse o vaciarse usando una bomba. Para ello, la bomba debe conectarse al depósito mediante una tubería (tuberías amarillas).

Un depósito también puede llenarse o vaciarse manualmente haciendo clic en el depósito con un recipiente de líquido lleno o vacío (barril, bidón). Cabe señalar que los barriles solo pueden llenarse o vaciarse completamente. Si, por ejemplo, hay menos de 10 unidades en el depósito, este resto debe retirarse con bidones o bombearse hasta vaciarlo.

Un depósito TA3 puede contener 1000 unidades o 100 barriles de líquido.

[ta3_tank|image]


### Bomba TA3

La bomba puede usarse para bombear líquidos de depósitos o recipientes a otros depósitos o recipientes. Debe observarse la dirección de la bomba (flecha). Las líneas y conectores amarillos también permiten colocar varios depósitos a cada lado de la bomba. Sin embargo, los depósitos deben tener el mismo contenido.

La bomba TA3 bombea 4 unidades de líquido cada dos segundos.

Nota 1: La bomba no debe colocarse directamente junto al depósito. Siempre debe haber al menos un trozo de tubería amarilla entre ellos.

[ta3_pump|image]


### Rellenador de Líquidos TA

El rellenador de líquidos se usa para transferir líquidos entre recipientes y depósitos.

- Si el rellenador de líquidos se coloca debajo de un depósito y se introducen barriles vacíos en el rellenador de líquidos con un empujador o a mano, el contenido del depósito se transfiere a los barriles y los barriles pueden retirarse de la salida
- Si el rellenador de líquidos se coloca sobre un depósito y se introducen recipientes llenos en el rellenador de líquidos con un empujador o a mano, el contenido se transfiere al depósito y los recipientes vacíos pueden retirarse en el lado de salida

Cabe señalar que los barriles solo pueden llenarse o vaciarse completamente. Si, por ejemplo, hay menos de 10 unidades en el depósito, este resto debe retirarse con bidones o bombearse hasta vaciarlo.

[ta3_filler|image]

### Tubería TA4

Las tuberías amarillas se usan para la transmisión de gas y líquidos.
La longitud máxima de la tubería es de 100 m.

[ta3_pipe|image]

### Bloques de Entrada de Tubería en Pared TA3

Los bloques sirven como aperturas en la pared para tubos, de modo que no queden agujeros abiertos.

[ta3_pipe_wall_entry|image]

### Válvula TA

Hay una válvula para las tuberías amarillas, que puede abrirse y cerrarse con un clic del ratón.
La válvula también puede controlarse mediante comandos on/off.

[ta3_valve|image]


## Producción de Petróleo

Para poder ejecutar tus generadores y hornos con petróleo, primero debes buscar petróleo, construir una torre de perforación y luego extraerlo.
Para esto se usan el explorador de petróleo TA3, la caja de perforación de petróleo TA3 y el cabezal de bombeo TA3.

[techage_ta3|image]


### Explorador de Petróleo TA3

Puedes buscar petróleo con el explorador de petróleo. Para ello, coloca el bloque en el suelo y haz clic derecho para iniciar la búsqueda. El explorador de petróleo puede usarse sobre el suelo y bajo tierra a todas las profundidades.
La salida del chat te muestra la profundidad a la que se buscó petróleo y cuánto petróleo (petróleo) se encontró.
Puedes hacer clic en el bloque varias veces para buscar petróleo en áreas más profundas. Los yacimientos de petróleo varían en tamaño de 4.000 a 20.000 unidades.

Si la búsqueda no tuvo éxito, tienes que mover el bloque unos 16 m más lejos.
El explorador de petróleo siempre busca petróleo en todo el bloque de mapa y debajo, en el que fue colocado. Por lo tanto, una nueva búsqueda en el mismo bloque de mapa (campo de 16x16) no tiene sentido.

Si se encuentra petróleo, se muestra la ubicación para la torre de perforación. Debes erigir la torre de perforación dentro del área mostrada; lo mejor es marcar el lugar con un cartel y proteger toda el área contra jugadores ajenos.

No te rindas demasiado pronto buscando petróleo. Si tienes mala suerte, puede tardar mucho tiempo en encontrar un pozo de petróleo.
Tampoco tiene sentido buscar en un área que otro jugador ya ha buscado. La probabilidad de encontrar petróleo en cualquier lugar es la misma para todos los jugadores.

El explorador de petróleo siempre puede usarse para buscar petróleo.

[ta3_oilexplorer|image]


### Caja de Perforación de Petróleo TA3

La caja de perforación de petróleo debe colocarse en la posición indicada por el explorador de petróleo. Perforar en busca de petróleo en otro lugar no tiene sentido.
Si se hace clic en el botón de la caja de perforación, la torre de perforación se erige encima de la caja. Esto tarda unos segundos.
La caja de perforación tiene 4 lados; en ENTRADA la tubería de perforación debe entregarse mediante empujador y en SALIDA el material de perforación debe retirarse. La caja de perforación debe suministrarse con energía a través de uno de los otros dos lados.

La caja de perforación perfora hasta el yacimiento de petróleo (1 metro en 16 s) y requiere 16 ku de electricidad.
Una vez que se ha alcanzado el yacimiento de petróleo, la torre de perforación puede desmantelarse y la caja retirarse.

[ta3_drillbox|image]


### Cabezal de Bombeo de Petróleo TA3

La bomba de petróleo (cabezal de bombeo) debe colocarse ahora en el lugar de la caja de perforación. La bomba de petróleo también requiere electricidad (16 ku) y suministra una unidad de petróleo cada 8 s. El petróleo debe recogerse en un depósito. Para ello, la bomba de petróleo debe conectarse al depósito mediante tuberías amarillas.
Una vez que se ha bombeado todo el petróleo, la bomba de petróleo también puede retirarse.

[ta3_pumpjack|image]


### Tubería de Perforación TA3

La tubería de perforación es necesaria para la perforación. Se necesitan tantos elementos de tubería de perforación como la profundidad especificada para el yacimiento de petróleo. La tubería de perforación es inútil después de la perforación, pero tampoco puede desmantelarse y permanece en el suelo. Sin embargo, hay una herramienta para retirar los bloques de tubería de perforación (-> Herramientas -> Llave de tubería de perforación TA3).

[ta3_drillbit|image]


### Depósito de Petróleo

El depósito de petróleo es la versión grande del depósito TA3 (ver líquidos -> depósito TA3).

El depósito grande puede contener 4000 unidades de petróleo, pero también cualquier otro tipo de líquido.

[oiltank|image]


## Transporte de Petróleo

### Transporte de Petróleo con Carritos de Depósito

Los carritos de depósito pueden usarse para transportar petróleo desde el pozo de petróleo hasta la planta de procesamiento. Un carrito de depósito puede llenarse o vaciarse directamente usando bombas. En ambos casos, las tuberías amarillas deben conectarse al carrito de depósito desde arriba.

Los siguientes pasos son necesarios:

- Coloca el carrito de depósito frente al bloque tope del raíl. El bloque tope no debe estar todavía programado con un tiempo para que el carrito de depósito no arranque automáticamente
- Conecta el carrito de depósito a la bomba usando tuberías amarillas
- Enciende la bomba
- Programa el tope con un tiempo (10 - 20 s)

Esta secuencia debe observarse en ambos lados (llenado / vaciado).

[tank_cart | image]

### Transporte de Petróleo con Barriles en Minecarts

Los bidones y barriles pueden cargarse en los Minecarts. Para ello, el petróleo debe transferirse primero a barriles. Los barriles de petróleo pueden empujarse directamente hacia el Minecart con un empujador y tubos (ver mapa). Los barriles vacíos, que regresan de la estación de descarga por Minecart, pueden descargarse usando una tolva, que se coloca debajo del raíl en la parada.

No es posible con la tolva tanto **descargar los barriles vacíos como cargar los barriles llenos en una parada**. La tolva descarga inmediatamente los barriles llenos. Por lo tanto, es aconsejable configurar 2 estaciones en el lado de carga y descarga y luego programar el Minecart en consecuencia usando una carrera de grabación.

El plano muestra cómo el petróleo puede bombearse a un depósito y llenarse en barriles a través de un rellenador de líquidos y cargarse en Minecarts.

Para que los Minecarts arranquen nuevamente de forma automática, los bloques tope deben configurarse con el nombre de la estación y el tiempo de espera. 5 s son suficientes para la descarga. Sin embargo, dado que los empujadores siempre entran en modo de espera durante varios segundos cuando no hay Minecart, debe ingresarse un tiempo de 15 o más segundos para la carga.

[ta3_loading|plan]

### Carrito de Depósito TA

El carrito de depósito se usa para transportar líquidos. Al igual que los depósitos, puede llenarse con bombas o vaciarse. En ambos casos, el tubo amarillo debe conectarse al carrito de depósito desde arriba.

Caben 200 unidades en el carrito de depósito.

[tank_cart | image]

### Carrito de Cofre TA

El carrito de cofre se usa para transportar objetos. Al igual que los cofres, puede llenarse o vaciarse usando un empujador.

Caben 4 pilas en el carrito de cofre.

[chest_cart | image]


## Procesamiento de Petróleo

El petróleo es una mezcla de sustancias y consta de muchos componentes. El petróleo puede descomponerse en sus componentes principales como betún, fuel-oil, nafta, gasolina y gas propano a través de una torre de destilación.
El procesamiento adicional a productos finales tiene lugar en el reactor químico.

[techage_ta31|image]


### Torre de Destilación

La torre de destilación debe montarse como en el plano en la parte superior derecha.
El betún se drena a través del bloque base. La salida está en la parte trasera del bloque base (nota la dirección de la flecha).
Los bloques de "torre de destilación" con los números: 1, 2, 3, 2, 3, 2, 3, 4 se colocan sobre este bloque básico.
El fuel-oil, la nafta y la gasolina se drenan desde las aberturas de abajo hacia arriba. El gas propano se recoge en la parte superior.
Todas las aberturas de la torre deben conectarse a depósitos.
El rehervidor debe conectarse al bloque "torre de destilación 1".

¡El rehervidor necesita electricidad (no se muestra en el plano)!

[ta3_distiller|plan]

#### Rehervidor

El rehervidor calienta el petróleo a aprox. 400 °C. Se evapora en gran medida y se alimenta a la torre de destilación para su enfriamiento.

El rehervidor requiere 14 unidades de electricidad y produce una unidad de betún, fuel-oil, nafta, gasolina y propano cada 16 s.
Para ello, el rehervidor debe suministrarse con petróleo mediante una bomba.

[reboiler|image]


## Bloques de Lógica / Conmutación

Además de los tubos para el transporte de mercancías, así como las tuberías de gas y electricidad, también existe un nivel de comunicación inalámbrica a través del cual los bloques pueden intercambiar datos entre sí. No es necesario trazar líneas para esto, la conexión entre transmisor y receptor se realiza únicamente a través del número de bloque.

**Info:** Un número de bloque es un número único que genera Techage cuando se colocan muchos bloques de Techage. El número de bloque se usa para el direccionamiento durante la comunicación entre los controladores y las máquinas de Techage. Todos los bloques que pueden participar en esta comunicación muestran el número de bloque como texto informativo si fijas el bloque con el cursor del ratón.

Los comandos que admite un bloque pueden leerse y mostrarse con la Herramienta de Información TechAge (llave inglesa).
Los comandos más simples que admiten casi todos los bloques son:

- `on` - para encender el bloque / máquina / lámpara
- `off` - para apagar el bloque / máquina / lámpara

Con la ayuda del Terminal TA3, estos comandos pueden probarse muy fácilmente. Supongamos que una lámpara de señal tiene el número 123.
Entonces con:

    cmd 123 on

la lámpara puede encenderse y con:

    cmd 123 off

la lámpara puede apagarse nuevamente. Estos comandos deben introducirse en el campo de entrada del terminal TA3.

Comandos como `on` y `off` se envían al destinatario sin que regrese una respuesta. Por lo tanto, estos comandos pueden enviarse a varios receptores al mismo tiempo, por ejemplo con un botón pulsador / interruptor, si se introducen varios números en el campo de entrada.

Un comando como `state` solicita el estado de un bloque. El bloque luego envía su estado de vuelta. Este tipo de comando confirmado solo puede enviarse a un destinatario a la vez.
Este comando también puede probarse con el terminal TA3 en un empujador, por ejemplo:

    cmd 123 state

Las posibles respuestas del empujador son:
- `running` -> estoy trabajando
- `stopped` -> apagado
- `standby` -> nada que hacer porque el inventario de origen está vacío
- `blocked` -> no puedo hacer nada porque el inventario de destino está lleno

Este estado y otra información también se muestran cuando se hace clic en el bloque con la llave inglesa.

[ta3_logic|image]


### Botón / Interruptor TA3

El botón/interruptor envía comandos `on` / `off` a los bloques que han sido configurados mediante los números.
El botón/interruptor puede configurarse como botón o como interruptor. Si se configura como botón, puede establecerse el tiempo entre los comandos `on` y `off`. Con el modo de funcionamiento "botón on" solo se envía un comando `on` y ningún comando `off`.

La casilla de verificación "público" puede usarse para establecer si el botón puede ser usado por todos (marcado) o solo por el propio propietario (no marcado).

Nota: Con el programador, los números de bloque pueden recopilarse y configurarse fácilmente.

[ta3_button|image]

### Convertidor de Comandos TA3

Con el convertidor de comandos TA3, los comandos `on` / `off` pueden convertirse en otros comandos, y el reenvío puede prevenirse o retrasarse.
Deben introducirse el número del bloque de destino o los números de los bloques de destino, los comandos a enviar y los tiempos de retardo en segundos. Si no se introduce ningún comando, no se envía nada.

Los números también pueden programarse usando el programador Techage.

[ta3_command_converter|image]

### Flip-Flop TA3

El flip-flop TA3 cambia su estado con cada comando `on` recibido. Los comandos `off` recibidos se ignoran. Dependiendo del cambio de estado, se envían alternamente comandos `on` / `off`. Deben introducirse el número del bloque de destino o los números de los bloques de destino. Los números también pueden programarse usando el programador Techage.

Por ejemplo, las lámparas pueden encenderse y apagarse con la ayuda de botones.

[ta3_flipflop|image]

### Bloque Lógico TA3

El bloque lógico TA3 puede programarse de tal manera que uno o más comandos de entrada se vinculen a un comando de salida y se envíen. Este bloque puede por lo tanto reemplazar varios elementos lógicos como AND, OR, NOT, XOR, etc.
Los comandos de entrada para el bloque lógico son comandos `on` / `off`.
Los comandos de entrada se referencian mediante el número, p. ej. `1234` para el comando del remitente con el número 1234.
Lo mismo se aplica a los comandos de salida.

Una regla tiene la siguiente estructura:

```
<salida> = on/off si <expresión-entrada> es verdadera
```

`<salida>` es el número de bloque al que debe enviarse el comando.
`<expresión-entrada>` es una expresión booleana donde se evalúan los números de entrada.



**Ejemplos para la expresión de entrada**

Negar señal (NOT):

    1234 == off

AND lógico:

    1234 == on and 2345 == on

OR lógico:

    1234 == on or 2345 == on

Los siguientes operadores están permitidos: `and`   `or`   `on`   `off`   `me`   `==`   `~=`   `(`   `)`

Si la expresión es verdadera, se envía un comando al bloque con el número `<salida>`.
Pueden definirse hasta cuatro reglas, donde todas las reglas siempre se comprueban cuando se recibe un comando.
El tiempo de procesamiento interno para todos los comandos es de 100 ms.

El número de nodo propio puede referenciarse usando la palabra clave `me`. Esto hace posible que el bloque se envíe un comando a sí mismo (función flip-flop).

El tiempo de bloqueo define una pausa después de un comando, durante la cual el bloque lógico no acepta ningún otro comando externo. Los comandos recibidos durante el período de bloqueo se descartan. El tiempo de bloqueo puede definirse en segundos.

[ta3_logic|image]


### Repetidor TA3

El repetidor envía la señal recibida a todos los números configurados.
Esto puede tener sentido, por ejemplo, si quieres controlar muchos bloques al mismo tiempo. El repetidor puede configurarse con el programador, lo que no es posible con todos los bloques.

[ta3_repeater|image]


### Secuenciador TA3

El secuenciador puede enviar una serie de comandos `on` / `off`, donde el intervalo entre los comandos debe especificarse en segundos. Puedes usarlo para hacer parpadear una lámpara, por ejemplo.
Se pueden configurar hasta 8 comandos, cada uno con el número de bloque de destino y pendiente el siguiente comando.
El secuenciador repite los comandos indefinidamente cuando se establece "Ejecutar indefinidamente".
Si no se selecciona nada, solo se espera el tiempo especificado en segundos.

[ta3_sequencer|image]


### Temporizador TA3

El temporizador puede enviar comandos controlados por tiempo. Para cada línea de comando pueden especificarse la hora, el/los número(s) de destino y el propio comando. Esto significa que las lámparas pueden encenderse por la tarde y apagarse nuevamente por la mañana.

[ta3_timer|image]


### Terminal TA3

El terminal se usa principalmente para probar la interfaz de comandos de otros bloques (ver "Bloques de lógica / conmutación"), así como para la automatización de sistemas usando el lenguaje de programación BASIC.
También puedes asignar comandos a teclas y usar el terminal de forma productiva.

    set <num-botón> <texto-botón> <comando>

Con `set 1 ON cmd 123 on`, por ejemplo, la tecla de usuario 1 puede programarse con el comando `cmd 123 on`. Si se presiona la tecla, el comando se envía y la respuesta se muestra en la pantalla.

El terminal tiene los siguientes comandos locales:
- `clear` limpiar pantalla
- `help` mostrar una página de ayuda
- `pub` cambiar a modo público
- `priv` cambiar a modo privado

En modo privado, el terminal solo puede ser usado por jugadores que puedan construir en esa ubicación, es decir, que tengan derechos de protección.

En modo público, todos los jugadores pueden usar las teclas preconfiguradas.

Puedes cambiar al modo BASIC usando el menú de la llave inglesa. Puedes encontrar más información sobre el modo BASIC [aquí](https://github.com/joe7575/techage/tree/master/manuals/ta3_terminal.md)

[ta3_terminal|image]


### Monitor CRT TA3

El monitor CRT está disponible para complementar el terminal TA3 en modo BASIC. Este puede mostrar la salida del programa BASIC.
El monitor también puede usarse como pantalla para otros bloques que generan texto (p. ej. el controlador Lua).
El monitor tiene un menú de llave inglesa que puede usarse para establecer la resolución del monitor y el color del texto.
La resolución puede establecerse en el rango de 16x8 a 40x20 caracteres x líneas.
La tasa de actualización del monitor depende directamente de la resolución y es de un segundo a 16x8 y alrededor de 6 segundos a 40x20.

Los comandos para el control en modo BASIC:

```BASIC
10 DCLR(num)              ' Limpiar la pantalla con el número 'num'.
20 DPUTS(num, row, text)  ' Salida de texto a la pantalla en la línea 'row' (1..n).
                          ' El valor 0 para 'row' significa que el texto se
                          ' añade después de la última línea.
```

Los comandos para el control mediante el controlador Lua:

```lua
$clear_screen(num)        -- Limpiar la pantalla con el número 'num'.
$display(num, row, text)  -- Salida de texto a la pantalla en la línea 'row' (1..n).
                          -- El valor 0 para 'row' significa que el texto se
                          -- añade después de la última línea.
```

[ta3_monitor|image]

### Lámpara de Color TechAge

La lámpara de señal puede encenderse o apagarse con el comando `on` / `off`. Esta lámpara no necesita electricidad y puede colorearse con la herramienta de aerógrafo del mod "Unified Dyes" y mediante comandos Lua/Beduino.

Con el comando de chat `/ta_color` se muestra la paleta de colores con los valores para los comandos Lua/Beduino y con `/ta_send color <num>` el color puede cambiarse.

[ta3_colorlamp|image]


### Bloques de Puerta/Verja

Con estos bloques puedes realizar puertas y verjas que pueden abrirse mediante comandos (los bloques desaparecen) y cerrarse nuevamente. Se requiere un controlador de puerta para cada verja o puerta.

La apariencia de los bloques puede ajustarse a través del menú del bloque.
Esto permite realizar puertas secretas que solo se abren para ciertos jugadores (con la ayuda del detector de jugador).

[ta3_doorblock|image]

### Controlador de Puerta TA3

El controlador de puerta se usa para controlar los bloques de puerta/verja TA3. Con el controlador de puerta, deben introducirse los números de los bloques de puerta/verja. Si se envía un comando `on` / `off` al controlador de puerta, este abre/cierra la puerta o verja.

[ta3_doorcontroller|image]

### Controlador de Puerta II TA3

El Controlador de Puerta II puede retirar y colocar muchos tipos de bloques. Para enseñar al Controlador de Puerta II, presiona el botón "Grabar". Luego, haz clic en todos los bloques que deben ser parte de la puerta/verja. Luego, presiona el botón "Hecho". Se pueden seleccionar hasta 16 bloques.

Al presionar el botón "Intercambiar" se retiran los bloques de las posiciones enseñadas y se guardan en el inventario del controlador.

Los bloques pueden reasignarse a las posiciones vacantes. Al presionar el botón "Intercambiar" nuevamente se intercambian los bloques con los bloques del inventario.

Al presionar el botón "Restablecer" se restablecen todos los bloques a su estado inicial después de la enseñanza. Esto completa la fase de enseñanza y el Controlador de Puerta II puede controlarse mediante comandos.

Cada posición o ranura tiene dos estados:

1) El bloque está en el mundo (cualquier bloque de intercambio existente está en el inventario) = Estado inicial
2) El bloque está en el inventario (cualquier bloque de intercambio existente está en el mundo) = Estado de intercambio

- Usando el comando `on` / `off`, todos los bloques en las posiciones aprendidas se intercambian con los del inventario.
- Usando el comando `reset`, todos los bloques se restablecen a su estado inicial después del aprendizaje.

Para todos los comandos siguientes, el número de ranura del inventario también debe pasarse como parámetro (1..16).

- Usando el comando `exc`, un bloque en el mundo se intercambia con el bloque del inventario.
- El comando `to1` intercambia un bloque del inventario con el bloque en el mundo, siempre que la posición estuviera en el estado 2 (Estado de intercambio).
- El comando `to2` intercambia un bloque del mundo con el bloque del inventario, siempre que la posición estuviera en el estado 1 (Estado inicial).
- El comando `get` devuelve el estado de la posición, es decir, los valores 1 o 2.

[ta3_doorcontroller|image]

### Bloque de Sonido TA3

Se pueden reproducir diferentes sonidos con el bloque de sonido. Todos los sonidos de los Mods Techage, Signs Bot, Hyperloop, Unified Inventory, TA4 Jetpack y Minetest Game están disponibles.

Los sonidos pueden seleccionarse y reproducirse a través del menú y mediante comando.

- Comando `on` para reproducir un sonido
- Comando `sound <idx>` para seleccionar un sonido mediante el índice
- Comando `gain <volumen>` para ajustar el volumen mediante el valor `<volumen>` (1 a 5).

[ta3_soundblock|image]

### Convertidor Mesecons TA3

El convertidor Mesecons se usa para convertir comandos on/off de Techage en señales Mesecons y viceversa.
Para ello, deben introducirse uno o más números de nodo y el convertidor con bloques Mesecons debe conectarse mediante cables Mesecons. El convertidor Mesecons también puede configurarse con el programador.
El convertidor Mesecons acepta hasta 5 comandos por segundo; se apaga con cargas más altas.

**¡Este nodo solo existe si el mod mesecons está activo!**

[ta3_mesecons_converter|image]


## Detectores

Los detectores escanean sus alrededores y envían un comando `on` cuando se reconoce la búsqueda.

[ta3_nodedetector|image]


### Detector de Objetos TA3

El detector es un bloque de tubo especial que detecta cuando los objetos pasan por el tubo. Para ello, debe conectarse a tubos en ambos lados. Si los objetos se empujan hacia el detector con un empujador, se pasan automáticamente.
Envía un `on` cuando se reconoce un objeto, seguido de un `off` un segundo después.
Luego se bloquean más comandos durante 8 segundos.
El tiempo de espera y los objetos que deben activar un comando pueden configurarse usando el menú de la llave inglesa.

[ta3_detector|image]


### Detector de Carrito TA3

El detector de carrito envía un comando `on` si ha reconocido un carrito (Minecart) directamente frente a él. Además, el detector también puede reiniciar el carrito cuando se recibe un comando `on`.

El detector también puede programarse con su propio número. En este caso, empuja todos los vagones que se detienen cerca de él (un bloque en todas las direcciones).

[ta3_cartdetector|image]


### Detector de Nodo TA3

El detector de nodo envía un comando `on` si detecta que los nodos (bloques) aparecen o desaparecen frente a él, pero debe configurarse en consecuencia. Después de devolver el detector al estado estándar (bloque gris), se envía un comando `off`. Los bloques válidos son todos los tipos de bloques y plantas, pero no animales o jugadores. El rango del sensor es de 3 bloques / metro en la dirección de la flecha.

[ta3_nodedetector|image]


### Detector de Jugador TA3

El detector de jugador envía un comando `on` si detecta un jugador dentro de 4 m del bloque. Si el jugador abandona el área nuevamente, se envía un comando `off`.
Si la búsqueda debe limitarse a jugadores específicos, estos nombres de jugador también pueden introducirse.

[ta3_playerdetector|image]

### Detector de Luz TA3

El detector de luz envía un comando `on` si el nivel de luz del bloque superior supera un cierto nivel, que puede establecerse a través del menú de clic derecho.
Si tienes un Controlador Lua TA4, puedes obtener el nivel de luz exacto con $get_cmd(num, 'light_level')

[ta3_lightdetector|image]

## Máquinas TA3

TA3 tiene las mismas máquinas que TA2, solo que estas son más potentes y requieren electricidad en lugar de accionamiento por eje.
Por lo tanto, a continuación solo se dan los datos técnicos diferentes.

[ta3_grinder|image]


### Empujador TA3

La función corresponde a la de TA2.
La capacidad de procesamiento es de 6 objetos cada 2 s.

[ta3_pusher|image]


### Distribuidor TA3

La función del distribuidor TA3 corresponde a la de TA2.
La capacidad de procesamiento es de 12 objetos cada 4 s.

[ta3_distributor|image]


### Fabricante Automático TA3

La función corresponde a la de TA2.
La capacidad de procesamiento es de 2 objetos cada 4 s. El fabricante automático requiere 6 ku de electricidad.

[ta3_autocrafter|image]


### Fábrica Electrónica TA3

La función corresponde a la de TA2, solo que aquí se producen chips WLAN TA4.
La capacidad de procesamiento es de un chip cada 6 s. El bloque requiere 12 ku de electricidad para esto.

[ta3_electronicfab|image]


### Cantera TA3

La función corresponde a la de TA2.
La profundidad máxima es de 40 metros. La cantera requiere 12 ku de electricidad.

[ta3_quarry|image]


### Criba de Grava TA3

La función corresponde a la de TA2.
La capacidad de procesamiento es de 2 objetos cada 4 s. El bloque requiere 4 ku de electricidad.

[ta3_gravelsieve|image]


### Enjuagador de Grava TA3

La función corresponde a la de TA2.
La probabilidad también es la misma que para TA2. El bloque también requiere 3 ku de electricidad.
Pero en contraste con TA2, el estado del bloque TA3 puede leerse (controlador).

[ta3_gravelrinser|image]


### Trituradora TA3

La función corresponde a la de TA2.
La capacidad de procesamiento es de 2 objetos cada 4 s. El bloque requiere 6 ku de electricidad.

[ta3_grinder|image]

### Inyector TA3

El inyector es un empujador TA3 con propiedades especiales. Tiene un menú para la configuración. Aquí pueden configurarse hasta 8 objetos. Solo toma estos objetos de un cofre para pasarlos a máquinas con recetas (fabricante automático, horno industrial y fábrica electrónica).

Al pasar, solo se usa una posición en el inventario en la máquina de destino. Si, por ejemplo, solo se configuran las primeras tres entradas en el inyector, solo se usan las primeras tres ubicaciones de almacenamiento en el inventario de la máquina. Para que se evite un desbordamiento en el inventario de la máquina.

El inyector también puede cambiarse a "modo de extracción". Entonces solo extrae objetos del cofre desde las posiciones que están definidas en la configuración del inyector. En este caso, el tipo de objeto y la posición deben coincidir. Esto permite vaciar entradas específicas del inventario de un cofre.

La capacidad de procesamiento es de hasta 8 veces un objeto cada 4 segundos.

[ta3_injector|image]

### Ventana de Observación TA3

La ventana de observación es un bloque que funciona como una ventana hacia un tubo. Puede usarse para hacer visibles los objetos en los tubos.
El bloque de ventana debe colocarse entre dos tubos. No se permiten dos o más bloques de ventana seguidos. La animación de objetos
solo ocurre cuando un jugador está cerca (<=8 bloques). Sin embargo, los objetos se pasan independientemente de la visibilidad.

## Herramientas

### Herramienta de Información Techage

La Herramienta de Información Techage (llave inglesa de extremo abierto) tiene varias funciones. Muestra la hora, posición, temperatura y bioma cuando se hace clic en un bloque desconocido.
Si haces clic en un bloque TechAge con interfaz de comandos, se mostrarán todos los datos disponibles (ver también "Bloques de lógica / conmutación").

Con Shift + clic derecho se puede abrir un menú ampliado para algunos bloques. Dependiendo del bloque, aquí pueden consultarse datos adicionales o realizarse configuraciones especiales. En el caso de un generador, por ejemplo, la curva de carga/apagado puede programarse.

[ta3_end_wrench|image]

### Programador TechAge

Con el programador, los números de bloque pueden recopilarse de varios bloques con un clic derecho y escribirse en un bloque como un botón / interruptor con un clic izquierdo.
Si haces clic en el aire, la memoria interna se borra.

[ta3_programmer|image]

### Paleta TechAge / Paleta

La paleta se usa para enlucir cables eléctricos. Ver también "cable eléctrico TA".

[ta3_trowel|image]

### Llave de Tubería de Perforación TA3

Esta herramienta puede usarse para retirar los bloques de tubería de perforación si, por ejemplo, un túnel debe pasar por allí.

[ta3_drill_pipe_wrench|image]

### Destornillador Techage

El Destornillador Techage sirve como reemplazo del destornillador normal. Tiene las siguientes funciones:

- Clic izquierdo: girar el bloque hacia la izquierda
- Clic derecho: girar el lado visible del bloque hacia arriba
- Shift + clic izquierdo: guardar la alineación del bloque en el que se hizo clic
- Shift + clic derecho: aplicar la alineación guardada al bloque en el que se hizo clic

[ta3_screwdriver|image]

### Destornillador Inalámbrico TechAge

El Destornillador Inalámbrico TechAge se usa para retirar y recolocar bloques Techage sin que estos bloques pierdan su número de bloque o se les asigne un nuevo número al colocarlos. Esto es útil, por ejemplo, para las canteras, ya que a menudo deben moverse.

- Botón izquierdo: Retirar un bloque
- Botón derecho: Colocar un bloque

El bloque que fue retirado previamente con el Destornillador Inalámbrico y que va a colocarse nuevamente debe estar en la ranura 1 de la barra de acceso rápido (la ranura más a la izquierda de la barra de acceso rápido).

[techage:cordless_screwdriver|image]
