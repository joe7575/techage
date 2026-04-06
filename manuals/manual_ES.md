# Tech Age Mod

Tech Age es un mod de tecnología con 5 etapas de desarrollo:

TA1: Edad del Hierro  
Usa herramientas y ayudas como hornos de carbón, cribas de grava, martillos y tolvas para extraer y procesar los minerales y metales necesarios.

TA2: Edad del Vapor  
Construye una máquina de vapor con ejes de transmisión y úsala para operar tus primeras máquinas de procesamiento de minerales.

TA3: Edad del Petróleo  
Encuentra y extrae petróleo, construye ferrocarriles para el transporte del petróleo. Una central eléctrica proporciona la electricidad necesaria para tus máquinas. La luz eléctrica ilumina tus instalaciones industriales.

TA4: Presente  
Las fuentes de energía renovables como el viento, el sol y los biocombustibles te ayudan a dejar la era del petróleo. Con tecnologías modernas y máquinas inteligentes te embarcas hacia el futuro.

TA5: Futuro  
Máquinas para superar el espacio y el tiempo, nuevas fuentes de energía y otros logros dan forma a tu vida.


Nota: Con un clic en el signo más accedes a los subcapítulos de este manual.

[techage_ta4|image]



## Consejos

Esta documentación está disponible tanto "en el juego" (plano de construcción de bloques) como en GitHub como archivos MD.

- Enlace: https://github.com/joe7575/techage/wiki

Los planos de construcción (diagramas) para la construcción de las máquinas y las imágenes solo están disponibles en el juego.

Con Tech Age tienes que empezar desde el principio. Solo puedes crear bloques TA2 con los objetos de TA1, para TA3 necesitas los resultados de TA2, etc.

En TA2, las máquinas solo funcionan con ejes de transmisión.

A partir de TA3, las máquinas funcionan con electricidad y tienen una interfaz de comunicación para el control remoto.

TA4 añade más fuentes de energía, pero también mayores desafíos logísticos (líneas eléctricas, transporte de objetos).



## Cambios desde la versión 1.0

Desde la V1.0 (17/07/2021) lo siguiente ha cambiado:

- El algoritmo para calcular la distribución de energía ha cambiado. Esto hace que los sistemas de almacenamiento de energía sean más importantes. Estos compensan las fluctuaciones, lo cual es importante en redes más grandes con varios generadores.
- Por esta razón, TA2 obtuvo su propio almacenamiento de energía.
- Los bloques de batería de TA3 también sirven como almacenamiento de energía. Su funcionalidad ha sido adaptada en consecuencia.
- El sistema de almacenamiento TA4 ha sido revisado. Los intercambiadores de calor han recibido un nuevo número porque la funcionalidad se ha movido del bloque inferior al bloque central. Si estos eran controlados de forma remota, el número de nodo debe adaptarse. Los generadores ya no tienen su propio menú, sino que solo se encienden/apagan a través del intercambiador de calor. ¡El intercambiador de calor y el generador ahora deben estar conectados a la misma red!
- Varias redes eléctricas ahora pueden acoplarse mediante bloques transformadores TA4.
- También es nuevo un bloque de medidor eléctrico TA4 para subredes.
- Al menos un bloque de batería o un sistema de almacenamiento en cada red


### Consejos sobre el cambio

Muchos más bloques han recibido cambios menores. Por lo tanto, es posible que las máquinas o los sistemas no vuelvan a arrancar inmediatamente después del cambio. En caso de mal funcionamiento, los siguientes consejos ayudarán:

- Apagar y encender las máquinas de nuevo
- Retirar un bloque de cable eléctrico y volver a colocarlo
- Retirar el bloque completamente y volver a colocarlo



## Minerales y Minerales

Techage añade algunos objetos nuevos al juego:

- Meridium - una aleación para la producción de herramientas luminosas en TA1
- Usmium - un mineral que se extrae en TA2 y se necesita para TA3
- Baborium - un metal que se necesita para las recetas en TA3
- Petróleo - se necesita en TA3
- Bauxita - un mineral de aluminio que se necesita en TA4 para producir aluminio
- Basalto - se forma cuando el agua y la lava se tocan


### Meridium

El Meridium es una aleación de acero y cristales de mesecons. Los lingotes de Meridium se pueden hacer con el horno de carbón a partir de acero y cristales de mesecons. El Meridium brilla en la oscuridad. Las herramientas hechas de Meridium también brillan y son por tanto muy útiles en la minería subterránea.

[meridium|image]


### Usmium

El Usmium solo se presenta en forma de pepitas y solo se puede obtener lavando grava con el sistema de lavado de grava TA2/TA3.

[usmium|image]


### Baborium

El Baborium solo se puede obtener de la minería subterránea. Esta sustancia solo se encuentra a una profundidad de -250 a -340 metros.

El Baborium solo se puede fundir en el Horno Industrial TA3.


[baborium|image]


### Petróleo

El petróleo solo se puede encontrar con la ayuda del Explorador y extraerse con la ayuda de las máquinas TA3 adecuadas. Ver TA3.

[oil|image]


### Bauxita

La bauxita solo se extrae en la minería subterránea. La bauxita solo se encuentra en la piedra a una altura entre -50 y -500 metros.
Se requiere para la producción de aluminio, que se usa principalmente en TA4.

[bauxite|image]


### Basalto

El basalto solo se crea cuando la lava y el agua se juntan.
Lo mejor es montar un sistema donde una fuente de lava y una fuente de agua fluyan juntas.
El basalto se forma donde ambos líquidos se encuentran.
Puedes construir un generador de basalto automatizado con el Sign Bot.

[basalt|image]


## Historial

- 28.09.2019: Sistema solar añadido
- 05.10.2019: Datos sobre el sistema solar y descripción del inversor y el terminal de energía modificados
- 18.11.2019: Capítulo para minerales, reactor, aluminio, silo, bauxita, calefacción del horno, sistema de lavado de grava añadido
- 22.02.2020: correcciones y capítulos sobre la actualización
- 29.02.2020: Controlador ICTA añadido y más correcciones
- 14.03.2020 Controlador Lua añadido y más correcciones
- 22.03.2020 Más bloques TA4 añadidos
