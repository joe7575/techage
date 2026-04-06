# TA5: Futuro

Máquinas para superar el espacio y el tiempo, nuevas fuentes de energía y otros logros dan forma a tu vida.

Se requieren puntos de experiencia para la fabricación y el uso de máquinas y bloques TA5. Estos solo pueden obtenerse usando el colisionador de TA4.

[techage_ta5|image]

## Fuentes de Energía

### Reactor de Fusión TA5

La fusión nuclear significa la unión de dos núcleos atómicos. Dependiendo de la reacción, pueden liberarse grandes cantidades de energía. Las fusiones nucleares en las que se libera energía ocurren en forma de reacciones en cadena. Son la fuente de energía de las estrellas, incluido nuestro sol, por ejemplo. Un reactor de fusión convierte la energía liberada durante la fusión nuclear controlada en electricidad.

**¿Cómo funcionan los reactores de fusión?**

Un reactor de fusión funciona según el principio clásico de una central eléctrica térmica: el agua se calienta y acciona una turbina de vapor, cuya energía cinética es convertida en electricidad por un generador.

Una central de fusión inicialmente requiere una gran cantidad de energía, ya que debe generarse un plasma. "Plasma" es el nombre dado al cuarto estado de la materia, después del sólido, líquido y gaseoso. Esto requiere mucha electricidad. Solo a través de esta extrema concentración de energía se enciende la reacción de fusión y el calor emitido se usa para generar electricidad a través del intercambiador de calor. El generador entonces suministra 800 ku de electricidad.

El plano de la derecha muestra una sección a través del reactor de fusión.

Se requieren 60 puntos de experiencia para operar el reactor de fusión. El reactor de fusión debe construirse completamente en un área de bloque de carga forzada.

[ta5_fusion_reactor|plan]

#### Magneto del Reactor de Fusión TA5

Se necesitan un total de 60 Magnetos del Reactor de Fusión TA5 para configurar el reactor de fusión. Estos forman el anillo en el que se forma el plasma. Los Magnetos del Reactor de Fusión TA5 requieren energía y tienen dos puertos para el enfriamiento.

Hay dos tipos de magnetos, por lo que todos los lados del magneto que dan al anillo de plasma también pueden protegerse con un escudo térmico.

Con los magnetos de esquina en el interior del anillo, un lado de conexión está cubierto (energía o enfriamiento) y por lo tanto no puede conectarse. Esto no es técnicamente factible y por lo tanto no tiene influencia en la función del reactor de fusión.

[ta5_magnet|image]

#### Bomba TA5

La bomba es necesaria para llenar el circuito de enfriamiento con isobutano. Se requieren alrededor de 350 unidades de isobutano.

La bomba tiene dos lados de conexión:

- Lado izquierdo: conector amarillo (GasPipe) – conecta aquí el depósito de isobutano
- Lado derecho: conector azul (LiquidPipe) – conecta aquí el circuito de enfriamiento

Por defecto, la bomba mueve el líquido de izquierda (amarillo) a derecha (azul), es decir, del depósito al circuito de enfriamiento. La dirección de la bomba puede cambiarse a "inversa" a través del menú de la llave inglesa.

Nota: La bomba TA5 solo puede usarse para llenar el circuito de enfriamiento; bombear el refrigerante no es posible. Por lo tanto, la bomba no debe encenderse hasta que los magnetos estén correctamente colocados y todas las líneas de energía y enfriamiento estén conectadas.

Si la bomba muestra "bloqueada", el destino está lleno o no conectado.

[ta5_pump|image]

#### Intercambiador de Calor TA5

El Intercambiador de Calor TA5 es necesario para convertir el calor generado en el reactor de fusión primero en vapor y luego en electricidad. El propio Intercambiador de Calor requiere 5 ku de electricidad. La estructura es similar al Intercambiador de Calor del almacenamiento de energía de TA4.

El Intercambiador de Calor consta de 3 partes (de abajo hacia arriba: 1, 2, 3). Las partes 1 y 3 tienen cada una dos lados de conexión:

- Lado derecho: conector amarillo – conecta a la turbina (parte 1) o al enfriador (parte 3)
- Lado izquierdo de la parte 1: conector azul – circuito de enfriamiento al anillo de magnetos inferior (56 magnetos)
- Lado izquierdo de la parte 3: conector verde – circuito de enfriamiento al anillo de magnetos superior (52 magnetos)

El circuito de enfriamiento puede verificarse para comprobar su integridad usando el botón de inicio en el intercambiador de calor (parte 2), incluso si aún no se ha llenado refrigerante. Posibles mensajes de error:

- "Turbine error" / "Cooler error": Turbina o enfriador no conectados mediante tubería amarilla
- "Blue/Green pipe connection error": Magnetos no conectados correctamente mediante tuberías azules/verdes
- "Blue/Green pipe coolant missing": Magnetos aún no llenados con isobutano (6 unidades por magneto)

[ta5_heatexchanger|plan]

#### Controlador del Reactor de Fusión TA5

El reactor de fusión se enciende a través del Controlador del Reactor de Fusión TA5. El reactor de fusión y por lo tanto el controlador requiere 400 ku de electricidad para mantener el plasma.

**Secuencia de arranque:**

1. Todos los magnetos deben estar correctamente colocados y llenados con isobutano
2. El circuito de enfriamiento (tuberías azules y verdes) y las tuberías de vapor (tuberías amarillas) deben estar completamente conectados
3. Primero, enciende el Intercambiador de Calor (parte 2)
4. Luego enciende el Controlador
5. Tarda unos 2 minutos para que el reactor alcance los 80° y produzca vapor/electricidad

**Importante:** Tanto el Intercambiador de Calor como el Controlador deben estar funcionando al mismo tiempo. El Controlador calienta los magnetos (inc_power), el Intercambiador de Calor los enfría (dec_power). Sin que ambas partes funcionen juntas, no se alcanzará la temperatura de funcionamiento.

Posibles mensajes de error del Controlador:

- "Magnet detection error": No todos los 56 magnetos son accesibles mediante cable eléctrico
- "Plasma ring shape error": El interior del anillo de plasma no está despejado (aire)
- "Shell shape error": La carcasa alrededor de los magnetos está incompleta (muestra cuántos magnetos tienen carcasa completa)
- "Nucleus detection error": Núcleo faltante o no colocado correctamente
- "Cooling failed": El Intercambiador de Calor no está funcionando o los magnetos no se están enfriando

[ta5_fr_controller|image]

#### Carcasa del Reactor de Fusión TA5

Todo el reactor debe estar rodeado por una carcasa que absorba la enorme presión que los magnetos ejercen sobre el plasma y proteja el entorno de la radiación. Sin esta carcasa, el reactor no puede iniciarse. Con la Paleta TechAge, los cables eléctricos y las tuberías de enfriamiento del reactor de fusión también pueden integrarse en la carcasa.

[ta5_fr_shell|image]

#### Núcleo del Reactor de Fusión TA5

El núcleo debe estar en el centro del reactor. Ver ilustración bajo "Reactor de Fusión TA5". La Paleta TechAge también es necesaria para esto.

[ta5_fr_nucleus|image]

## Almacenamiento de Energía

### Almacenamiento Híbrido TA5 (planificado)

## Bloques Lógicos

## Transporte y Tráfico

### Controlador de Vuelo TA5

El Controlador de Vuelo TA5 es similar al Controlador de Movimiento TA4. A diferencia del Controlador de Movimiento TA4, varios movimientos pueden combinarse en una ruta de vuelo. Esta ruta de vuelo puede definirse en el campo de entrada usando varias entradas x,y,z (un movimiento por línea). La ruta de vuelo se verifica y guarda a través de "Guardar". En caso de error, se emite un mensaje de error.

Con el botón "Probar", la ruta de vuelo con las coordenadas absolutas se emite para su verificación en el chat.

La distancia máxima para toda la distancia de vuelo es de 1500 m. Se pueden entrenar hasta 32 bloques.

El uso del Controlador de Vuelo TA5 requiere 40 puntos de experiencia.

**Modo teletransporte**

Si el "Modo Teletransporte" está habilitado, un jugador también puede moverse sin bloques. Para ello, la posición de inicio debe configurarse usando el botón "Grabar". Solo puede configurarse una posición aquí. El jugador que debe moverse debe estar en esa posición.

[ta5_flycontroller|image]

### Cofre Hyperloop TA5

El Cofre Hyperloop TA5 permite transportar objetos a través de una red Hyperloop.

El Cofre Hyperloop TA5 debe colocarse en una Unión Hyperloop. El cofre tiene un menú especial con el que puedes emparejar dos cofres. Los objetos que están en el cofre se teletransportan a la estación remota. El cofre también puede llenarse/vaciarse con un empujador.

Para el emparejamiento primero debes ingresar un nombre para el cofre en un lado, luego puedes seleccionar este nombre para el otro cofre y así conectar los dos bloques.

El uso del Cofre Hyperloop TA5 requiere 15 puntos de experiencia.

[ta5_chest|image]

### Depósito Hyperloop TA5

El Depósito Hyperloop TA5 permite transportar líquidos a través de una red Hyperloop.

El Depósito Hyperloop TA5 debe colocarse en una Unión Hyperloop. El depósito tiene un menú especial con el que puedes emparejar dos depósitos. Los líquidos en el depósito se teletransportarán a la estación remota. El depósito también puede llenarse/vaciarse con una bomba.

Para el emparejamiento primero debes ingresar un nombre para el depósito en un lado, luego puedes seleccionar este nombre para el otro depósito y así conectar los dos bloques.

El uso del Depósito Hyperloop TA5 requiere 15 puntos de experiencia.

[ta5_tank|image]



## Bloques de Teletransporte

Los bloques de teletransporte permiten transferir objetos entre dos bloques de teletransporte sin necesidad de una tubería entre ellos. Para emparejar los bloques, primero debes ingresar un nombre para el bloque en un lado, luego puedes seleccionar este nombre para el otro bloque y así conectar los dos bloques. El emparejamiento solo puede realizarlo un jugador (se verifica el nombre del jugador) y debe completarse antes de que se reinicie el servidor. De lo contrario, los datos de emparejamiento se perderán.

El mapa de la derecha muestra cómo pueden usarse los bloques.

[ta5_teleport|plan]

### Bloque de Teletransporte de Objetos TA5

Estos bloques de teletransporte permiten la transferencia de objetos y así reemplazan un tubo. Se pueden salvar distancias de hasta 500 bloques.

Cada bloque de teletransporte requiere 12 ku de electricidad.

Se requieren 30 puntos de experiencia para usar los bloques de teletransporte.

[ta5_tele_tube|image]

### Bloque de Teletransporte de Líquidos TA5

Estos bloques de teletransporte permiten la transferencia de líquidos y así reemplazan una tubería. Se pueden salvar distancias de hasta 500 bloques.

Cada bloque de teletransporte requiere 12 ku de electricidad.

Se requieren 30 puntos de experiencia para usar los bloques de teletransporte.

[ta5_tele_pipe|image]

### Bloques de Teletransporte Hyperloop (planificado)

Los Bloques de Teletransporte Hyperloop permiten la construcción de una red Hyperloop sin tubos Hyperloop.

El uso de los Bloques de Teletransporte Hyperloop requiere 60 puntos de experiencia.



## Digitalizador TA5

### Digitalizador TA5

El Digitalizador TA5 es un bloque de almacenamiento de objetos de alta capacidad que almacena digitalmente los objetos extraídos de inventarios adyacentes. Puede operar en dos modos (extracción/empuje) y maneja hasta 8 tipos de objetos diferentes con hasta 100.000 objetos por ranura.

El Digitalizador tiene una conexión de tubo en el lado derecho y también puede controlarse a través de la red Techage. En el modo de extracción, extrae hasta 50 objetos por ciclo de un cofre conectado. En el modo de empuje, empuja los objetos almacenados de vuelta a los inventarios adyacentes.

Solo pueden almacenarse objetos apilables sin metadatos y sin desgaste. Los objetos como libros firmados o herramientas desgastadas son rechazados.

El Digitalizador solo puede retirarse con un pico si el almacenamiento interno está completamente vacío. Usa el destornillador inalámbrico para retirarlo cuando esté detenido; los objetos almacenados se conservan como metadatos del objeto y se restauran automáticamente cuando el bloque se vuelve a colocar usando el destornillador inalámbrico.

El Digitalizador TA5 requiere 24 ku de energía.

Se requieren 50 puntos de experiencia para usar el Digitalizador TA5 (configurable a través de `techage_ta5_digitizer_expoints`).

El Digitalizador también puede configurarse e iniciarse usando un controlador Lua o Beduino.

Aquí están los comandos adicionales para el controlador Lua:

- `on` / `off` - Iniciar o detener el Digitalizador
- `state` - Consultar el estado actual (p. ej. "running", "stopped")
- `pull` - Iniciar en modo de extracción; extrae objetos del cofre adyacente
- `push` - Iniciar en modo de empuje; empuja los objetos almacenados al cofre adyacente
- `stop` - Detener el Digitalizador
- `config` establece el tipo de objeto objetivo (detiene el Digitalizador primero).
  Ejemplo: `$send_cmnd(NUM, "config", "default:stone")`
- `count` consulta el número total de objetos almacenados.
  Ejemplo: `$send_cmnd(NUM, "count")` devuelve un número
- `itemstring` consulta el tipo de objeto configurado.
  Ejemplo: `$send_cmnd(NUM, "itemstring")` devuelve el nombre del objeto
- `mode` obtiene o establece el modo de operación (1 = extracción, 2 = empuje).
  Ejemplo: `$send_cmnd(NUM, "mode")` devuelve 1 o 2
  Ejemplo: `$send_cmnd(NUM, "mode", 2)` establece el modo de empuje

Temas Beduino (cmnd): 65 = establecer tipo de objeto, 67 = establecer modo (1=extracción, 2=empuje)
Temas Beduino (request): 154 = recuento total de objetos, 155 = tipo de objeto configurado

[ta5_digitizer|image]

### Unidad de Control TA5

La Unidad de Control TA5 es necesaria para fabricar el Digitalizador TA5. Solo puede fabricarse en la Fábrica Electrónica TA4 y requiere 50 puntos de experiencia.

[ta5_controlunit|image]

### SSD TA5

El SSD TA5 es un componente intermedio necesario para fabricar el Digitalizador TA5. Solo puede fabricarse en la Fábrica Electrónica TA4 a partir de 16 Chips RAM TA4, 1 Oblea de Silicio TA4, 1 Lámina de Plástico y 1 Tira de Acero.

[ta5_ssd|image]

## Más Bloques/Objetos TA5

### Contenedor TA5 (planificado)

El contenedor TA5 permite empacar y desempacar sistemas Techage en otro lugar.

Se requieren 80 puntos de experiencia para usar el contenedor TA5.

### Chip de IA TA5

El Chip de IA TA5 es en parte necesario para la producción de bloques TA5. El Chip de IA TA5 solo puede fabricarse en la Fábrica Electrónica TA4. Esto requiere 10 puntos de experiencia.

[ta5_aichip|image]

### Chip de IA II TA5

El Chip de IA II TA5 es necesario para construir el Reactor de Fusión TA5. El Chip de IA II TA5 solo puede fabricarse en la Fábrica Electrónica TA4. Esto requiere 25 puntos de experiencia.

[ta5_aichip2|image]
