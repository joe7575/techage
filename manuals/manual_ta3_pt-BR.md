# TA3: Era do Petróleo

Na TA3, é importante substituir as máquinas a vapor por máquinas mais potentes movidas a eletricidade.

Para fazer isso, é necessário construir usinas termelétricas a carvão e geradores. Logo você perceberá que suas necessidades de eletricidade só podem ser atendidas com usinas movidas a óleo. Portanto, você parte em busca de petróleo. Torres de perfuração e bombas de petróleo ajudam a extrair o óleo. Ferrovias são usadas para transportar o óleo até as usinas.

A era industrial está em seu auge.

[techage_ta3|image]

## Usina Termelétrica a Carvão / Usina Termelétrica a Óleo

A usina termelétrica a carvão é composta por vários blocos e deve ser montada conforme mostrado no plano à direita. São necessários os blocos Fornalha(Firebox) TA3, Topo da Caldeira TA3, Base da Caldeira TA3, Turbina TA3, Gerador TA3 e Resfriador TA3.

A caldeira deve ser preenchida com água. Encha até 10 baldes de água na caldeira ou conecte um tubo de líquido ao topo da caldeira para fornecer água automaticamente via bomba.
A caixa de fogo deve ser preenchida com carvão ou carvão vegetal.
Quando a água estiver quente, o gerador pode ser iniciado.

Alternativamente, a usina pode ser equipada com um queimador de óleo e operada com óleo. O óleo pode ser reabastecido usando uma bomba e um tubo de óleo.

A usina fornece uma saída de 80 ku.

[coalpowerstation|plan]

### TA3 Fornalha(firebox) da  estação de energia

Parte da usina de energia.
A fornalha deve ser preenchida com carvão ou carvão vegetal. O tempo de queima depende da potência solicitada pela usina. Carvão queima por 20s e carvão vegetal por 60s em carga total. Proporcionalmente mais tempo em carga parcial (50% de carga = dobro do tempo).

[ta3_firebox|image]

### TA3 Queimador de Óleo da Usina de Energia

Parte da usina de energia.

O queimador de óleo pode ser preenchido com óleo cru, óleo combustível, nafta ou gasolina. O tempo de queima depende da potência solicitada pela usina. Em carga total, óleo cru queima por 15s, óleo combustível por 20s, nafta por 22s e gasolina por 25s.

Proporcionalmente mais tempo em carga parcial (50% de carga = dobro do tempo).

O queimador de óleo pode armazenar apenas 50 unidades de combustível. Recomenda-se, portanto, um tanque de óleo adicional e uma bomba de óleo.


[ta3_oilbox|image]

### TA3 Base / Topo da Caldeira

Parte da usina de energia. Deve ser preenchida com água. Se não houver mais água ou a temperatura diminuir muito, a usina desliga.

A caldeira pode ser preenchida com água de duas maneiras:
- Manualmente clicando no topo da caldeira com um balde de água (até 10 baldes)
- Automaticamente através de um tubo de líquido conectado ao topo da caldeira usando uma bomba TA3/TA4

O consumo de água da caldeira TA3 é muito menor do que o da máquina a vapor devido ao circuito de vapor fechado.
Com a máquina a vapor, parte da água é perdida como vapor a cada curso do pistão.

[ta3_boiler|image]


### TA3 Turbina

A turbina faz parte da usina de energia. Deve ser colocada ao lado do gerador e conectada à caldeira e ao resfriador por meio de tubos de vapor, conforme mostrado no plano.

[ta3_turbine|image]

### TA3 Gerador

O gerador é usado para gerar eletricidade. Deve ser conectado às máquinas por meio de cabos de energia e caixas de junção.

[ta3_generator|image]


### TA3 Cooler

Usado para resfriar o vapor quente da turbina. Deve ser conectado à caldeira e à turbina por meio de tubos de vapor, conforme mostrado no plano.

[ta3_cooler|image]

## Corrente elétrica

Em TA3 (e TA4), as máquinas são alimentadas por eletricidade. Para isso, máquinas, sistemas de armazenamento e geradores devem ser conectados com cabos de energia.
TA3 possui 2 tipos de cabos de energia:

- Cabos isolados (cabos de energia TA) para instalação local no chão ou em edifícios. Esses cabos podem ser ocultos na parede ou no chão (podem ser "revestidos" com a colher de pedreiro).
- Linhas aéreas (linha de energia TA) para cabeamento externo em longas distâncias. Esses cabos são protegidos e não podem ser removidos por outros jogadores.

Vários consumidores, sistemas de armazenamento e geradores podem ser operados juntos em uma rede de energia. Redes podem ser configuradas com a ajuda das caixas de junção.
Se houver pouca eletricidade fornecida, os consumidores ficam sem energia.
Nesse contexto, também é importante entender a funcionalidade dos blocos de Forceload, porque os geradores, por exemplo, só fornecem eletricidade quando o bloco de mapa correspondente está carregado. Isso pode ser imposto com um bloco de Forceload.

Em TA4, também existe um cabo para o sistema solar.

[ta3_powerswitch|image]

### Importância dos sistemas de armazenamento

Os sistemas de armazenamento na rede elétrica desempenham duas funções:

- Lidar com picos de demanda: Todos os geradores sempre fornecem exatamente a quantidade de energia necessária. No entanto, se os consumidores forem ligados/desligados ou houver flutuações na demanda por outros motivos, os consumidores podem falhar por um curto período. Para evitar isso, deve sempre haver pelo menos um bloco de bateria em cada rede. Isso serve como um buffer e compensa essas flutuações na faixa de segundos.
- Armazenar energia regenerativa: Solar e eólica não estão disponíveis 24 horas por dia. Para que o fornecimento de energia não falhe quando não há produção de eletricidade, um ou mais sistemas de armazenamento devem ser instalados na rede. Alternativamente, as lacunas também podem ser preenchidas com eletricidade de óleo/carvão.

Um sistema de armazenamento indica sua capacidade em kud, ou seja, ku por dia. Por exemplo, um sistema de armazenamento com 100 kud fornece 100 ku por um dia de jogo, ou 10 ku por 10 dias de jogo.

Todas as fontes de energia TA3/TA4 têm características de carregamento ajustáveis. Por padrão, isso é configurado para "80% - 100%". Isso significa que, quando o sistema de armazenamento estiver 80% cheio, a saída é reduzida cada vez mais até desligar completamente em 100%. Se eletricidade for necessária na rede, nunca se atingirá 100%, pois a potência do gerador em algum momento caiu para a demanda de eletricidade na rede e o sistema de armazenamento não está mais sendo carregado, mas apenas os consumidores estão sendo atendidos.

Isso tem várias vantagens:

- As características de carregamento são ajustáveis. Isso significa, por exemplo, que as fontes de energia de óleo/carvão podem ser reduzidas em 60% e as fontes de energia renovável apenas em 80%. Isso significa que o óleo/carvão só é queimado se não houver energia renovável suficiente disponível.
- Várias fontes de energia podem ser operadas em paralelo e são carregadas quase uniformemente, porque todas as fontes de energia trabalham, por exemplo, até 80% da capacidade de carga do sistema de armazenamento em sua capacidade total e depois reduzem sua capacidade ao mesmo tempo.
- Todos os sistemas de armazenamento em uma rede formam um grande buffer. A capacidade de carga e o nível de preenchimento de todo o sistema de armazenamento podem sempre ser lidos em percentagem em todos os sistemas de armazenamento, mas também no terminal de eletricidade.

[power_reduction|image] 

### TA3 Cabo Elétrico

Para fiação local no chão ou em construções.
Ramos podem ser realizados usando caixas de junção. O comprimento máximo do cabo entre máquinas ou caixas de junção é de 1000 m. Um máximo de 1000 nós pode ser conectado em uma rede elétrica. Todos os blocos com conexão elétrica, incluindo caixas de junção, contam como nós.

Como os cabos elétricos não são automaticamente protegidos, as linhas aéreas (TA power line) são recomendadas para distâncias mais longas.

Os cabos elétricos podem ser rebocados com a colher de alvenaria para que fiquem ocultos na parede ou no chão. Todos os blocos de pedra, argila e outros blocos sem "inteligência" podem ser usados como material de reboco. A sujeira não funciona porque pode ser convertida em grama ou algo semelhante, o que destruiria a linha.

Para rebocar, o cabo deve ser clicado com a colher de alvenaria. O material com o qual o cabo deve ser rebocado deve estar no canto mais à esquerda do inventário do jogador.
Os cabos podem ser tornados visíveis novamente clicando no bloco com a colher de alvenaria.

Além dos cabos, a caixa de junção TA e a caixa de interruptores de energia TA também podem ser rebocadas.

[ta3_powercable|image]

### TA Caixa de Junção Elétrica

Com a caixa de junção, a eletricidade pode ser distribuída em até 6 direções. Caixas de junção também podem ser rebocadas (ocultas) com uma colher de alvenaria e tornadas visíveis novamente.

[ta3_powerjunction|image]

### TA Linha de Energia

Com a linha de energia TA e os postes de eletricidade, é possível realizar linhas aéreas razoavelmente realistas. As cabeças dos postes também servem para proteger a linha de energia (proteção). Um poste deve ser colocado a cada 16 m ou menos. A proteção se aplica apenas à linha de energia e aos postes; no entanto, todos os outros blocos nesta área não estão protegidos.

[ta3_powerline|image]

### TA Poste de Energia
Usado para construir postes de eletricidade. É protegido contra destruição pela cabeça do poste de eletricidade e só pode ser removido pelo proprietário.

[ta3_powerpole|image]

### TA Topo do Poste de Energia 
Possui até quatro braços e permite assim a distribuição de eletricidade em até 6 direções.
A cabeça do poste de eletricidade protege as linhas de energia e os postes dentro de um raio de 8 m.

[ta3_powerpole4|image]

### TA Topo do Poste de Energia 2

Esta cabeça de poste de eletricidade tem dois braços fixos e é usada para as linhas aéreas. No entanto, também pode transmitir corrente para baixo e para cima.
A cabeça do poste de eletricidade protege as linhas de energia e os postes dentro de um raio de 8 m.

[ta3_powerpole2|image]

### TA Interruptor de Energia

O interruptor pode ser usado para ligar e desligar a energia. Para isso, o interruptor deve ser colocado em uma caixa de interruptor de energia. A caixa de interruptor de energia deve ser conectada ao cabo de energia em ambos os lados.

[ta3_powerswitch|image]

### TA Interruptor de Energia Pequeno

O interruptor pode ser usado para ligar e desligar a energia. Para isso, o interruptor deve ser colocado em uma caixa de interruptor de energia. A caixa de interruptor de energia deve ser conectada ao cabo de energia em ambos os lados.

[ta3_powerswitchsmall|image]

### TA Caixa de Interruptor de Energia

Veja o interruptor de energia TA.

[ta3_powerswitchbox|image]

### TA3 Pequeno Gerador de Energia

O pequeno gerador de energia funciona com gasolina e pode ser usado para consumidores pequenos com até 12 ku. A gasolina queima por 150s em carga total. Correspondentemente mais tempo em carga parcial (50% de carga = tempo duplo).

O gerador de energia só pode armazenar 50 unidades de gasolina. Portanto, é aconselhável um tanque adicional e uma bomba.

[ta3_tinygenerator|image]

### TA3 Bloco Acumulador

O bloco acumulador (bateria recarregável) é usado para armazenar energia excedente e fornece automaticamente energia em caso de queda de energia (se disponível).
Vários blocos de acumulador juntos formam um sistema de armazenamento de energia TA3. Cada bloco de acumulador possui um display para o estado de carga e para a carga armazenada.
Os valores para toda a rede são sempre exibidos aqui. A carga armazenada é exibida em "kud" ou "ku-dias" (análogo a kWh). Assim, 5 kud correspondem, por exemplo, a 5 ku para um dia de jogo (20 minutos) ou 1 ku para 5 dias de jogo.

Um bloco de acumulador tem 3,33 kud.

[ta3_akkublock|image]

### TA3 Terminal de Energia

O terminal de energia deve ser conectado à rede elétrica. Ele exibe dados da rede elétrica.

As informações mais importantes são exibidas na metade superior:

- potência do gerador atual/máxima
- consumo de energia atual de todos os consumidores
- corrente de carga atual dentro/fora do sistema de armazenamento
- Estado de carga atual do sistema de armazenamento em percentual

O número de blocos da rede é exibido na metade inferior.

Dados adicionais sobre os geradores e sistemas de armazenamento podem ser consultados através da guia "console".

[ta3_powerterminal|image]

### TA3 Motor Elétrico

O Motor Elétrico TA3 é necessário para operar as máquinas TA2 através da rede elétrica. O Motor Elétrico TA3 converte eletricidade em potência de eixo.
Se o motor elétrico não for alimentado com energia suficiente, ele entra em um estado de falha e deve ser reativado com um clique direito.

O motor elétrico consome no máximo 40 ku de eletricidade e fornece do outro lado no máximo 39 ku como potência de eixo. Portanto, ele consome um ku para a conversão.

[ta3_motor|image]


## TA3 Forno Industrial

O forno industrial TA3 serve como complemento aos fornos normais. Isso significa que todos os produtos podem ser fabricados com receitas de "cozimento", mesmo em um forno industrial. No entanto, também existem receitas especiais que só podem ser feitas em um forno industrial.
O forno industrial possui seu próprio menu para seleção de receitas. Dependendo dos produtos no inventário do forno industrial à esquerda, o produto de saída pode ser selecionado à direita.

O forno industrial requer eletricidade (para o impulsionador) e óleo combustível/gasolina para o queimador. O forno industrial deve ser montado conforme mostrado no plano à direita.

Veja também o aquecedor TA4.

[ta3_furnace|plan]

### TA3 Forno - Queimador de Óleo

Parte do forno industrial TA3.

O queimador de óleo pode ser operado com óleo bruto, óleo combustível, nafta ou gasolina. O tempo de queima é de 64 s para óleo bruto, 80 s para óleo combustível, 90 s para nafta e 100 s para gasolina.

O queimador de óleo pode armazenar apenas 50 unidades de combustível. Portanto, é aconselhável um tanque adicional e uma bomba.

[ta3_furnacefirebox|image]

### TA3 Forno - Parte Superior

Faz parte do forno industrial TA3. Consulte o forno industrial TA3.

[ta3_furnace|image]

### TA3 Reforço

Faz parte do forno industrial TA3. Consulte o forno industrial TA3.

[ta3_booster|image]


## Líquidos

Líquidos como água ou óleo só podem ser bombeados através de tubulações especiais e armazenados em tanques. Assim como com a água, existem recipientes (latas, barris) nos quais o líquido pode ser armazenado e transportado.

Também é possível conectar vários tanques usando as tubulações amarelas e conectores. No entanto, os tanques devem ter o mesmo conteúdo e sempre deve haver pelo menos um tubo amarelo entre o tanque, a bomba e o tubo distribuidor.

Por exemplo, não é possível conectar dois tanques diretamente a um tubo distribuidor.

O enchimento de líquidos é usado para transferir líquidos de recipientes para tanques. O plano mostra como latas ou barris com líquidos são empurrados para um enchimento de líquidos através de empurradores. O recipiente é esvaziado no enchimento de líquidos e o líquido é conduzido para baixo no tanque.

O enchimento de líquidos também pode ser colocado sob um tanque para esvaziar o tanque.

[ta3_tank|plan]

### TA3 Tanque

Líquidos podem ser armazenados em um tanque. Um tanque pode ser preenchido ou esvaziado usando uma bomba. Para fazer isso, a bomba deve ser conectada ao tanque por meio de um tubo (tubos amarelos).

Um tanque também pode ser preenchido ou esvaziado manualmente clicando no tanque com um recipiente de líquido cheio ou vazio (barril, galão). Deve-se observar que os barris só podem ser completamente preenchidos ou esvaziados. Se, por exemplo, houver menos de 10 unidades no tanque, esse restante deve ser removido com galões ou esvaziado com uma bomba.

Um tanque TA3 pode armazenar 1000 unidades ou 100 barris de líquido.

[ta3_tank|image]

### TA3 Bomba

A bomba pode ser usada para bombear líquidos de tanques ou recipientes para outros tanques ou recipientes. A direção da bomba (seta) deve ser observada. As linhas amarelas e os conectores também permitem organizar vários tanques em cada lado da bomba. No entanto, os tanques devem ter o mesmo conteúdo.

A bomba TA3 bombeia 4 unidades de líquido a cada dois segundos.

Observação 1: A bomba não deve ser colocada diretamente ao lado do tanque. Deve sempre haver pelo menos um pedaço de tubo amarelo entre eles.

[ta3_pump|image]

### TA Liquid Filler

O liquid filler é usado para transferir líquidos entre recipientes e tanques.

- Se o liquid filler for colocado sob um tanque e barris vazios forem colocados no liquid filler com um empurrador ou manualmente, o conteúdo do tanque é transferido para os barris e os barris podem ser removidos da saída
- Se o liquid filler for colocado em cima de um tanque e se recipientes cheios forem colocados no liquid filler com um empurrador ou manualmente, o conteúdo é transferido para o tanque e os recipientes vazios podem ser removidos no lado de saída

Deve-se observar que os barris só podem ser completamente cheios ou esvaziados. Se, por exemplo, houver menos de 10 unidades no tanque, este restante deve ser removido com recipientes ou bombeado vazio.

[ta3_filler|image]

### TA4 Tubos(pipe)

Os tubos amarelos são usados para a transmissão de gás e líquidos.
O comprimento máximo do tubo é 100m.

[ta3_pipe|image]

### TA3 Tubos de parede (entre-blocos)

Os blocos servem como aberturas de parede para os tubos, para que não fiquem buracos abertos.

[ta3_pipe_wall_entry|image]

### TA Válvula

Existe uma válvula para os tubos amarelos, que pode ser aberta e fechada com um clique do mouse.
A válvula também pode ser controlada por comandos ligar/desligar.

[ta3_valve|image]


## Produção de Óleo

Para alimentar seus geradores e fogões com óleo, você deve primeiro procurar óleo e construir uma torre de perfuração para extrair o óleo.
Para isso, são utilizados o explorador de óleo TA3, a caixa de perfuração de óleo TA3 e o macaco de bomba de óleo TA3.

[techage_ta3|image]

### TA3 Explorador de petróleo

Você pode procurar petróleo com o explorador de petróleo. Para fazer isso, coloque o bloco no chão e clique com o botão direito para iniciar a busca. O explorador de petróleo pode ser usado tanto acima quanto abaixo do solo em todas as profundidades.
A saída do chat mostra a profundidade até a qual o petróleo foi procurado e quanto petróleo foi encontrado.
Você pode clicar várias vezes no bloco para procurar petróleo em áreas mais profundas. Os campos de petróleo variam em tamanho de 4.000 a 20.000 itens.

Se a busca não der certo, você deve mover o bloco aproximadamente 16 m para frente.
O explorador de petróleo sempre procura petróleo em todo o bloco do mapa e abaixo, no qual foi colocado. Uma nova busca no mesmo bloco do mapa (campo 16x16) portanto, não faz sentido.

Se o petróleo for encontrado, a localização para a torre de perfuração é exibida. Você precisa erguer a torre de perfuração dentro da área mostrada, é melhor marcar o local com uma placa e proteger toda a área contra jogadores estrangeiros.

Não desista de procurar petróleo muito rapidamente. Se tiver azar, pode levar muito tempo para encontrar um poço de petróleo.
Também não faz sentido procurar em uma área que outro jogador já tenha procurado. A chance de encontrar petróleo é a mesma para todos os jogadores.

O explorador de petróleo pode ser sempre usado para procurar petróleo.

[ta3_oilexplorer|image]

### TA3 Caixa de perfuração de petróleo

A caixa de perfuração de petróleo deve ser colocada na posição indicada pelo explorador de petróleo. Perfurar petróleo em outro lugar não tem sentido.
Se o botão na caixa de perfuração de petróleo for clicado, a torre de perfuração será erguida acima da caixa. Isso leva alguns segundos.
A caixa de perfuração de petróleo tem 4 lados, em IN o tubo de perfuração deve ser entregue via pusher e em OUT o material de perfuração deve ser removido. A caixa de perfuração de petróleo deve ser alimentada com eletricidade por um dos outros dois lados.

A caixa de perfuração de petróleo perfura até o campo de petróleo (1 metro em 16 s) e requer 16 ku de eletricidade.
Depois que o campo de petróleo for alcançado, a torre de perfuração pode ser desmontada e a caixa removida.

[ta3_drillbox|image]

### TA3 Bomba de petróleo

A bomba de petróleo (pumpjack) deve ser colocada no lugar da caixa de perfuração de petróleo. A bomba de petróleo também requer eletricidade (16 ku) e fornece uma unidade de petróleo a cada 8 segundos. O petróleo deve ser coletado em um tanque. Para fazer isso, a bomba de petróleo deve ser conectada ao tanque por meio de tubos amarelos.
Depois que todo o petróleo for bombeado para fora, a bomba de petróleo também pode ser removida.

[ta3_pumpjack|image]

### TA3 Haste de perfuração

A haste de perfuração é necessária para perfurar. Tantos itens de haste de perfuração são necessários quanto a profundidade especificada para o campo de petróleo. A haste de perfuração é inútil após a perfuração, mas também não pode ser desmontada e permanece no solo. No entanto, há uma ferramenta para remover os blocos de haste de perfuração (-> Ferramentas -> TA3 Alicate de haste de perfuração(drill pipe pliers)).

[ta3_drillbit|image]

### Tanque de petróleo

O tanque de petróleo é a versão grande do tanque TA3 (ver líquidos -> Tanque TA3).

O tanque grande pode armazenar 4000 unidades de petróleo, mas também qualquer outro tipo de líquido.

[oiltank|image]


## Transporte de Petróleo

### Transporte de Petróleo por Vagões Tanque

Os vagões tanque podem ser usados para transportar petróleo do poço de petróleo para a usina de processamento de petróleo. Um vagão tanque pode ser preenchido ou esvaziado diretamente usando bombas. Em ambos os casos, os tubos amarelos devem ser conectados ao vagão tanque de cima.

Os seguintes passos são necessários:

- Coloque o vagão tanque na frente do bloco para-choque da ferrovia. O bloco para-choque ainda não deve estar programado com um tempo para que o vagão tanque não comece automaticamente.
- Conecte o vagão tanque à bomba usando tubos amarelos.
- Ligue a bomba.
- Programe o para-choque com um tempo (10 - 20s).

Essa sequência deve ser observada em ambos os lados (encher / esvaziar).

[tank_cart|image]

### Oil transportation with barrels over Minecarts

Canisters and barrels can be loaded into the Minecarts. To do this, the oil must first be transferred to barrels. The oil barrels can be pushed directly into the Minecart with a pusher and tubes (see map). The empty barrels, which come back from the unloading station by Minecart, can be unloaded using a hopper, which is placed under the rail at the stop.

It is not possible with the hopper to both **unload the empty barrels and load the full barrels at a stop**. The hopper immediately unloads the full barrels. It is therefore advisable to set up 2 stations on the loading and unloading side and then program the Minecart accordingly using a recording run.

The plan shows how the oil can be pumped into a tank and filled into barrels via a liquid filler and loaded into Minecarts.

For the Minecarts to start again automatically, the bumper blocks must be configured with the station name and waiting time. 5 s are sufficient for unloading. However, since the pushers always go into standby for several seconds when there is no Minecart, a time of 15 or more seconds must be entered for loading.

[ta3_loading|plan]

### Transporte de Petróleo com Barris por Minecarts

As latas e barris podem ser carregados nos Minecarts. Para fazer isso, o petróleo deve primeiro ser transferido para os barris. Os barris de petróleo podem ser empurrados diretamente para dentro do Minecart com um empurrador e tubos (veja o mapa). Os barris vazios, que retornam da estação de descarga por Minecart, podem ser descarregados usando um funil, que é colocado sob os trilhos na parada.

Não é possível com o funil **descarregar os barris vazios e carregar os barris cheios em uma parada**. O funil descarrega imediatamente os barris cheios. Portanto, é aconselhável configurar 2 estações no lado de carregamento e descarregamento e, em seguida, programar o Minecart de acordo com uma corrida de gravação.

O plano mostra como o petróleo pode ser bombeado para um tanque, preenchido em barris via um dispositivo de enchimento de líquidos e carregado em Minecarts.

Para que os Minecarts reiniciem automaticamente, os blocos para-choque devem ser configurados com o nome da estação e o tempo de espera. 5 segundos são suficientes para descarregar. No entanto, como os empurradores sempre entram em espera por vários segundos quando não há Minecart, um tempo de 15 segundos ou mais deve ser inserido para carregar.

[ta3_loading|plan]

### Carrinho-tanque

O carrinho-tanque é usado para transportar líquidos. Assim como os tanques, ele pode ser cheio com bombas ou esvaziado. Em ambos os casos, o tubo amarelo deve ser conectado ao caminhão-tanque de cima.

Cabem 200 unidades no caminhão-tanque.

[tank_cart|image]

### Carrinho-baú

O carrinho-baú é usado para transportar itens. Assim como os baús, ele pode ser cheio ou esvaziado usando um empurrador.

Cabem 4 pilhas no carrinho de baú.

[chest_cart|image]


## Processamento de Petróleo

O petróleo é uma mistura de substâncias e consiste em muitos componentes. O petróleo pode ser decomposto em seus principais componentes, como betume, óleo combustível, nafta, gasolina e gás propano, por meio de uma torre de destilação.
O processamento adicional para produtos finais ocorre no reator químico.

[techage_ta31|image]

### Torre de Destilação

A torre de destilação deve ser montada como no plano no canto superior direito.
O betume é drenado pelo bloco de base. A saída está na parte de trás do bloco de base (observe a direção da seta).
Os blocos "torre de destilação" com os números: 1, 2, 3, 2, 3, 2, 3, 4 são colocados sobre este bloco base.
Óleo combustível, nafta e gasolina são drenados das aberturas de baixo para cima. O gás propano é capturado no topo.
Todas as aberturas na torre devem ser conectadas a tanques.
O reboiler deve ser conectado ao bloco "torre de destilação 1".

O reboiler precisa de eletricidade (não mostrado no plano)!

[ta3_distiller|plan]

#### Refervedor(Reboiler)

O reboiler aquece o petróleo para aproximadamente 400 °C. Ele evapora em grande parte e é alimentado na torre de destilação para resfriamento.

O reboiler requer 14 unidades de eletricidade e produz uma unidade de betume, óleo combustível, nafta, gasolina e propano a cada 16s.
Para isso, o reboiler deve ser alimentado com petróleo por meio de uma bomba.

[reboiler|image]


## Blocos Lógicos / de Comutação

Além dos tubos para transporte de mercadorias, bem como os tubos de gás e energia, há também um nível de comunicação sem fio através do qual os blocos podem trocar dados entre si. Não é necessário desenhar linhas para isso, a conexão entre transmissor e receptor é feita apenas através do número do bloco.

**Info:** Um número de bloco é um número único gerado pelo Techage quando muitos blocos do Techage são colocados. O número do bloco é usado para endereçamento durante a comunicação entre controladores e máquinas Techage. Todos os blocos que podem participar dessa comunicação mostram o número do bloco como texto de informações se você fixar o bloco com o cursor do mouse.

Quais comandos um bloco suporta podem ser lidos e exibidos com a TechAge Info Tool (chave inglesa ou wrench).
Os comandos mais simples suportados por quase todos os blocos são:

- `on` - para ligar o bloco / máquina / lâmpada
- `off` - para desligar o bloco / máquina / lâmpada

Com a ajuda do Terminal TA3, esses comandos podem ser testados muito facilmente. Suponha que uma lâmpada de sinalização seja o número 123.
Então com:

    cmd 123 on

a lâmpada pode ser ligada e com:

    cmd 123 off

a lâmpada pode ser desligada novamente. Esses comandos devem ser inseridos no campo de entrada do terminal TA3.

Comandos como `on` e `off` são enviados ao destinatário sem que uma resposta seja enviada de volta. Portanto, esses comandos podem ser enviados para vários destinatários ao mesmo tempo, por exemplo, com um botão de pressão / interruptor, se vários números forem inseridos no campo de entrada.

Um comando como `state` solicita o status de um bloco. O bloco então envia seu status de volta. Esse tipo de comando confirmado só pode ser enviado para um destinatário de cada vez.
Esse comando também pode ser testado com o terminal TA3 em um empurrador, por exemplo:

    cmd 123 state

As respostas possíveis do empurrador são:
- `running` -> Estou funcionando
- `stopped` -> desligado
- `standby` -> nada a fazer porque o inventário da fonte está vazio
- `blocked` -> não pode fazer nada porque o inventário de destino está cheio

Esse status e outras informações também são exibidos quando a chave inglesa(wrench) é clicada no bloco.

[ta3_logic|image]

### TA3 Botão / Interruptor
O botão/interruptor envia comandos `on` / `off` para os blocos que foram configurados através dos números.
O botão/interruptor pode ser configurado como um botão ou um interruptor. Se for configurado como um botão, o tempo entre os comandos `on` e `off` pode ser definido. Com o modo de operação "no botão", apenas um comando `on` e nenhum comando `off` é enviado.

A caixa de seleção "público" pode ser usada para definir se o botão pode ser usado por todos (marcado) ou apenas pelo próprio proprietário (não marcado).

Nota: Com o programador, os números dos blocos podem ser facilmente coletados e configurados.

[ta3_button|image]

### TA3 Conversor de Comandos

Com o conversor de comandos TA3, os comandos `on` / `off` podem ser convertidos em outros comandos, e o encaminhamento pode ser impedido ou atrasado.
Deve-se inserir o número do bloco de destino ou os números dos blocos de destino, os comandos a serem enviados e os tempos de atraso em segundos. Se nenhum comando for inserido, nada será enviado.

Os números também podem ser programados usando o programador Techage(programmer).

[ta3_command_converter|image]

### TA3 Flip-Flop

O flip-flop TA3 muda de estado a cada comando `on` recebido. Os comandos `off` recebidos são ignorados. Dependendo da alteração de status, os comandos `on` / `off` são enviados alternadamente. Deve-se inserir o número do bloco de destino ou os números dos blocos de destino. Os números também podem ser programados usando o programador Techage.

Por exemplo, lâmpadas podem ser ligadas e desligadas com a ajuda de botões.

[ta3_flipflop|image]

### Bloco Lógico TA3

O bloco lógico TA3 pode ser programado de forma que um ou mais comandos de entrada estejam vinculados a um comando de saída e sejam enviados. Este bloco pode, portanto, substituir vários elementos lógicos, como AND, OR, NOT, XOR, etc.
Os comandos de entrada para o bloco lógico são comandos `ligar` / `desligar`.
Os comandos de entrada são referenciados pelo número, por exemplo, `1234` para o comando do remetente com o número 1234.
O mesmo se aplica aos comandos de saída.

Uma regra é estruturada da seguinte forma:

```
<output> = on/off if <expressão-de-entrada> is true
```

`<output>` é o número do bloco para o qual o comando deve ser enviado.
`<expressão-de-entrada>` é uma expressão booleana onde os números de entrada são avaliados.

**Exemplos para a expressão de entrada**

Negar sinal (NOT):

    1234 == off

AND lógico:

    1234 == on e 2345 == on

OR lógico:

    1234 == ligar ou 2345 == ligar

Os seguintes operadores são permitidos: `and` `or` `on` `off` `me` `==` `~=` `(` `)`

Se a expressão for verdadeira, um comando é enviado para o bloco com o número `<output>`.
Até quatro regras podem ser definidas, sendo que todas as regras são sempre verificadas quando um comando é recebido.
O tempo interno de processamento para todos os comandos é de 100 ms.

Seu próprio número de nó pode ser referenciado usando a palavra-chave `me`. Isso permite que o bloco envie a si mesmo um comando (função flip-flop).

O tempo de bloqueio define uma pausa após um comando, durante a qual o bloco lógico não aceita mais comandos externos. Comandos recebidos durante o período de bloqueio são descartados. O tempo de bloqueio pode ser definido em segundos.

[ta3_logic|image]

### TA3 Repetidor

O repetidor envia o sinal recebido para todos os números configurados.
Isso pode fazer sentido, por exemplo, se você quiser controlar muitos blocos ao mesmo tempo. O repetidor pode ser configurado com o programador, o que não é possível com todos os blocos.

[ta3_repeater|image]

### TA3 Sequenciador

O sequenciador pode enviar uma série de comandos `on` / `off`, em que o intervalo entre os comandos deve ser especificado em segundos. Você pode usá-lo para fazer uma lâmpada piscar, por exemplo.
Até 8 comandos podem ser configurados, cada um com número de bloco de destino e aguardando o próximo comando.
O sequenciador repete os comandos indefinidamente quando "Run endless" está ativado.
Se nada for selecionado, apenas o tempo especificado em segundos é aguardado.

[ta3_sequencer|image]

### TA3 Temporizador

O temporizador pode enviar comandos controlados pelo tempo. O horário, o(s) número(s) de destino e o comando em si podem ser especificados para cada linha de comando. Isso significa que as lâmpadas podem ser ligadas à noite e desligadas pela manhã.

[ta3_timer|image]

### TA3 Terminal

O terminal é usado principalmente para testar a interface de comando de outros blocos (veja "Blocos lógicos / de comutação").
Você também pode atribuir comandos a teclas e usar o terminal de maneira produtiva.

	set <número-do-botão> <texto-do-botão> <comando>

Com `set 1 ON cmd 123 on`, por exemplo, a tecla do usuário 1 pode ser programada com o comando `cmd 123 on`. Se a tecla for pressionada, o comando é enviado e a resposta é exibida na tela.

O terminal possui os seguintes comandos locais:
- `clear` limpa a tela
- `help` exibe uma página de ajuda
- `pub` alterna para o modo público
- `priv` alterna para o modo privado

No modo privado, o terminal só pode ser usado por jogadores que podem construir neste local, ou seja, que têm direitos de proteção.

No modo público, todos os jogadores podem usar as teclas preconfiguradas.

[ta3_terminal|image]


### Lâmpada Colorida TechAge

A lâmpada de sinalização pode ser ligada ou desligada com o comando `on` / `off`. Esta lâmpada não precisa de eletricidade e pode ser colorida com a ferramenta de aerografia do mod "Dyes Unificados" e via comandos Lua/Beduino.

Com o comando de chat `/ta_color`, a paleta de cores com os valores para os comandos Lua/Beduino é exibida e com `/ta_send color <num>` a cor pode ser alterada.

[ta3_colorlamp|image]

### Blocos de Porta/Portão

Com esses blocos, você pode criar portas e portões que podem ser abertos por meio de comandos (blocos desaparecem) e fechados novamente. Um controlador de porta é necessário para cada portão ou porta.

A aparência dos blocos pode ser ajustada por meio do menu de blocos.
Isso permite a criação de portas secretas que só se abrem para certos jogadores (com a ajuda do detector de jogadores).

[ta3_doorblock|image]

### TA3 Controlador de Porta

O controlador de porta é usado para controlar os blocos de porta/portão TA3. Com o controlador de porta, os números dos blocos de porta/portão devem ser inseridos. Se um comando `on` / `off` for enviado para o controlador de porta, isso abre/fecha a porta ou portão.

[ta3_doorcontroller|image]

### Controlador de Porta TA3 II

O Controlador de Porta II pode remover e definir todos os tipos de blocos. Para ensinar ao Controlador de Porta II, o botão "Record" deve ser pressionado. Em seguida, todos os blocos que devem fazer parte da porta/portão devem ser clicados. Depois, o botão "Done" deve ser pressionado. Até 16 blocos podem ser selecionados. Os blocos removidos são salvos no inventário do controlador. A função do controlador pode ser testada manualmente usando os botões "Remove" ou "Set". Se um comando `on` /`off` for enviado para o Controlador de Porta II, ele remove ou define os blocos também.

Com `$send_cmnd(número_do_nó, "exchange", 2)` blocos individuais podem ser definidos, removidos ou substituídos por outros blocos do inventário.

Com `$send_cmnd(número_do_nó, "set", 2)` um bloco do inventário pode ser definido explicitamente, desde que o slot do inventário não esteja vazio.

Um bloco pode ser removido novamente com `$send_cmnd(número_do_nó, "dig", 2)` se o slot do inventário estiver vazio.

O nome do bloco definido é retornado com `$send_cmnd(número_do_nó, "get", 2)`.

O número do slot do inventário (1 .. 16) deve ser passado como carga útil em todos os três casos.

Isso também pode ser usado para simular escadas extensíveis e coisas do tipo.

[ta3_doorcontroller|image]

### TA3 Bloco de Som

Diferentes sons podem ser reproduzidos com o bloco de som. Todos os sons dos Mods Techage, Signs Bot, Hyperloop, Unified Inventory, TA4 Jetpack e Minetest Game estão disponíveis.

Os sons podem ser selecionados e reproduzidos pelo menu e via comando.

- Comando `on` para reproduzir um som
- Comando `sound <índice>` para selecionar um som via o índice
- Comando `gain <volume>` para ajustar o volume via o valor `<volume>` (1 a 5).

[ta3_soundblock|image]

### TA3 Conversor Mesecons

O conversor Mesecons é utilizado para converter comandos de ligar/desligar do Techage em sinais Mesecons e vice-versa.
Para fazer isso, um ou mais números de nó devem ser inseridos e o conversor deve ser conectado a blocos Mesecons por meio de cabos Mesecons. O conversor Mesecons também pode ser configurado com o programador.
O conversor Mesecons aceita até 5 comandos por segundo; ele se desativa em cargas mais altas.

**Este nó só existe se o mod mesecons estiver ativo!**

[ta3_mesecons_converter|image]


## Detectores

Os detectores escaneiam o ambiente e enviam um comando `on` quando a busca é reconhecida.

[ta3_nodedetector|image]


### TA3 Detector

O detector é um bloco de tubo especial que detecta quando itens passam pelo tubo. Para fazer isso, ele deve ser conectado a tubos dos dois lados. Se os itens forem empurrados para o detector com um empurrador(pusher), eles são passados automaticamente.
Ele envia um comando `on` quando um item é reconhecido, seguido por um `off` um segundo depois.
Em seguida, outros comandos são bloqueados por 8 segundos.
O tempo de espera e os itens que devem acionar um comando podem ser configurados usando o menu de chave inglesa(wrench).

[ta3_detector|image]

### TA3 Cart Detector

O detector de carrinho envia um comando `on` se reconhecer um carrinho (Minecart) diretamente na frente dele. Além disso, o detector também pode reiniciar o carrinho quando recebe um comando `on`.

O detector também pode ser programado com seu próprio número. Nesse caso, ele empurra todos os vagões que param perto dele (um bloco em todas as direções).

[ta3_cartdetector|image]


### TA3 Node Detector

O detector de nó envia um comando `on` se detectar que nós (blocos) aparecem ou desaparecem na frente dele, mas deve ser configurado de acordo. Após retornar o detector ao estado padrão (bloco cinza), um comando `off` é enviado. Blocos válidos são todos os tipos de blocos e plantas, mas não animais ou jogadores. O alcance do sensor é de 3 blocos por metro na direção da seta.

[ta3_nodedetector|image]

### TA3 Detector de jogador(Player detector)

O detector de jogador envia um comando `on` se detectar um jogador dentro de 4m do bloco. Se o jogador sair da área, um comando `off` é enviado.
Se a pesquisa deve ser limitada a jogadores específicos, esses nomes de jogador também podem ser inseridos.

[ta3_playerdetector|image]

### TA3 Detector de luz(Light detector)

O detector de luz envia um comando `on` se o nível de luz do bloco acima exceder um certo nível, que pode ser definido através do menu de clique direito.
Se você tiver um Controlador Lua TA4, pode obter o nível exato de luz com $get_cmd(num, 'light_level')

[ta3_lightdetector|image]


## Máquinas TA3

TA3 possui as mesmas máquinas que o TA2, apenas estas são mais poderosas e requerem eletricidade em vez de movimento por eixo.
Portanto, abaixo são fornecidos apenas os dados técnicos diferentes.

[ta3_grinder|image]


### TA3 Pusher 

A função corresponde à do TA2.
A capacidade de processamento é de 6 itens a cada 2 segundos.

[ta3_pusher|image]

### TA3 Distributor

A função do Distribuidor TA3 corresponde à do TA2.
A capacidade de processamento é de 12 itens a cada 4 segundos.

[ta3_distributor|image]


### TA3 Autocrafter

A função corresponde à do TA2.
A capacidade de processamento é de 2 itens a cada 4 segundos. O autocrafter requer 6 ku de eletricidade.

[ta3_autocrafter|image]


### TA3 Electronic Fab

A função corresponde à do TA2, apenas os chips WLAN do TA4 são produzidos aqui.
A capacidade de processamento é de um chip a cada 6 segundos. O bloco requer 12 ku de eletricidade para isso.

[ta3_electronicfab|image]

### TA3 Quarry

A função corresponde à do TA2.
A profundidade máxima é de 40 metros. A pedreira requer 12 ku de eletricidade.

[ta3_quarry|image]


### TA3 Gravel Sieve

A função corresponde à do TA2.
A capacidade de processamento é de 2 itens a cada 4 segundos. O bloco requer 4 ku de eletricidade.

[ta3_gravelsieve|image]


### TA3 Gravel Rinser

A função corresponde à do TA2.
A probabilidade também é a mesma que a do TA2. O bloco também requer 3 ku de eletricidade.
Mas, ao contrário do TA2, o status do bloco TA3 pode ser lido (controlador)

[ta3_gravelrinser|image]


### TA3 Grinder

A função corresponde à do TA2.
A capacidade de processamento é de 2 itens a cada 4 segundos. O bloco requer 6 ku de eletricidade.

[ta3_grinder|image]

### TA3 Injetor

O injetor é um TA3 pusher com propriedades especiais. Ele possui um menu para configuração. Até 8 itens podem ser configurados aqui. Ele apenas pega esses itens de um baú para passá-los para as máquinas com receitas (autocrafter, forno industrial e electronic fab).

Ao passar, apenas uma posição no inventário é usada na máquina de destino. Se, por exemplo, apenas as três primeiras entradas estiverem configuradas no injetor, apenas as três primeiras posições de armazenamento no inventário da máquina serão usadas. Isso evita o transbordamento no inventário da máquina.

O injetor também pode ser alternado para o "modo pull". Então ele apenas retira itens do baú das posições que estão definidas na configuração do injetor. Nesse caso, o tipo e a posição do item devem corresponder. Isso permite esvaziar entradas específicas do inventário de um baú.

A capacidade de processamento é de até 8 vezes um item a cada 4 segundos.

[ta3_injector|image]


## Ferramentas

### Techage Info Tool

O Techage Info Tool (chave inglesa de ponta aberta) possui várias funções. Ele mostra a hora, posição, temperatura e bioma quando um bloco desconhecido é clicado.
Se você clicar em um bloco TechAge com interface de comando, todos os dados disponíveis serão mostrados (consulte também "Blocos lógicos / de comutação").

Com Shift + clique direito, um menu estendido pode ser aberto para alguns blocos. Dependendo do bloco, dados adicionais podem ser chamados ou configurações especiais podem ser feitas aqui. No caso de um gerador, por exemplo, a curva de carga/desligamento pode ser programada.

[ta3_end_wrench|image]

### TechAge Programmer (Programador)

Com o programador, números de bloco podem ser coletados de vários blocos com um clique direito e gravados em um bloco como um botão / interruptor com um clique esquerdo.
Se você clicar no ar, a memória interna é apagada.

[ta3_programmer|image]

### TechAge Trowel / Trowel

A colher de pedreiro é usada para revestir cabos de energia. Veja também "Cabo de energia TA".

[ta3_trowel|image]

### TA3 chave de cano 

Esta ferramenta pode ser usada para remover blocos de tubo se, por exemplo, um túnel precisar passar por lá.

[ta3_drill_pipe_wrench|image]

### Techage Screwdriver

A chave de fenda Techage serve como substituto da chave de fenda normal. Ela possui as seguintes funções:

- Clique esquerdo: girar o bloco para a esquerda
- Clique direito: girar a face visível do bloco para cima
- Shift + clique esquerdo: salvar o alinhamento do bloco clicado
- Shift + clique direito: aplicar o alinhamento salvo ao bloco clicado

[ta3_screwdriver|image] 

### TechAge Assembly Tool

A TechAge Assembly Tool é usada para remover e reposicionar blocos Techage sem que esses blocos percam seu número de bloco ou recebam um novo número ao serem configurados. Isso é útil, por exemplo, para pedreiras, já que muitas vezes precisam ser movidas.

- Botão esquerdo: remover um bloco
- Botão direito: configurar um bloco

O bloco que foi removido anteriormente com a ferramenta de montagem e que será colocado novamente deve estar no extremo esquerdo do inventário do jogador.

[techage:assembly_tool|image]






























