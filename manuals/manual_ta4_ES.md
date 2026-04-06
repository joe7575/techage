# TA4: Presente

Las fuentes de energía renovables como el viento, el sol y los biocombustibles te ayudan a salir de la era del petróleo. Con tecnologías modernas y máquinas inteligentes te lanzas hacia el futuro.

[techage_ta4|image]


## Turbina Eólica

Una turbina eólica siempre suministra electricidad cuando hay viento. No hay viento en el juego, pero el mod lo simula haciendo girar las turbinas eólicas solo por la mañana (5:00 - 9:00) y por la tarde (17:00 - 21:00). Una turbina eólica solo suministra electricidad si está instalado en un lugar adecuado.

Las plantas eólicas TA son instalaciones puramente marinas, lo que significa que deben construirse en el mar. Esto significa que las turbinas eólicas solo pueden construirse en un bioma marino (océano) y que debe haber suficiente agua y una vista despejada alrededor del mástil.

Para encontrar un lugar adecuado, haz clic en el agua con la llave inglesa (Herramienta de Información TechAge). Un mensaje de chat te mostrará si esta posición es adecuada para el mástil de la turbina eólica.

La corriente debe llevarse desde el bloque del rotor hacia abajo a través del mástil. Primero jala la línea eléctrica hacia arriba y luego "enluce" el cable eléctrico con bloques de pilares TA4. Debajo puede construirse una plataforma de trabajo. El plano de la derecha muestra la estructura en la parte superior.

La turbina eólica entrega 70 ku, pero solo 8 horas al día (ver arriba).

[ta4_windturbine|plan]


### Turbina Eólica TA4

El bloque de la turbina eólica (rotor) es el corazón de la turbina eólica. Este bloque debe colocarse en la cima del mástil. Idealmente a Y = 15, entonces te mantienes dentro de un bloque de mapa / carga forzada.
Cuando inicias la turbina, se comprueban todas las condiciones para el funcionamiento de la turbina eólica. Si se cumplen todas las condiciones, las palas del rotor (alas) aparecen automáticamente. De lo contrario, recibirás un mensaje de error.

[ta4_windturbine|image]


### Góndola de la Turbina Eólica TA4

Este bloque debe colocarse en el extremo negro del bloque de la turbina eólica.

[ta4_nacelle|image]


### Lámpara de Señal de la Turbina Eólica TA4

Esta luz parpadeante es solo para fines decorativos y puede colocarse encima del bloque de la turbina eólica.

[ta4_blinklamp|image]


### Pilar TA4

Este construye el mástil para la turbina eólica. Sin embargo, estos bloques no se colocan a mano sino que deben colocarse con la ayuda de una paleta, de modo que la línea eléctrica hacia la punta del mástil se reemplace con estos bloques (ver cable eléctrico TA).

[ta4_pillar|image]


## Sistema Solar

El sistema solar solo produce electricidad cuando luce el sol. En el juego esto ocurre cada día de juego de las 6:00 a las 18:00.
Durante este tiempo siempre está disponible la misma potencia. Después de las 18:00, los módulos solares se apagan completamente.

La temperatura del bioma es determinante para el rendimiento de los módulos solares. Cuanto más alta sea la temperatura, mayor será el rendimiento.
La temperatura del bioma puede determinarse con la Herramienta de Información Techage (llave inglesa). Normalmente fluctúa entre 0 y 100:

- a 100 está disponible la potencia completa
- a 50, está disponible la mitad de la potencia
- a 0 no hay servicio disponible

Por lo tanto, es aconsejable buscar estepas cálidas y desiertos para el sistema solar.
Las líneas aéreas están disponibles para el transporte de electricidad.
Sin embargo, también se puede producir hidrógeno, que puede transportarse y convertirse de nuevo en electricidad en el destino.

La unidad más pequeña en un sistema solar son dos módulos solares y un módulo portador. El módulo portador debe colocarse primero, los dos módulos solares a la izquierda y a la derecha junto a él (¡no encima!).

El plano de la derecha muestra 3 unidades, cada una con dos módulos solares y un módulo portador, conectados al inversor mediante cables rojos.

Los módulos solares suministran tensión continua (CC), que no puede alimentarse directamente a la red eléctrica. Por lo tanto, las unidades solares deben conectarse primero al inversor mediante el cable rojo. Este consta de dos bloques, uno para el cable rojo a los módulos solares (CC) y otro para el cable eléctrico gris a la red eléctrica (CA).

El área del mapa donde está ubicado el sistema solar debe estar completamente cargada. Esto también se aplica a la posición directamente sobre el módulo solar, porque la intensidad de la luz se mide allí regularmente. Por lo tanto, es aconsejable colocar primero un bloque de carga forzada y luego colocar los módulos dentro de esta área.

[ta4_solarplant|plan]


### Módulo Solar TA4

El módulo solar debe colocarse sobre el módulo portador. Siempre se necesitan dos módulos solares.
En un par, los módulos solares realizan hasta 3 ku, dependiendo de la temperatura.
Con los módulos solares, hay que tener cuidado de que tengan luz diurna plena y no estén sombreados por bloques o árboles. Esto puede probarse con la Herramienta de Información (llave inglesa).

[ta4_solarmodule|image]


### Módulo Portador Solar TA4

El módulo portador está disponible en dos alturas (1 m y 2 m). Ambos son funcionalmente idénticos.
Los módulos portadores pueden colocarse directamente uno al lado del otro y así conectarse para formar una fila de módulos. La conexión al inversor o a otras series de módulos debe realizarse con los cables de baja potencia rojos o las cajas de baja potencia.

[ta4_solarcarrier|image]


### Inversor Solar TA4

El inversor convierte la energía solar (CC) en corriente alterna (CA) para que pueda alimentarse a la red eléctrica.
Un inversor puede alimentar un máximo de 100 ku de electricidad, lo que corresponde a 33 módulos solares o más.

[ta4_solar_inverter|image]


### Cable de Baja Potencia TA4

El cable de baja potencia se usa para conectar filas de módulos solares al inversor. El cable no debe usarse para otros fines.

La longitud máxima del cable es de 200 m.

[ta4_powercable|image]


### Caja de Baja Potencia TA4

La caja de conexiones debe colocarse en el suelo. Solo tiene 4 conexiones (en las 4 direcciones).

[ta4_powerbox|image]


### Celda Solar de Farola TA4

Como su nombre indica, la celda solar de farola se usa para alimentar una farola. Una celda solar puede suministrar dos lámparas (1 ku). La celda solar almacena la energía solar durante el día y suministra la electricidad a la lámpara por la noche. Eso significa que la lámpara solo brilla en la oscuridad.

Esta celda solar no puede combinarse con los otros módulos solares.

[ta4_minicell|image]



## Almacenamiento de Energía Térmica

El almacenamiento de energía térmica reemplaza el bloque de batería de TA3.

El almacenamiento de energía térmica consiste en una carcasa de hormigón (bloques de hormigón) rellena de grava. Son posibles cinco tamaños del almacenamiento:

- Carcasa con 5x5x5 bloques de hormigón, rellena con 27 de grava, capacidad de almacenamiento: 22,5 kud
- Carcasa con 7x7x7 bloques de hormigón, rellena con 125 de grava, capacidad de almacenamiento: 104 kud
- Carcasa con 9x9x9 bloques de hormigón, rellena con 343 de grava, capacidad de almacenamiento: 286 kud
- Carcasa con 11x11x11 bloques de hormigón, rellena con 729 de grava, capacidad de almacenamiento: 610 kud
- Carcasa con 13x13x13 bloques de hormigón, rellena con 1331 de grava, capacidad de almacenamiento: 1112 kud

Una ventana hecha de un bloque de vidrio de obsidiana puede estar en la carcasa de hormigón. Debe colocarse bastante en el centro de la pared. A través de esta ventana puedes ver si el almacenamiento está cargado más del 80%. En el plano de la derecha puedes ver la estructura del intercambiador de calor TA4 formado por 3 bloques, la turbina TA4 y el generador TA4. Presta atención a la alineación del intercambiador de calor (la flecha en el bloque 1 debe apuntar hacia la turbina).

Al contrario del plano de la derecha, las conexiones del bloque de almacenamiento deben estar al mismo nivel (dispuestas horizontalmente, es decir, no abajo y arriba). Las entradas de tubería (Entrada de Tubería TA4) deben estar exactamente en el centro de la pared y frente a la otra. Las tuberías amarillas TA4 se usan como tuberías de vapor. Las tuberías de vapor TA3 no pueden usarse aquí.
Tanto el generador como el intercambiador de calor tienen una conexión eléctrica y deben estar conectados a la red eléctrica.

En principio, el sistema de almacenamiento de calor funciona exactamente igual que las baterías, solo con mucha más capacidad de almacenamiento.

Para que el sistema de almacenamiento de calor funcione, todos los bloques (también la carcasa de hormigón y la grava) deben cargarse usando un bloque de carga forzada.

[ta4_storagesystem|plan]


### Intercambiador de Calor TA4

El intercambiador de calor consta de 3 partes que deben colocarse una encima de la otra, con la flecha del primer bloque apuntando hacia la turbina. Las tuberías deben construirse con las tuberías amarillas TA4.
El intercambiador de calor debe estar conectado a la red eléctrica. El dispositivo de almacenamiento de energía se recarga a través del intercambiador de calor, siempre que haya suficiente electricidad disponible.

[ta4_heatexchanger|image]


### Turbina TA4

La turbina es parte del almacenamiento de energía. Debe colocarse junto al generador y conectarse al intercambiador de calor mediante tuberías TA4 como se muestra en el plano.

[ta4_turbine|image]


### Generador TA4

El generador se usa para generar electricidad. Por lo tanto, el generador también debe estar conectado a la red eléctrica.
El generador es parte del almacenamiento de energía. Se usa para generar electricidad y así libera la energía del dispositivo de almacenamiento de energía. Por lo tanto, el generador también debe estar conectado a la red eléctrica.

Importante: ¡Tanto el intercambiador de calor como el generador deben estar conectados a la misma red eléctrica!

[ta4_generator|image]


### Entrada de Tubería TA4

Debe instalarse un bloque de entrada de tubería en ambos lados del bloque de almacenamiento. Los bloques deben estar exactamente uno frente al otro.

Los bloques de entrada de tubería **no** pueden usarse como aberturas normales de pared; en su lugar usa los bloques de entrada de tubería en pared TA3.

[ta4_pipeinlet|image]


### Tubería TA4

Con TA4, las tuberías amarillas se usan para la transmisión de gas y líquidos.
La longitud máxima del cable es de 100 m.

[ta4_pipe|image]



## Distribución de Energía

Con la ayuda de cables eléctricos y cajas de conexiones, se pueden configurar redes de energía de hasta 1000 bloques/nodos. Sin embargo, debe tenerse en cuenta que las cajas de distribución también deben contarse. Esto significa que se pueden conectar hasta 500 generadores/sistemas de almacenamiento/máquinas/lámparas a una red eléctrica.

Con la ayuda de un transformador de aislamiento y un medidor de electricidad, las redes pueden conectarse para formar estructuras aún más grandes.

[ta4_transformer|image]

### Transformador de Aislamiento TA4

Con la ayuda de un transformador de aislamiento, dos redes eléctricas pueden conectarse para formar una red más grande. El transformador de aislamiento puede transmitir electricidad en ambas direcciones.

El transformador de aislamiento puede transmitir hasta 300 ku. El valor máximo es ajustable a través del menú de la llave inglesa.

[ta4_transformer|image]

### Medidor Eléctrico TA4

Con la ayuda de un medidor de electricidad, dos redes eléctricas pueden conectarse para formar una red más grande. El medidor de electricidad solo transmite electricidad en una dirección (nota la flecha). La cantidad de energía eléctrica transmitida (en kud) se mide y se muestra. Este valor también puede ser consultado por un controlador Lua usando el comando `consumption`. La corriente actual puede consultarse mediante el comando `current`.

El medidor de electricidad puede pasar hasta 200 ku. El valor máximo es ajustable a través del menú de la llave inglesa.

También se puede ingresar una cuenta regresiva de salida de energía a través del menú de la llave inglesa. Cuando esta cuenta regresiva llega a cero, el medidor de electricidad se apaga. La cuenta regresiva puede consultarse usando el comando `countdown`.

[ta4_electricmeter|image]

### Láser TA4

El láser TA4 se usa para la transmisión inalámbrica de energía. Se requieren dos bloques para esto: Emisor de Rayo Láser TA4 y Receptor de Rayo Láser TA4. Debe haber una separación de aire entre los dos bloques para que el rayo láser pueda construirse desde el emisor hasta el receptor. Primero debe colocarse el emisor. Esto activa inmediatamente el rayo láser y muestra las posibles posiciones del receptor. Las posibles posiciones para el receptor también se emiten mediante un mensaje de chat.

Con el láser, se pueden salvar distancias de hasta 96 bloques. Una vez establecida la conexión (no tiene que fluir corriente), esto se indica mediante el texto de información del emisor y también del receptor.

Los propios bloques láser no requieren ninguna electricidad.

[ta4_laser|image]



## Hidrógeno

La electrólisis puede usarse para dividir el agua en hidrógeno y oxígeno usando electricidad. Por otro lado, el hidrógeno puede convertirse de nuevo en electricidad con el oxígeno del aire usando una celda de combustible.
Esto permite que los picos de corriente o un suministro excesivo de electricidad se conviertan en hidrógeno y así se almacenen.

En el juego, la electricidad puede convertirse en hidrógeno usando el electrolizador y el agua. El hidrógeno puede luego convertirse de nuevo en electricidad a través de la celda de combustible.
Esto significa que la electricidad (en forma de hidrógeno) no solo puede almacenarse en depósitos, sino también transportarse mediante el carro cisterna.

Sin embargo, la conversión de electricidad en hidrógeno y de nuevo es con pérdidas. De 100 unidades de electricidad, solo salen 95 unidades de electricidad después de la conversión a hidrógeno y de vuelta.

[ta4_hydrogen|image]


### Electrolizador

El electrolizador convierte electricidad y agua en hidrógeno.
Debe alimentarse desde la izquierda. El agua debe suministrarse a través de tuberías. A la derecha, el hidrógeno puede extraerse a través de tuberías y bombas.

El electrolizador puede tomar hasta 35 ku de electricidad y luego genera un objeto de hidrógeno cada 4 s.
Caben 200 unidades de hidrógeno en el electrolizador.

El electrolizador tiene un menú de llave inglesa para establecer el consumo de corriente y el punto de desconexión.

Si la energía almacenada en la red eléctrica cae por debajo del valor especificado del punto de desconexión, el electrolizador se apaga automáticamente. Esto evita que los sistemas de almacenamiento se vacíen.

[ta4_electrolyzer|image]


### Celda de Combustible

La celda de combustible convierte hidrógeno en electricidad.
Debe suministrarse con hidrógeno desde la izquierda mediante una bomba. La conexión eléctrica está a la derecha.

La celda de combustible puede suministrar hasta 34 ku de electricidad y necesita un objeto de hidrógeno cada 4 s.

Por lo general, la celda de combustible funciona como un generador de categoría 2 (como otros sistemas de almacenamiento).
En este caso, no se pueden cargar otros bloques de categoría 2 como el bloque de batería. Sin embargo, la celda de combustible también puede usarse como generador de categoría 1 a través de la casilla de verificación.

[ta4_fuelcell|image]


## Reactor Químico

El reactor se usa para procesar los ingredientes obtenidos de la torre de destilación o de otras recetas para obtener nuevos productos.
El plano a la izquierda muestra solo una variante posible, ya que la disposición de los silos y depósitos depende de la receta.

El producto de salida principal siempre se emite por el lado del soporte del reactor, independientemente de si es un polvo o un líquido. El producto de desecho (secundario) siempre se descarga en la parte inferior del soporte del reactor.

Un reactor consta de:
- Varios depósitos y silos con los ingredientes que están conectados al dosificador a través de tuberías
- opcionalmente una base de reactor, que descarga los residuos del reactor (solo necesario para recetas con dos productos de salida)
- el soporte del reactor, que debe colocarse sobre la base (si está disponible). El soporte tiene una conexión eléctrica y consume 8 ku durante el funcionamiento.
- El recipiente del reactor que debe colocarse sobre el soporte del reactor
- El tubo de relleno del reactor que debe colocarse sobre el recipiente del reactor
- El dispositivo dosificador, que debe conectarse a los depósitos o silos y al tubo de relleno del reactor a través de tuberías

Nota 1: Los líquidos solo se almacenan en depósitos, los sólidos y sustancias en polvo solo en silos. Esto se aplica tanto a los ingredientes como a los productos de salida.

Nota 2: Los depósitos o silos con contenidos diferentes no deben conectarse a un sistema de tuberías. Por el contrario, varios depósitos o silos con el mismo contenido pueden estar en paralelo en una línea.

El craqueo rompe las cadenas largas de hidrocarburos en cadenas cortas usando un catalizador.
El polvo de gibbsita sirve como catalizador (no se consume). Puede usarse para convertir betún en fuel-oil, fuel-oil en nafta y nafta en gasolina.

En la hidrogenación, se agregan pares de átomos de hidrógeno a una molécula para convertir los hidrocarburos de cadena corta en cadenas largas.
Aquí se requiere polvo de hierro como catalizador (no se consume). Puede usarse para convertir gas (propano) en isobutano, isobutano en gasolina, gasolina en nafta, nafta en fuel-oil y fuel-oil en betún.

[ta4_reactor|plan]


### Dosificador TA4

Parte del reactor químico.
En los 4 lados del dosificador pueden conectarse tuberías para materiales de entrada. Los materiales para el reactor se descargan hacia arriba.

La receta puede establecerse y el reactor iniciarse a través del dosificador.

Como con otras máquinas:
- si el dosificador está en modo de espera, faltan uno o más ingredientes
- si el dosificador está en estado bloqueado, el depósito o silo de salida está lleno, defectuoso o conectado incorrectamente

El dosificador no necesita electricidad. Una receta se procesa cada 10 s.

[ta4_doser|image]

### Reactor TA4

Parte del reactor químico. El reactor tiene un inventario para los objetos catalizadores (para recetas de craqueo e hidrogenación).

[ta4_reactor|image]


### Tubo de Relleno del Reactor TA4

Parte del reactor químico. Debe colocarse sobre el reactor. Si esto no funciona, retira el tubo en la posición de arriba y vuelve a colocarlo.

[ta4_fillerpipe|image]


### Soporte del Reactor TA4

Parte del reactor químico. Aquí también está la conexión eléctrica para el reactor. El reactor requiere 8 ku de electricidad.

El soporte tiene dos conexiones de tuberías, a la derecha para el producto de partida y abajo para los residuos, como el lodo rojo en la producción de aluminio.

[ta4_reactorstand|image]


### Base del Reactor TA4

Parte del reactor químico. Es necesaria para el drenaje del producto de desecho.

[ta4_reactorbase|image]


### Silo TA4

Parte del reactor químico. Es necesario para almacenar sustancias en forma de polvo o gránulos.

[ta4_silo|image]




## Controlador ICTA

El controlador ICTA (ICTA significa "If Condition Then Action" / "Si Condición Entonces Acción") se usa para monitorear y controlar máquinas. El controlador puede usarse para leer datos de máquinas y otros bloques y, dependiendo de esto, encender/apagar otras máquinas y bloques.

Los datos de las máquinas se leen y los bloques y máquinas se controlan usando comandos. El capítulo TA3 -> Bloques de lógica / conmutación es importante para entender cómo funcionan los comandos.

El controlador requiere una batería para funcionar. La pantalla se usa para emitir datos, la torre de señales para mostrar errores.

[ta4_icta_controller|image]



### Controlador ICTA TA4

El controlador funciona sobre la base de reglas `SI <condición> ENTONCES <acción>`. Se pueden crear hasta 8 reglas por controlador.

Ejemplos de reglas son:

- Si un distribuidor está `bloqueado`, el empujador frente a él debe apagarse
- Si una máquina muestra un error, esto debe mostrarse en la pantalla

El controlador verifica estas reglas cíclicamente. Para ello, debe especificarse un tiempo de ciclo en segundos (`Ciclo / s`) para cada regla (1..1000).

Para las reglas que evalúan una entrada de encendido/apagado, p. ej. de un interruptor o detector, debe especificarse el tiempo de ciclo 0. El valor 0 significa que esta regla siempre debe ejecutarse cuando la señal de entrada ha cambiado, p. ej. el botón ha enviado un nuevo valor.

Todas las reglas deben ejecutarse solo con la frecuencia necesaria. Esto tiene dos ventajas:

- la batería del controlador dura más (cada controlador necesita una batería)
- la carga para el servidor es menor (por lo tanto, menos lag)

Debes establecer un tiempo de retardo (`después/s`) para cada acción. Si la acción debe ejecutarse inmediatamente, debe ingresarse 0.

El controlador tiene su propia ayuda e información sobre todos los comandos a través del menú del controlador.

[ta4_icta_controller|image]

### Batería

La batería debe colocarse cerca del controlador, es decir, en una de las 26 posiciones alrededor del controlador.

[ta4_battery|image]

### Torre de Señales TA4

La torre de señales puede mostrar rojo, verde y naranja. No es posible una combinación de los 3 colores.

[ta4_signaltower|image]



## Controlador Lua TA4

Como su nombre indica, el controlador Lua debe programarse en el lenguaje de programación Lua. El manual en inglés está disponible aquí:

https://github.com/joe7575/techage/blob/master/manuals/ta4_lua_controller_EN.md

El controlador Lua también requiere una batería. La batería debe colocarse cerca del controlador, es decir, en una de las 26 posiciones alrededor del controlador.

[ta4_lua_controller|image]

### Servidor Lua TA4

El servidor se usa para el almacenamiento central de datos de varios controladores Lua. También guarda los datos después de un reinicio del servidor.

[ta4_lua_server|image]

### Caja / Cofre Sensor TA4

La caja sensor TA4 se usa para configurar almacenes automáticos o máquinas expendedoras junto con el controlador Lua.
Si algo se pone en la caja o se retira, o se presiona una de las teclas "F1" / "F2", se envía una señal de evento al controlador Lua.
La caja sensor admite los siguientes comandos:

- El estado de la caja puede consultarse mediante `state = $send_cmnd(<num>, "state")`. Las posibles respuestas son: "empty", "loaded", "full"
- La última acción del jugador puede consultarse mediante `name, action = $send_cmnd(<num>, "action")`. `name` es el nombre del jugador. Se devuelve uno de los siguientes como `action`: "put", "take", "f1", "f2".
- El contenido de la caja puede leerse mediante `stacks = $send_cmnd(<num>, "stacks")`. Ver: https://github.com/joe7575/techage/blob/master/manuals/ta4_lua_controller_EN.md#sensor-chest
- Mediante `$send_cmnd(<num>, "text", "press both buttons and\nput something into the chest")` el texto puede establecerse en el menú de la caja sensor.

La casilla de verificación "Permitir acceso público al cofre" puede usarse para establecer si la caja puede ser usada por todos o solo por jugadores que tienen derechos de acceso/protección aquí.

[ta4_sensor_chest|image]

### Terminal del Controlador Lua TA4

El terminal se usa para entrada/salida del controlador Lua.

[ta4_terminal|image]

## Pantallas TA4

Techage ofrece varias pantallas que pueden usarse para mostrar texto. Las pantallas pueden accederse a través del controlador Lua, pero también a través del controlador ICTA, o a través del terminal TA3.

- Pantalla TA4 / Pantalla XL TA4: Visualización de 5 líneas de texto en fuente proporcional. El ancho de carácter flexible significa que por línea pueden mostrarse diferentes números de caracteres.
- Pantalla II TA4 / Pantalla II XXL TA4: Visualización de hasta 20 líneas de texto en fuentes de ancho fijo. Aquí se define el número máximo de caracteres que pueden mostrarse por línea.

Todas las pantallas muestran un número después de haber sido colocadas. Las pantallas pueden accederse a través de este número. Todas las pantallas tienen los mismos comandos para esto.

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

[ta4_display2|image]

### Pantalla TA4

El texto puede mostrarse en la pantalla y esta puede mostrar 5 líneas.

Las líneas de texto siempre se muestran alineadas a la izquierda. Si el texto debe centrarse horizontalmente, el texto debe ir precedido del carácter "\t" (tabulación).

La pantalla se actualiza como máximo una vez por segundo.

[ta4_display|image]

### Pantalla XL TA4

La Pantalla XL TA4 es el doble de grande que la Pantalla TA4.

Las líneas de texto siempre están alineadas a la izquierda. Si el texto debe centrarse horizontalmente, el texto debe ir precedido del carácter "\t" (tabulación).

La pantalla se actualiza como máximo cada dos segundos.

[ta4_displayXL|image]

### Pantalla II TA4

La pantalla puede configurarse de manera flexible. El número de líneas y caracteres por línea, así como el color del texto y del fondo pueden establecerse usando el menú de la llave inglesa:

- La resolución de pantalla puede establecerse en el rango de 16x8 a 40x20 caracteres x líneas.
- El color del texto puede establecerse como código de color en el rango de 0 a 63.
- El color de fondo también puede establecerse como código de color en el rango de 0 a 63.

El comando de chat `/ta_color64` muestra la paleta de colores con los códigos de color.

La tasa de actualización de la pantalla depende directamente de la resolución y es de un segundo a 16x8 y alrededor de 6 segundos a 40x20.

[ta4_display2|image]

### Pantalla II XXL TA4

Las mismas configuraciones se aplican a la pantalla XXL que a la Pantalla II. Sin embargo, la pantalla XXL es 9 veces más grande que la Pantalla II y por lo tanto consta de un bloque central "Pantalla II XXL TA4 interior" y otros 8 bloques "Pantalla II XXL TA4 exterior", que deben colocarse alrededor del bloque central en consecuencia.

[ta4_displayXXL|image]

## Módulos Lógicos/de Conmutación TA4

### Botón/Interruptor TA4

Solo ha cambiado la apariencia del botón/interruptor TA4. La funcionalidad es la misma que con el botón/interruptor TA3. Con el menú de la llave inglesa, sin embargo, los datos pueden cambiarse más tarde.

[ta4_button|image]

### Botón 2x TA4

Este bloque tiene dos botones que pueden configurarse individualmente usando el menú de la llave inglesa. El etiquetado y la dirección del bloque de destino pueden configurarse para cada botón. Además, el comando que debe enviarse puede configurarse para cada botón.

[ta4_button_2x|image]


### Botón 4x TA4

Este bloque tiene cuatro botones que pueden configurarse individualmente usando el menú de la llave inglesa. El etiquetado y la dirección del bloque de destino pueden configurarse para cada botón. Además, el comando que debe enviarse puede configurarse para cada botón.

[ta4_button_4x|image]

### Lámpara de Señal 2x TA4

Este bloque tiene dos lámparas que pueden controlarse individualmente. Cada lámpara puede mostrar los colores "rojo", "verde" y "ámbar". El etiquetado para ambas lámparas puede configurarse a través del menú de la llave inglesa. Las lámparas pueden controlarse usando los siguientes comandos:

- Cambiar lámpara 1 a rojo: `$send_cmnd(1234, "red", 1)`
- Cambiar lámpara 2 a verde: `$send_cmnd(1234, "green ", 2)`
- Cambiar lámpara 1 a naranja: `$send_cmnd(1234, "amber", 1)`
- Apagar lámpara 2: `$send_cmnd(1234, "off", 2)`

[ta4_signallamp_2x|image]

### Lámpara de Señal 4x TA4

Este bloque tiene cuatro lámparas que pueden controlarse individualmente. Cada lámpara puede mostrar los colores "rojo", "verde" y "ámbar". El etiquetado para todas las lámparas puede configurarse a través del menú de la llave inglesa. Las lámparas pueden controlarse usando los siguientes comandos:

- Cambiar lámpara 1 a rojo: `$send_cmnd(1234, "red", 1)`
- Cambiar lámpara 2 a verde: `$send_cmnd(1234, "green ", 2)`
- Cambiar lámpara 3 a naranja: `$send_cmnd(1234, "amber", 3)`
- Apagar lámpara 4: `$send_cmnd(1234, "off", 4)`

[ta4_signallamp_4x|image]

### Detector de Jugador TA4

Solo ha cambiado la apariencia del detector de jugador TA4. La funcionalidad es la misma que con el detector de jugador TA3.
Además, el radio de búsqueda puede configurarse a través del menú de la llave inglesa. El radio puede establecerse de 1 a 8 bloques (predeterminado: 4).

[ta4_playerdetector|image]

### Recopilador de Estados TA4

[ta4_collector|image]

El recopilador de estados consulta todas las máquinas configuradas por turnos para conocer el estado. Si una de las máquinas ha alcanzado o superado un estado preconfigurado, se envía un comando "on". Por ejemplo, muchas máquinas pueden monitorearse fácilmente para detectar fallos desde un controlador Lua.

### Detector de Objetos TA4

La funcionalidad es la misma que para el detector de objetos TA3. Además, el detector cuenta los objetos pasados.
Este contador puede consultarse con el comando `count` y reiniciarse con `reset`.

[ta4_detector|image]

### Detector de Nodo TA4

La funcionalidad es la misma que con el Detector de Nodo TA3.

A diferencia del detector de nodo TA3, las posiciones a monitorear pueden configurarse individualmente aquí. Para ello, debe presionarse el botón "Grabar". Luego deben hacer clic en todos los bloques cuya posición debe comprobarse. Luego debe presionarse el botón "Hecho".

Se pueden seleccionar hasta 4 bloques.

[ta4_nodedetector|image]

### Detector de Carga del Almacenamiento de Energía TA4

El detector de carga mide el estado de carga del almacenamiento de energía de la red eléctrica cada 8 s.

Si el valor cae por debajo de un umbral configurable (punto de conmutación), se envía un comando (predeterminado: "off"). Si el valor vuelve a subir por encima de este punto de conmutación, se envía un segundo comando (predeterminado: "on"). Esto permite desconectar los consumidores de la red cuando el nivel de carga del dispositivo de almacenamiento de energía cae por debajo del punto de conmutación especificado.

Para ello, el detector de carga debe conectarse a la red a través de una caja de conexiones. El detector de carga se configura a través del menú de la llave de extremo abierto.

[ta4_chargedetector|image]

### Sensor de Mirada TA4

El sensor de mirada TA4 genera un comando cuando el bloque es visto/enfocado por el propietario u otros jugadores configurados y envía un segundo comando cuando el bloque ya no está enfocado. Sirve así como reemplazo de botones/interruptores, por ejemplo para abrir/cerrar puertas.

El Sensor de Mirada TA4 solo puede programarse usando el menú de la llave de extremo abierto. Si tienes una llave de extremo abierto en la mano, el sensor no se activa, incluso si está enfocado.

[ta4_gaze_sensor|image]

### Secuenciador TA4

Se pueden programar procesos completos usando el secuenciador TA4. Aquí hay un ejemplo:

```
-- esto es un comentario
[1] send 188 reset
[50] send 188 moveto 771,19,-280
[100] goto 1
```

- Cada línea comienza con un número que corresponde a un punto en el tiempo `[<num>]`
- Los valores de 1 a 50000 están permitidos para los tiempos
- 1 corresponde a 100 ms, 50000 corresponde a aproximadamente 4 días de juego
- Se permiten líneas vacías o comentarios (`-- comentario`)
- Con `send <num> <comando> <datos>` puedes enviar un comando a un bloque
- Con `goto <num>` puedes saltar a otra línea / punto en el tiempo
- Con `stop` puedes detener el secuenciador con un retraso para que no acepte un nuevo comando de un botón u otro bloque (para completar un movimiento). Sin `stop`, el secuenciador pasa al modo detenido inmediatamente después del último comando.

El secuenciador TA4 admite los siguientes comandos techage:

- `goto <num>` Saltar a una línea de comando e iniciar el secuenciador
- `stop` Detener el secuenciador
- `on` y `off` como alias para `goto 1` y `stop` respectivamente

El comando `goto` solo se acepta cuando el secuenciador está detenido.

El tiempo de ciclo (predeterminado: 100 ms) puede cambiarse para el secuenciador a través del menú de la llave de extremo abierto.

[ta4_sequencer|image]



## Controlador de Movimiento/Giro

### Controlador de Movimiento TA4 (obsoleto)

El Controlador de Movimiento TA4 es similar al "Controlador de Puerta 2", pero los bloques seleccionados no se retiran, sino que pueden moverse.
Dado que los bloques en movimiento pueden llevar a los jugadores y criaturas que se encuentran sobre el bloque, con ellos se pueden construir ascensores y sistemas de transporte similares.

Instrucciones:

- Configura el controlador y entrena los bloques a mover a través del menú (se pueden entrenar hasta 16 bloques)
- la "ruta de vuelo" debe ingresarse a través de una especificación x, y, z (relativa) (la distancia máxima es 1000 m)
- El movimiento puede probarse con los botones del menú "Mover A-B" y "Mover B-A"
- también puedes volar a través de paredes u otros bloques
- La posición de destino para los bloques también puede estar ocupada. En este caso, los bloques se guardan "invisiblemente". Esto está diseñado para puertas corredizas y similares

El Controlador de Movimiento admite los siguientes comandos techage:

- `a2b` Mover bloque de A a B.
- `b2a` Mover bloque de B a A.
- `move` Mover bloque al otro lado

Puedes cambiar al modo de operación `move xyz` a través del menú de la llave inglesa. Después del cambio, se admiten los siguientes comandos techage:

- `move2` Con este comando, la ruta de vuelo también debe especificarse como vector x,y,z.
  Ejemplo Controlador Lua: `$send_cmnd(MOVE_CTLR, "move2", "0,12,0")`
- `moveto` Mover bloque a la posición de destino indicada (la posición de destino es válida para el primer bloque marcado; los demás bloques se mueven en relación con esta posición)
- `reset` mover bloque(s) de vuelta a la posición inicial

**Instrucciones importantes:**

- Si se van a mover varios bloques, primero debe hacerse clic en el bloque que debe llevar a los jugadores/criaturas al entrenar.
- Si se usa el comando `moveto`, la posición de destino especificada se aplica al bloque en el que se hace clic primero durante el entrenamiento.
- Si el bloque que se supone que debe llevar a los jugadores/criaturas tiene una altura reducida, la altura debe establecerse en el controlador usando el menú de la llave de extremo abierto (p. ej., height = 0.5). De lo contrario, el jugador/criatura no será "encontrado" y no será llevado.

[ta4_movecontroller|image]

### Controlador de Movimiento II TA4

El Controlador de Movimiento II TA4 es un desarrollo adicional del Controlador de Movimiento TA4. Puede mover hasta 16 bloques y solo admite los comandos `moveto` y `reset`.
También tiene un inventario donde se almacenan los bloques si no pueden colocarse porque la posición ya está ocupada.

En caso de un fallo o reinicio del servidor, los bloques pueden restaurarse desde el inventario si es necesario.

Instrucciones:

- Coloca el controlador y entrena los bloques a mover a través del menú (presiona el botón "Grabar"). (Se pueden entrenar hasta 16 bloques.)
- Prueba el movimiento usando los botones del menú "Probar movimiento" y "Restablecer".
- También puedes volar a través de paredes u otros bloques.
- La posición de destino para los bloques puede estar ocupada. En este caso, los bloques se guardan en el inventario de bloques. Esto está diseñado para puertas corredizas y dispositivos similares.

El Controlador de Movimiento II admite los siguientes comandos techage:

- `moveto` mueve un bloque a la posición de destino especificada (la posición de destino se refiere al primer bloque seleccionado; los bloques restantes se mueven en relación con esta posición).
- `reset` mueve el/los bloque(s) de vuelta a la posición inicial.

Ejemplo Controlador Lua: `$send_cmnd(MOVE_CTLR, "moveto", "1234,12,-567")`

**Notas importantes:**

- Si se van a mover varios bloques, la posición de destino especificada se refiere al bloque en el que se hizo clic primero durante el entrenamiento. Los demás bloques se mueven en relación con esta posición.
- Si el bloque que debe llevar a los jugadores/criaturas tiene una altura reducida, la altura debe establecerse en el controlador a través del menú de la llave inglesa (p. ej., height = 0.5). De lo contrario, el jugador/criatura no será "encontrado" y por lo tanto no será llevado.

[ta4_movecontroller2|image]

### Controlador de Giro TA4

El controlador de giro TA4 es similar al "Controlador de Movimiento", pero los bloques seleccionados no se mueven, sino que se rotan alrededor de su centro hacia la derecha o hacia la izquierda.

Instrucciones:

- Configura el controlador y entrena los bloques a mover a través del menú (se pueden entrenar hasta 16 bloques)
- El movimiento puede probarse con los botones del menú "Girar a la izquierda" y "Girar a la derecha"

El controlador de giro admite los siguientes comandos techage:

- `left` Girar a la izquierda
- `right` Girar a la derecha
- `uturn` Girar 180 grados

[ta4_turncontroller|image]




## Lámparas TA4

TA4 contiene una serie de lámparas potentes que permiten una mejor iluminación o que asumen tareas especiales.

### Luz de Cultivo LED TA4

La luz de cultivo LED TA4 permite el crecimiento rápido y vigoroso de todas las plantas del mod `farming`. La lámpara ilumina un campo de 3x3, de modo que las plantas también pueden cultivarse bajo tierra.
La lámpara debe colocarse un bloque por encima del suelo en el centro del campo de 3x3.

La lámpara también puede usarse para cultivar flores. Si la lámpara se coloca sobre un campo de flores de 3x3 hecho de "Tierra de Jardín" (Mod `compost`), las flores crecen allí automáticamente (por encima y por debajo del suelo).

Puedes cosechar las flores con el Signs Bot, que también tiene un cartel correspondiente que debe colocarse frente al campo de flores.

La lámpara requiere 1 ku de electricidad.

[ta4_growlight|image]

### Farola TA4

La farola LED TA4 es una lámpara con iluminación particularmente potente. La lámpara consta de los bloques de la carcasa de la lámpara, el brazo de la lámpara y el poste de la lámpara.

La corriente debe llevarse desde abajo a través del mástil hasta la carcasa de la lámpara. Primero jala la línea eléctrica hacia arriba y luego "enluce" el cable eléctrico con bloques de poste de lámpara.

La lámpara requiere 1 ku de electricidad.

[ta4_streetlamp|image]

### Lámpara Industrial LED TA4

La lámpara industrial LED TA4 es una lámpara con iluminación particularmente potente. La lámpara debe alimentarse desde arriba.

La lámpara requiere 1 ku de electricidad.

[ta4_industriallamp|image]

### Semáforo TA4

El semáforo TA4 está disponible en dos versiones: negro (versión europea) y amarillo (versión americana). Además, hay un mástil, un brazo y un bloque conector. El semáforo puede montarse sobre o en un mástil. Sin embargo, no puede montarse en un brazo. Esto es por razones técnicas. Por eso existe el bloque conector, que se coloca entre el brazo y el semáforo.

El semáforo puede controlarse mediante comandos como la torre de señales TA4. Si también se usa el detector de jugador TA4, el semáforo también puede reaccionar a peatones o vehículos.

El semáforo no requiere electricidad.

[ta4_trafficlight|image]


## Filtro de Líquido TA4

El filtro de líquidos filtra el lodo rojo.
Una parte del lodo rojo se convierte en lejía, que puede recogerse en la parte inferior en un depósito.
La otra parte se convierte en adoquín de desierto y obstruye el material filtrante.
Si el filtro está demasiado obstruido, debe limpiarse y volver a llenarse.
El filtro consta de una capa base, 7 capas de filtro idénticas y una capa de llenado en la parte superior.

[ta4_liquid_filter|image]

### Capa Base

Puedes ver la estructura de esta capa en el plano.

La lejía se recoge en el depósito.

[ta4_liquid_filter_base|plan]

### Capa de Grava

Esta capa debe llenarse con grava como se muestra en el plano.
En total, debe haber siete capas de grava.
El filtro se obstruirá con el tiempo, por lo que debe limpiarse y volver a llenarse.

[ta4_liquid_filter_gravel|plan]

### Capa de Llenado

Esta capa se usa para llenar el filtro con lodo rojo.
El lodo rojo debe bombearse hacia la tubería de llenado.

[ta4_liquid_filter_top|plan]




## Colisionador TA4 (Acelerador de Partículas)

El Colisionador es una instalación de investigación que realiza investigación básica. Aquí se pueden recopilar puntos de experiencia, que son necesarios para TA5 (Edad Futura).

Al igual que su original en el CERN en Ginebra, el colisionador debe construirse bajo tierra. La configuración estándar aquí es Y <= -28. Sin embargo, el valor puede ser cambiado por el personal del servidor a través de la configuración. Por favor pregunta o prueba el bloque "Trabajador del Detector del Colisionador TA4".

Solo se puede operar un colisionador por jugador. Por lo tanto, no tiene sentido configurar dos o más colisionadores. Los puntos de experiencia se acreditan al jugador propietario del colisionador. Los puntos de experiencia no pueden transferirse.

Un colisionador consta de un "anillo" hecho de tubos y magnetos, así como un detector con un sistema de enfriamiento.

- El detector es el corazón del sistema. Aquí es donde tienen lugar los experimentos científicos. El detector tiene un tamaño de 3x3x7 bloques.
- 22 Magnetos del Colisionador TA4 (¡no los Magnetos del Detector del Colisionador TA4!) deben conectarse entre sí a través de 5 bloques del tubo de vacío TA4. Cada magneto también requiere electricidad y una conexión de gas para el enfriamiento. Todo esto forma (como se muestra en el plano de la derecha) un cuadrado con una longitud de arista de 37 metros.

El plano muestra la instalación desde arriba:

- el bloque gris es el detector con el bloque trabajador en el centro
- los bloques rojos son los magnetos, los azules los tubos de vacío

[techage_collider_plan|plan]

### Detector

El detector se configura automáticamente con la ayuda del bloque "Trabajador del Detector del Colisionador TA4" (similar a la torre de perforación). Todos los materiales necesarios para esto deben colocarse primero en el bloque trabajador. El detector se muestra simbólicamente en el bloque trabajador. El detector se configura a través del bloque trabajador.

El detector también puede desmantelarse de nuevo con la ayuda del bloque trabajador.

Las conexiones para electricidad, gas y tubos de vacío están en los dos lados frontales del detector. Debe conectarse una bomba TA4 en la parte superior para succionar el tubo vacío / crear el vacío.

El sistema de enfriamiento debe conectarse a la parte trasera del detector. El sistema de enfriamiento se muestra en el plano de la derecha. Además del intercambiador de calor TA4 del almacenamiento de energía (que se usa aquí para el enfriamiento), también se requiere un bloque enfriador TA4.

Nota: La flecha en el intercambiador de calor debe apuntar lejos del detector. El intercambiador de calor también debe suministrarse con electricidad.

[ta4_cooler|plan]


- Además, se requiere enfriamiento, que también debe instalarse en el detector. Se requiere isobutano para el enfriamiento.
- El sistema requiere bastante electricidad. Por lo tanto, tiene sentido tener su propio suministro eléctrico.

### Control / Terminal TA4

El colisionador se controla a través de un terminal TA4 (no a través del terminal del controlador Lua TA4).

Este terminal debe conectarse al detector. El número del detector se muestra como texto de información en el bloque trabajador.

El terminal admite los siguientes comandos:

- `connect <número>` (conectar al detector)
- `start` (iniciar el detector)
- `stop` (detener el detector)
- `test <número>` (comprobar un magneto)
- `points` (consulta de los puntos de experiencia ya alcanzados)

Si ocurre un error en un magneto durante el `start`, se emite el número del magneto. El comando `test` puede usarse para solicitar información adicional sobre el error del magneto.

[ta4_terminal|image]

### Enfriamiento y energía

Cada magneto del Colisionador TA4 también debe suministrarse con electricidad (como se muestra a la derecha en el plano) y con Isobutano para el enfriamiento:

- La conexión para la energía está en la parte superior del magneto.
- La conexión para el enfriamiento está en la parte frontal del magneto.
- También se requiere una bomba TA4 y un depósito TA4 con al menos 250 unidades de isobutano para enfriar todo el sistema.
- El sistema también requiere mucha electricidad. Por lo tanto, tiene sentido tener su propio suministro eléctrico con al menos 145 ku.

[techage_collider_plan2|plan]

### Construcción

Se recomienda la siguiente secuencia al configurar el colisionador:

- Coloca un bloque de carga forzada. Solo el detector con el sistema de enfriamiento debe estar en el área del bloque de carga forzada.
- Coloca el bloque trabajador, llénalo con objetos y configura el detector a través del menú
- Construye el anillo con tubos y magnetos
- Conecta todos los magnetos y el detector con cables eléctricos
- Conecta todos los magnetos y el detector con los tubos amarillos y bombea el isobutano al sistema de tubos con una bomba
- Instala una bomba TA4 como bomba de vacío en el detector y enciéndela (no se requiere depósito adicional). Si la bomba entra en "espera", el vacío se establece. Esto tomará unos segundos
- Monta el enfriador (intercambiador de calor) y conéctalo al cable eléctrico
- Coloca el terminal TA4 frente al detector y conéctalo al detector a través de `connect <número>`
- Enciende/conecta el suministro eléctrico
- enciende el enfriador (intercambiador de calor)
- Enciende el detector a través de `start` en el terminal TA4. Después de algunos pasos de prueba, el detector entra en operación normal o emite un error.
- El colisionador debe funcionar continuamente y luego entrega gradualmente puntos de experiencia. Para 10 puntos, el colisionador debe funcionar durante varias horas

[techage_ta4c|image]


## Más Bloques TA4

### Bloque de Recetas TA4

Se pueden guardar hasta 10 recetas en el bloque de recetas. Estas recetas pueden luego llamarse a través de un comando del Fabricante Automático TA4. Esto permite configurar la receta del fabricante automático usando un comando. Las recetas en el bloque de recetas también pueden consultarse directamente usando un comando.

`input <índice>` lee una receta del bloque de recetas TA4. `<índice>` es el número de la receta. El bloque devuelve una lista de ingredientes de la receta.

Ejemplo: `$send_cmnd(1234, "input", 1)`

[ta4_recipeblock|image]

### Fabricante Automático TA4

La función corresponde a la de TA3.

La capacidad de procesamiento es de 4 objetos cada 4 s. El fabricante automático requiere 9 ku de electricidad para esto.

Además, el Fabricante Automático TA4 admite la selección de diferentes recetas usando los siguientes comandos:

`recipe "<número>.<índice>"` cambia el fabricante automático a una receta del Bloque de Recetas TA4. `<número>` es el número del bloque de recetas, `<índice>` el número de receta. Ejemplo: `$send_cmnd(1234, "recipe", "5467.1")`

Alternativamente, también puede seleccionarse una receta a través de la lista de ingredientes, como:
`$send_cmnd(1234, "recipe", "default:coal_lump,,,default:stick")`
Aquí deben especificarse todos los nombres técnicos de una receta, separados por comas. Ver también el comando `input` en el bloque de recetas TA4.

El comando `flush` mueve todos los objetos del inventario de entrada al inventario de salida. El comando devuelve `true` si el inventario de entrada se vació completamente. Si se devolvió `false` (inventario de salida lleno), el comando debe repetirse más tarde.

[ta4_autocrafter|image]

### Depósito TA4

Ver depósito TA3.

Un depósito TA4 puede contener 2000 unidades o 200 barriles de líquido.

[ta4_tank|image]

### Bomba TA4

Ver bomba TA3.

La bomba TA4 bombea 8 unidades de líquido cada dos segundos.

En el modo "limitador de flujo", el número de unidades bombeadas por la bomba puede limitarse. El modo de limitador de flujo puede activarse a través del menú de la llave de extremo abierto configurando el número de unidades en el menú. Una vez bombeadas las unidades configuradas, la bomba se apagará. Cuando la bomba se enciende de nuevo, bombeará las unidades configuradas nuevamente y luego se apagará.

El limitador de flujo también puede configurarse e iniciarse usando un controlador Lua o Beduino.

La bomba también admite el comando `flowrate`. Esto permite consultar la tasa de flujo total a través de la bomba.

[ta4_pump|image]

### Calentador del Horno TA4

Con TA4, el horno industrial también tiene su calefacción eléctrica. El quemador de petróleo y el potenciador pueden reemplazarse con el calentador.

El calentador requiere 14 ku de electricidad.

[ta4_furnaceheater|image]

### Bomba de Agua TA4 (obsoleto)

Este bloque ya no puede fabricarse y será reemplazado por el bloque de entrada de agua TA4.

### Entrada de Agua TA4

Algunas recetas requieren agua. El agua debe bombearse desde el mar con una bomba (agua a y = 1). ¡Un "estanque" formado por unos pocos bloques de agua no es suficiente para esto!

Para ello, el bloque de entrada de agua debe colocarse en el agua y conectarse a la bomba mediante tuberías. Si el bloque se coloca en el agua, debe asegurarse de que haya agua debajo del bloque (el agua debe tener al menos 2 bloques de profundidad).

[ta4_waterinlet|image]

### Tubo TA4

TA4 también tiene sus propios tubos en el diseño TA4. Estos pueden usarse como tubos estándar.
Pero: los empujadores TA4 y los distribuidores TA4 solo alcanzan su pleno rendimiento cuando se usan con tubos TA4.

[ta4_tube|image]

### Empujador TA4

La función corresponde básicamente a la de TA2 / TA3. Además, puede usarse un menú para configurar qué objetos deben tomarse de un cofre TA4 y transportarse más adelante.
La capacidad de procesamiento es de 12 objetos cada 2 s, si se usan tubos TA4 en ambos lados. De lo contrario, solo hay 6 objetos cada 2 s.

En el modo "limitador de flujo", el número de objetos que mueve el empujador puede limitarse. El modo de limitador de flujo puede activarse a través del menú de la llave de extremo abierto configurando el número de objetos en el menú. Tan pronto como se hayan movido los objetos configurados, el empujador se apaga. Si el empujador se enciende de nuevo, mueve los objetos configurados nuevamente y luego se apaga.

El empujador TA4 también puede configurarse e iniciarse usando un controlador Lua o Beduino.

Aquí están los comandos adicionales para el controlador Lua:

- `config` se usa para configurar el empujador, análogamente a la configuración manual a través del menú.
   Ejemplo: `$send_cmnd(1234, "config", "default:dirt")`
   Con `$send_cmnd(1234, "config", "")` la configuración se borra
- `limit` se usa para establecer el número de objetos para el modo de limitador de flujo:
   Ejemplo: `$send_cmnd(1234, "limit", 7)`

[ta4_pusher|image]

### Cofre TA4

La función corresponde a la de TA3. El cofre puede contener más contenido.

Además, el cofre TA4 tiene un inventario sombra para la configuración. Aquí ciertas ubicaciones de pila pueden preasignarse con un objeto. Las pilas de inventario preasignadas solo se llenan con estos objetos al llenarse. Se requiere un empujador TA4 o un inyector TA4 con la configuración apropiada para vaciar una pila de inventario preasignada.

[ta4_chest|image]

### Cofre 8x2000 TA4

El cofre 8x2000 TA4 no tiene un inventario normal como otros cofres, sino que tiene 8 almacenes, donde cada almacén puede contener hasta 2000 objetos de un tipo. Los botones naranjas pueden usarse para mover objetos hacia o desde el almacén. La caja también puede llenarse o vaciarse con un empujador (TA2, TA3 o TA4) como de costumbre.

Si el cofre se llena con un empujador, todos los almacenes se llenan de izquierda a derecha. Si los 8 almacenes están llenos y no se pueden agregar más objetos, los objetos adicionales son rechazados.

**Función de fila**

Varios cofres 8x2000 TA4 pueden conectarse a un cofre grande con más contenido. Para ello, los cofres deben colocarse en fila uno detrás del otro.

Primero debe colocarse el cofre frontal, luego los cofres apilados se colocan detrás con la misma dirección de vista (todas las cajas tienen el frente hacia el jugador). Con 2 cofres en fila, el tamaño aumenta a 8x4000, etc.

Las filas de cofres ya no pueden retirarse. Hay dos formas de desmantelar los cofres:

- Vaciar y retirar el cofre frontal. Esto desbloquea el siguiente cofre y puede retirarse.
- Vaciar el cofre frontal hasta que todos los almacenes contengan como máximo 2000 objetos. Esto desbloquea el siguiente cofre y puede retirarse.

Los cofres tienen una casilla de verificación "orden". Si esta casilla de verificación está activada, los almacenes ya no se vacían completamente por un empujador. El último objeto permanece en el almacén como predeterminado. Esto resulta en una asignación fija de objetos a ubicaciones de almacenamiento.

El cofre solo puede ser usado por jugadores que puedan construir en esa ubicación, es decir, que tengan derechos de protección. No importa quién coloca el cofre.

El cofre tiene un comando adicional para el controlador Lua:

- `count` se usa para consultar cuántos objetos hay en el cofre.
  Ejemplo 1: `$send_cmnd(COFRE, "count")` -> Suma de objetos en los 8 almacenes
  Ejemplo 2: `$send_cmnd(COFRE, "count", 2)` -> número de objetos en el almacén 2 (segundo desde la izquierda)
- `storesize` se usa para leer el tamaño de uno de los ocho almacenes:
  Ejemplo: `$send_cmnd(COFRE, "storesize")` -> la función devuelve p. ej. 6000

[ta4_8x2000_chest|image]



### Distribuidor TA4

La función corresponde a la de TA2.
La capacidad de procesamiento es de 24 objetos cada 4 s, siempre que se usen tubos TA4 en todos los lados. De lo contrario, solo hay 12 objetos cada 4 s.

[ta4_distributor|image]

### Distribuidor de Alto Rendimiento TA4

La función corresponde a la del distribuidor TA4 normal, con dos diferencias:
La capacidad de procesamiento es de 36 objetos cada 4 s, siempre que se usen tubos TA4 en todos los lados. De lo contrario, solo hay 18 objetos cada 4 s.
Además, se pueden configurar hasta 8 objetos por dirección.

[ta4_high_performance_distributor|image]

### Criba de Grava TA4

La función corresponde a la de TA2.
La capacidad de procesamiento es de 4 objetos cada 4 s. El bloque requiere 5 ku de electricidad.

[ta4_gravelsieve|image]

### Trituradora TA4

La función corresponde a la de TA2.
La capacidad de procesamiento es de 4 objetos cada 4 s. El bloque requiere 9 ku de electricidad.

[ta4_grinder|image]

### Cantera TA4

La función corresponde en gran medida a la de TA2.

Además, el tamaño del agujero puede establecerse entre 3x3 y 11x11 bloques.
La profundidad máxima es de 80 metros. La cantera requiere 14 ku de electricidad.

[ta4_quarry|image]

### Eliminador de Agua TA4

El Eliminador de Agua retira el agua de un área de hasta 21 x 21 x 80 m. El propósito principal es drenar cuevas. Pero también puede usarse para "perforar" un agujero en el mar.

El Eliminador de Agua necesita electricidad y una conexión de tubería a un depósito de líquido. El Eliminador de Agua se coloca en el punto más alto de la cueva y retira el agua de la cueva hasta el punto más bajo. El Eliminador de Agua extrae un bloque de agua cada dos segundos. El dispositivo requiere 10 ku de electricidad.

Técnicamente, el Eliminador de Agua reemplaza los bloques de agua con un bloque de aire especial que no es visible y no puede caminarse pero evita que el agua fluya de vuelta.

[ta4_waterremover|image]

### Fábrica Electrónica TA4

La función corresponde a la de TA2, solo que aquí se producen chips diferentes.
La capacidad de procesamiento es de un chip cada 6 s. El bloque requiere 12 ku de electricidad para esto.

[ta4_electronicfab|image]

### Inyector TA4

La función corresponde a la de TA3.

La capacidad de procesamiento es de hasta 8 veces cuatro objetos cada 4 segundos.

[ta4_injector|image]

### Reciclador TA4

El reciclador es una máquina que procesa todas las recetas de Techage al revés, es decir, puede desmantelar máquinas y bloques de nuevo en sus componentes.

La máquina puede desmontar prácticamente cualquier bloque de Techage e Hyperloop. Pero no todos los objetos/materiales de la receta pueden reciclarse:

- La madera se convierte en palos
- La piedra se convierte en arena o grava
- Los semiconductores / chips no pueden reciclarse
- Las herramientas no pueden reciclarse

La capacidad de procesamiento es de un objeto cada 8 s. El bloque requiere 16 ku de electricidad para esto.

[ta4_recycler|image]
