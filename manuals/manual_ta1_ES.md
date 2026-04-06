# TA1: Edad del Hierro

TA1 trata de extraer suficientes minerales y producir carbón vegetal con herramientas y equipos sencillos, de modo que se puedan fabricar y operar las máquinas TA2.

Por supuesto, para una edad del hierro también debe haber hierro y no solo acero, como en "Minetest Game". Como resultado, algunas recetas han sido modificadas para que primero haya que producir hierro y luego acero más adelante.

La durabilidad de las herramientas se basa en las edades y por lo tanto no corresponde al juego original de Minetest.
La durabilidad / resistencia para un hacha, por ejemplo:

* Bronce: 20
* Acero: 30

[techage_ta1|image]


## Pila de Carbón Vegetal (horno de carbón)

Necesitas la Pila de Carbón Vegetal para hacer carbón vegetal. El carbón vegetal es necesario para el horno de fundición, pero también, por ejemplo, en TA2 para la máquina de vapor.

Para el horno de carbón necesitas:

- un bloque encendedor (`techage:lighter`)
- 26 bloques de madera que se apilan en una pila de madera. El tipo de madera es irrelevante
- Tierra para cubrir la pila de madera
- Pedernal y hierro (nombre técnico: `fire:flint_and_steel`) para encender el bloque encendedor



Instrucciones de construcción (ver también el plano):

- Construye un área de 5x5 de tierra
- Coloca 7 bloques de madera alrededor del encendedor pero deja un agujero hacia el encendedor
- Construye otras 2 capas de madera encima, formando un cubo de madera de 3x3x3
- Cubre todo con una capa de tierra formando un cubo de 5x5x5, pero mantén el agujero hacia el encendedor abierto
- Enciende el encendedor e inmediatamente cierra el agujero con un bloque de madera y tierra
- Si lo has hecho todo correctamente, el horno de carbón comenzará a humear después de unos segundos
- Solo abre el horno de carbón cuando el humo haya desaparecido (aprox. 20 min)

Luego puedes retirar los 9 bloques de carbón vegetal y rellenar la Pila de Carbón Vegetal.

[coalpile|plan]


## Horno de Fundición

Necesitas el horno de fundición, por ejemplo, para fundir hierro y otros minerales en el crisol. Hay diferentes recetas que requieren diferentes temperaturas. Cuanto más alta sea la torre de fundición, más caliente será la llama. Una altura de 11 bloques sobre la placa base es válida para todas las recetas, pero un quemador de esta altura también requiere más carbón vegetal.

Instrucciones de construcción (ver también el plano):

* Construye una torre de piedra (adoquín) con una base de 3x3 (de 7 a 11 bloques de alto)
* Deja un agujero abierto en un lado en la parte inferior
* Coloca un encendedor en él
* Llena la torre hasta el borde con carbón vegetal dejando caer el carbón vegetal en el agujero desde arriba
* Enciende el encendedor a través del agujero
* Coloca el crisol en la parte superior de la torre directamente sobre la llama, un bloque por encima del borde de la torre
* Para detener el quemador, cierra temporalmente el agujero con un bloque de tierra, por ejemplo.

El crisol tiene su propio menú de recetas y un inventario donde tienes que poner los minerales.

[coalburner|plan]



## Molino de Agua

El molino de agua se puede usar para moler trigo y otros cereales en harina y luego hornearlos en el horno para hacer pan.
El molino funciona con energía hidráulica. Para ello, se debe llevar un canal hasta la rueda del molino.
El flujo de agua y por tanto la rueda del molino se puede controlar mediante una esclusa. La esclusa consta de la compuerta y el manejo de la esclusa.

La imagen de la derecha (haz clic en "Plano") muestra la estructura del molino de agua.

[watermill1|plan]


### Molino TA1

El molino de agua se puede usar para moler trigo y otros cereales en harina y luego hornearlos en el horno para hacer pan. El molino debe estar conectado a la rueda del molino con un eje TA1. La potencia de la rueda del molino solo es suficiente para un molino.

El molino se puede automatizar con la ayuda de una tolva Minecart, de modo que la harina, por ejemplo, se transporte directamente del molino a un horno para hacer pan con ella.

[watermill2|plan]

### Compuerta de esclusa TA1

La válvula de la compuerta de esclusa debe colocarse directamente junto a un estanque o en un arroyo a la misma altura que la superficie del agua.
Cuando se abre la compuerta, el agua fluye a través de la corredera. Este agua luego debe dirigirse a la rueda del molino, donde impulsa el molino.

[ta1_sluice|image]

### Manija de esclusa TA1

La manija de esclusa TA1 debe colocarse sobre la compuerta de esclusa. La compuerta se puede abrir con la ayuda de la manija de la esclusa (clic derecho).

[ta1_sluice_handle|image]

### Tabla de madera de manzano TA1

Bloque en diferentes tipos de madera para construir el canal del molino. Sin embargo, también se puede utilizar cualquier otro material.

[ta1_board1|image]

### Tabla de canal del molino de manzano TA1

Bloque en diferentes tipos de madera para construir el canal del molino. Este bloque es especialmente adecuado en combinación
con postes de la valla de madera para construir un soporte del canal.

[ta1_board2|image]



## Minerales y Herramientas

TA1 tiene sus propias herramientas como el martillo y la criba de grava, pero también se puede usar la tolva Minecart.

[ta1_gravelsieve|image]


### Martillo

El martillo TA1 se puede usar para golpear/excavar piedra en una mina, pero también para triturar adoquines en grava. El martillo está disponible en diferentes versiones y por tanto con diferentes propiedades: bronce, acero, latón y diamante.

[hammer|image]


### Criba de Grava

Los minerales pueden cribarse de la grava con la criba de grava. Para ello, haz clic en la criba con la grava. La grava cribada y los minerales caen por debajo.

Para no tener que estar horas junto a la criba, el cribado puede automatizarse con la tolva.

[ta1_gravelsieve|image]


### Tolva

La tolva del mod "Minecart" se utiliza principalmente para cargar y descargar Minecarts. Absorbe objetos desde arriba y los pasa hacia la derecha. Por lo tanto, al colocar la tolva, presta atención a la dirección de dispensación.

La tolva también puede extraer objetos de cajas (cofres), siempre que la caja esté junto o encima de la tolva.

La tolva también puede poner objetos en cajas si la caja está junto a la tolva.

[ta1_hopper|image]


### Criba de grava con la tolva

Con la ayuda de dos cajas, dos tolvas y una criba de grava, el proceso de cribado puede automatizarse. El plano de la derecha muestra la estructura.

Asegúrate de que las cajas sean "chest_locked" (cofre bloqueado), de lo contrario alguien robará los valiosos minerales de la caja de abajo.

[hoppersieve|plan]


### Meridium

TA1 tiene su propia aleación metálica el meridium. Los lingotes de Meridium se pueden hacer con el horno de carbón a partir de acero y cristales de mesecons. El Meridium brilla en la oscuridad. Las herramientas hechas de Meridium también brillan y son por tanto muy útiles en la minería subterránea.

[meridium|image]
