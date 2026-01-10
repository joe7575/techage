# TA4: Presente

Fontes de energia renováveis, como vento, sol e biocombustíveis, ajudam você a sair da era do petróleo. Com tecnologias modernas e máquinas inteligentes, você parte para o futuro.

[techage_ta4|image]


## Turbina eólica

Uma turbina eólica sempre fornece eletricidade quando há vento. Não há vento no jogo, mas o mod simula isso girando as turbinas eólicas somente pela manhã (5:00 - 9:00) e à noite (17:00 - 21:00). Uma turbina eólica só fornece eletricidade se estiver instalada em um local adequado.

As usinas eólicas da TA são usinas puramente offshore, o que significa que elas precisam ser construídas no mar. Isso significa que as turbinas eólicas só podem ser construídas em um bioma marinho (oceano) e que deve haver água suficiente e uma visão clara ao redor do mastro.

Para encontrar um local adequado, clique na água com a chave inglesa (TechAge Info Tool). Uma mensagem de bate-papo mostrará se essa posição é adequada para o mastro da turbina eólica.

A corrente deve ser conduzida do bloco do rotor até o mastro. Primeiro, puxe a linha de energia para cima e, em seguida, "engesse" o cabo de energia com blocos de pilar TA4. Uma plataforma de trabalho pode ser construída abaixo. A planta à direita mostra a estrutura na parte superior.

A turbina eólica fornece 70 ku, mas apenas 8 horas por dia (veja acima).

[ta4_windturbine|plan]


### Turbina eólica TA4

O bloco da turbina eólica (rotor) é o coração da turbina eólica. Esse bloco deve ser colocado no topo do mastro. Idealmente, em Y = 15, então você fica dentro de um bloco de mapa/carga.
Quando você inicia a turbina, todas as condições para a operação da turbina eólica são verificadas. Se todas as condições forem atendidas, as pás do rotor (asas) aparecerão automaticamente. Caso contrário, você receberá uma mensagem de erro.

[ta4_windturbine|image]


### Nacelle da turbina eólica TA4

Esse bloco deve ser colocado na extremidade preta do bloco da turbina eólica.

[ta4_nacelle|image]


### Lâmpada de sinalização de turbina eólica TA4

Essa luz intermitente serve apenas para fins decorativos e pode ser colocada na parte superior do bloco da turbina eólica.

[ta4_blinklamp|image]


### Pilar TA4

Isso constrói o mastro da turbina eólica. No entanto, esses blocos não são fixados manualmente, mas devem ser fixados com a ajuda de uma espátula(trowel), de modo que a linha de energia para a ponta do mastro seja substituída por esses blocos (consulte Cabo de energia TA).

[ta4_pillar|image]


## Sistema Solar

O sistema solar só produz eletricidade quando o sol está brilhando. No jogo, isso ocorre todo dia de jogo, das 6h às 18h.
A mesma energia está sempre disponível durante esse período. Após as 18h00, os módulos solares se desligam completamente.

A temperatura do bioma é decisiva para o desempenho dos módulos solares. Quanto mais quente for a temperatura, maior será o rendimento.
A temperatura do bioma pode ser determinada com a Techage Info Tool (chave inglesa). Normalmente, ela oscila entre 0 e 100:

- a potência total está disponível a 100
- a 50, metade da potência está disponível
- em 0, não há serviço disponível

Portanto, é aconselhável procurar estepes e desertos quentes para o sistema solar.
As linhas aéreas estão disponíveis para o transporte de eletricidade.
No entanto, também é possível produzir hidrogênio, que pode ser transportado e convertido novamente em eletricidade no destino.

A menor unidade em um sistema solar é composta por dois módulos solares e um módulo de transporte. O módulo de transporte deve ser colocado primeiro, com os dois módulos solares à esquerda e à direita próximos a ele (não acima!).

A planta à direita mostra 3 unidades, cada uma com dois módulos solares e um módulo de suporte, conectadas ao inversor por meio de cabos vermelhos.

Os módulos solares fornecem tensão CC, que não pode ser alimentada diretamente na rede elétrica. Portanto, as unidades solares devem primeiro ser conectadas ao inversor por meio do cabo vermelho. Ele consiste em dois blocos, um para o cabo vermelho dos módulos solares (CC) e outro para o cabo de alimentação cinza da rede elétrica (CA).

A área do mapa onde o sistema solar está localizado deve estar totalmente carregada. Isso também se aplica à posição direta acima do módulo solar, pois a intensidade da luz é medida regularmente nesse local. Portanto, é aconselhável definir primeiro um bloco de carga e depois colocar os módulos dentro dessa área.

[ta4_solarplant|plan]


### Módulo solar TA4

O módulo solar deve ser colocado no módulo de suporte. São sempre necessários dois módulos solares.
Em um par, os módulos solares têm desempenho de até 3 ku, dependendo da temperatura.
Com os módulos solares, deve-se tomar cuidado para que eles tenham plena luz do dia e não sejam sombreados por blocos ou árvores. Isso pode ser testado com a Info Tool (wrench ou chave inglesa).

[ta4_solarmodule|image]


### Módulo de transporte solar TA4

O módulo de suporte está disponível em duas alturas (1m e 2m). Ambos são funcionalmente idênticos.
Os módulos portadores podem ser colocados diretamente um ao lado do outro e, assim, conectados para formar uma fileira de módulos. A conexão com o inversor ou com outras séries de módulos deve ser feita com os cabos vermelhos de baixa tensão ou com as caixas de junção de baixa tensão.

[ta4_solarcarrier|image]


### Inversor solar TA4

O inversor converte a energia solar (CC) em corrente alternada (CA) para que ela possa ser alimentada na rede elétrica.
Um inversor pode alimentar um máximo de 100 ku de eletricidade, o que corresponde a 33 módulos solares ou mais.

[ta4_solar_inverter|image]


### Cabo de baixa potência TA4

O cabo de baixa tensão é usado para conectar fileiras de módulos solares ao inversor. O cabo não deve ser usado para outros fins.

O comprimento máximo do cabo é de 200 m.

[ta4_powercable|image]


### Caixa de junção de baixa tensão TA4

A caixa de junção deve ser colocada no chão. Ela tem apenas 4 conexões (nas 4 direções).

[ta4_powerbox|image]


### Célula solar para lâmpadas de rua TA4

Como o nome sugere, a célula solar para lâmpadas de rua é usada para alimentar uma lâmpada de rua. Uma célula solar pode alimentar duas lâmpadas (1 ku). A célula solar armazena a energia do sol durante o dia e fornece a eletricidade para a lâmpada à noite. Isso significa que a lâmpada só brilha no escuro.

Essa célula solar não pode ser combinada com os outros módulos solares.

[ta4_minicell|image]



## Armazenamento de energia térmica

O armazenamento de energia térmica substitui o bloco de baterias do TA3.

O armazenamento de energia térmica consiste em uma concha de concreto (blocos de concreto) preenchida com cascalho. São possíveis cinco tamanhos de armazenamento:

- Cobertura com blocos de concreto 5x5x5, preenchida com 27 cascalhos, capacidade de armazenamento: 22,5 kud
- Cobertura com blocos de concreto 7x7x7, preenchidos com cascalho 125, capacidade de armazenamento: 104 kud
- Cobertura com blocos de concreto 9x9x9, preenchida com 343 cascalhos, capacidade de armazenamento: 286 kud
- Cobertura com blocos de concreto 11x11x11, preenchida com 729 cascalhos, capacidade de armazenamento: 610 kud
- Cobertura com blocos de concreto 13x13x13, preenchidos com cascalho 1331, capacidade de armazenamento: 1112 kud

Uma janela feita de um bloco de vidro de obsidiana pode ser colocada na estrutura de concreto. Ela deve ser colocada bem no meio da parede. Por essa janela, é possível ver se o armazenamento está carregado em mais de 80%. Na planta à direita, você pode ver a estrutura do trocador de calor TA4, que consiste em 3 blocos, a turbina TA4 e o gerador TA4. Preste atenção ao alinhamento do trocador de calor (a seta no bloco 1 deve apontar para a turbina).

Ao contrário da planta à direita, as conexões no bloco de armazenamento devem estar no mesmo nível (dispostas horizontalmente, ou seja, não abaixo e acima). As entradas de tubulação (TA4 Pipe Inlet) devem estar exatamente no meio da parede e de frente uma para a outra. Os tubos TA4 amarelos são usados como tubos de vapor. Os tubos de vapor TA3 não podem ser usados aqui.
Tanto o gerador quanto o trocador de calor têm uma conexão de energia e devem ser conectados à rede elétrica.

Em princípio, o sistema de armazenamento de calor funciona exatamente da mesma forma que as baterias, só que com muito mais capacidade de armazenamento.

Para que o sistema de armazenamento de calor funcione, todos os blocos (também a casca de concreto e o cascalho) devem ser carregados usando um bloco forceload.

[ta4_storagesystem|plan]


### Trocador de calor TA4

O trocador de calor consiste em três partes que devem ser colocadas umas sobre as outras, com a seta do primeiro bloco apontando para a turbina. Os tubos devem ser construídos com os tubos TA4 amarelos.
O trocador de calor deve ser conectado à rede elétrica. O dispositivo de armazenamento de energia é recarregado por meio do trocador de calor, desde que haja eletricidade suficiente disponível. 

[ta4_heatexchanger|image]


### Turbina TA4

A turbina faz parte do armazenamento de energia. Ela deve ser colocada ao lado do gerador e conectada ao trocador de calor por meio de tubos TA4, conforme mostrado na planta.

[ta4_turbine|image]


### Gerador TA4

O gerador é usado para gerar eletricidade. Portanto, o gerador também deve ser conectado à rede elétrica.
O gerador faz parte do armazenamento de energia. Ele é usado para gerar eletricidade e, assim, liberar a energia da unidade de armazenamento de energia. Portanto, o gerador também deve ser conectado à rede elétrica.

Importante: Tanto o trocador de calor quanto o gerador devem estar conectados à mesma rede elétrica! 

[ta4_generator|image]


### Entrada do tubo TA4

Um bloco de entrada de tubo deve ser instalado em cada um dos dois lados do bloco de armazenamento. Os blocos devem estar exatamente de frente um para o outro.

Os blocos de entrada de tubo **não** podem ser usados como aberturas normais de parede; em vez disso, use os blocos de entrada de tubo TA3 na parede.

[ta4_pipeinlet|image]


### Tubo TA4

Com o TA4, os tubos amarelos são usados para a transmissão de gás e líquidos.
O comprimento máximo do cabo é de 100 m.

[ta4_pipe|image]



## Distribuição de energia

Com a ajuda de cabos de energia e caixas de junção, é possível configurar redes de energia de até 1.000 blocos/nós. Entretanto, deve-se observar que as caixas de distribuição também devem ser contadas. Isso significa que até 500 geradores/sistemas de armazenamento/máquinas/lâmpadas podem ser conectados a uma rede elétrica.

Com a ajuda de um transformador de isolamento e de um medidor de eletricidade, as redes podem ser conectadas para formar estruturas ainda maiores.

[ta4_transformer|image]

### Transformador de isolamento TA4

Com a ajuda de um transformador de isolamento, duas redes de energia podem ser conectadas para formar uma rede maior. O transformador de isolamento pode transmitir eletricidade em ambas as direções.

O transformador de isolamento pode transmitir até 300 ku. O valor máximo é ajustável por meio do menu da chave inglesa.

[ta4_transformer|image]

### Medidor elétrico TA4

Com a ajuda de um medidor de eletricidade, duas redes de eletricidade podem ser conectadas para formar uma rede maior. O medidor de eletricidade transmite eletricidade somente em uma direção (observe a seta). A quantidade de energia elétrica transmitida (em kud) é medida e exibida. Esse valor também pode ser consultado por um controlador Lua usando o comando `consumption`. A corrente atual pode ser consultada por meio do comando `current`.

O medidor de eletricidade pode passar até 200 ku. O valor máximo é ajustável por meio do menu da chave inglesa.

Uma contagem regressiva da potência de saída também pode ser inserida por meio do menu da chave inglesa. Quando essa contagem regressiva chega a zero, o medidor de eletricidade é desligado. A contagem regressiva pode ser consultada com o comando `countdown`.

[ta4_electricmeter|image]

### Laser TA4

O laser TA4 é usado para transmissão de energia sem fio. Para isso, são necessários dois blocos: Emissor de feixe de laser TA4 e Receptor de feixe de laser TA4. Deve haver um espaço de ar entre os dois blocos para que o feixe de laser possa ser construído a partir do emissor até o receptor. Primeiro, o emissor deve ser colocado. Isso liga imediatamente o feixe de laser e mostra as possíveis posições do receptor. As possíveis posições do receptor também são exibidas por meio de uma mensagem de bate-papo. 

Com o laser, distâncias de até 96 blocos podem ser superadas. Depois que a conexão é estabelecida (não é necessário haver fluxo de corrente), isso é indicado por meio do texto informativo do emissor e também do receptor. 

Os blocos de laser em si não requerem eletricidade.

[ta4_laser|image]



## Hidrogênio

A eletrólise pode ser usada para dividir a água em hidrogênio e oxigênio usando eletricidade. Por outro lado, o hidrogênio pode ser convertido novamente em eletricidade com o oxigênio do ar usando uma célula de combustível.
Isso permite que os picos de corrente ou um excesso de fornecimento de eletricidade sejam convertidos em hidrogênio e, portanto, armazenados.

No jogo, a eletricidade pode ser convertida em hidrogênio usando o eletrolisador e água. O hidrogênio pode então ser convertido novamente em eletricidade por meio da célula de combustível.
Isso significa que a eletricidade (na forma de hidrogênio) pode não apenas ser armazenada em tanques, mas também transportada por meio do carrinho-tanque.

No entanto, a conversão de eletricidade em hidrogênio e vice-versa é deficitária. De 100 unidades de eletricidade, apenas 95 unidades de eletricidade saem após a conversão em hidrogênio e vice-versa.

[ta4_hydrogen|image]


### Eletrolisador

O eletrolisador converte eletricidade e água em hidrogênio.
Ele deve ser alimentado pela esquerda. A água deve ser fornecida por tubos. À direita, o hidrogênio pode ser extraído por meio de tubos e bombas.

O eletrolisador pode consumir até 35 ku de eletricidade e, em seguida, gera um item de hidrogênio a cada 4 s.
200 unidades de hidrogênio cabem no eletrolisador.

O eletrolisador tem um menu de chave inglesa para definir o consumo de corrente e o ponto de desligamento.

Se a energia armazenada na rede elétrica cair abaixo do valor especificado do ponto de desligamento, o eletrolisador se desliga automaticamente. Isso evita que os sistemas de armazenamento fiquem vazios.

[ta4_electrolyzer|image]


### Célula de combustível

A célula de combustível converte hidrogênio em eletricidade.
Ele deve ser abastecido com hidrogênio pela esquerda por meio de uma bomba. A conexão de energia está à direita.

A célula de combustível pode fornecer até 34 ku de eletricidade e precisa de um item de hidrogênio a cada 4 s.

Normalmente, a célula de combustível funciona como um gerador de categoria 2 (como outros sistemas de armazenamento). 
Nesse caso, nenhum outro bloco de categoria 2, como o bloco de bateria, pode ser carregado. No entanto, a célula de combustível também pode ser usada como um gerador de categoria 1 por meio da caixa de seleção.

[ta4_fuelcell|image]


## Reator químico

O reator é usado para processar os ingredientes obtidos da torre de destilação ou de outras receitas em novos produtos.
A planta à esquerda mostra apenas uma variante possível, pois a disposição dos silos e tanques depende da receita.

O produto primário de saída é sempre descarregado na lateral do suporte do reator, independentemente de ser um pó ou um líquido. O produto residual (secundário) é sempre descarregado na parte inferior do suporte do reator.

Um reator consiste em:
- Vários tanques e silos com os ingredientes que são conectados ao dosador por meio de tubos
- opcionalmente, uma base do reator, que descarrega os resíduos do reator (necessário apenas para receitas com dois produtos de saída)
- o suporte do reator, que deve ser colocado na base (se disponível). O suporte tem uma conexão de energia e consome 8 ku durante a operação.
- O vaso do reator que deve ser colocado no suporte do reator
- O tubo de enchimento que deve ser colocado no vaso do reator
- O dispositivo de dosagem, que deve ser conectado aos tanques ou silos e ao tubo de enchimento por meio de tubos

Observação 1: Os líquidos são armazenados somente em tanques e os sólidos e substâncias em pó somente em silos. Isso se aplica a ingredientes e produtos finais.

Observação 2: Os tanques ou silos com conteúdos diferentes não devem ser conectados a um sistema de tubulação. Por outro lado, vários tanques ou silos com o mesmo conteúdo podem ser pendurados em paralelo em uma linha.

O craqueamento quebra cadeias longas de hidrocarbonetos em cadeias curtas usando um catalisador.
O pó de gibbsita serve como catalisador (não é consumido). Ele pode ser usado para converter betume em óleo combustível, óleo combustível em nafta e nafta em gasolina.

Na hidrogenação, pares de átomos de hidrogênio são adicionados a uma molécula para converter hidrocarbonetos de cadeia curta em longa.
Aqui, o pó de ferro é necessário como catalisador (não é consumido). Ele pode ser usado para converter gás (propano) em isobutano,
isobutano em gasolina, gasolina em nafta, nafta em óleo combustível e óleo combustível em betume.


[ta4_reactor|plan]


### Dosador TA4

Parte do reator químico.
As tubulações para materiais de entrada podem ser conectadas em todos os quatro lados do dosador. Os materiais para o reator são descarregados para cima.

A receita pode ser definida e o reator pode ser iniciado por meio do dosador.

Como em outras máquinas:
- se o dosador estiver no modo de espera, um ou mais ingredientes estão faltando
- se o dosador estiver no estado bloqueado, o tanque ou silo de saída está cheio, com defeito ou conectado incorretamente

O dosador não precisa de eletricidade. Uma receita é processada a cada 10 s.

[ta4_doser|image]

### Reator TA4

Parte do reator químico. O reator tem um inventário para os itens de catalisador (para receitas de craqueamento e hidrogenação).

[ta4_reactor|image]


### Tubo de enchimento TA4

Parte do reator químico. Deve ser colocado no reator. Se isso não funcionar, remova o tubo na posição acima e coloque-o novamente.

[ta4_fillerpipe|image]


### Suporte do reator TA4

Parte do reator químico. Aqui também está a conexão de energia para o reator. O reator requer 8 ku de eletricidade.

O suporte tem duas conexões de tubulação, à direita para o produto inicial e abaixo para os resíduos, como a lama vermelha na produção de alumínio.

[ta4_reactorstand|image]


### Base do reator TA4

Parte do reator químico. É necessário para a drenagem do produto residual.

[ta4_reactorbase|image]


### Silo TA4

Parte do reator químico. É necessário para armazenar substâncias em forma de pó ou grânulos.

[ta4_silo|image]




## Controlador ICTA

O controlador ICTA (ICTA significa "If Condition Then Action") é usado para monitorar e controlar máquinas. O controlador pode ser usado para ler dados de máquinas e outros blocos e, dependendo disso, ligar/desligar outras máquinas e blocos.

Os dados da máquina são lidos e os blocos e máquinas são controlados por meio de comandos. O capítulo TA3 -> Blocos lógicos/comutação é importante para entender como os comandos funcionam.

O controlador requer uma bateria para funcionar. O visor é usado para emitir dados, a torre de sinalização para exibir erros.

[ta4_icta_controller|image]



### Controlador TA4 ICTA

O controlador funciona com base nas regras `IF <condição> THEN <ação>`. Podem ser criadas até 8 regras por controlador.

Exemplos de regras são:

- Se um distribuidor estiver "bloqueado", o empurrador na frente dele deve ser desligado
- Se uma máquina apresentar um erro, isso deverá ser mostrado no visor

O controlador verifica essas regras ciclicamente. Para fazer isso, um tempo de ciclo em segundos (`` Cycle / s '') deve ser especificado para cada regra (1...1000).

Para regras que avaliam uma entrada ligada/desligada, por exemplo, de um interruptor ou detector, o tempo de ciclo 0 deve ser especificado. O valor 0 significa que essa regra deve ser sempre executada quando o sinal de entrada for alterado, por exemplo, quando o botão enviar um novo valor.

Todas as regras devem ser executadas apenas com a frequência necessária. Isso tem duas vantagens:

- a bateria do controlador dura mais (cada controlador precisa de uma bateria)
- a carga do servidor é menor (portanto, menos atrasos)

Você deve definir um tempo de atraso (`depois/s`) para cada ação. Se a ação tiver que ser executada imediatamente, deve-se inserir 0.

O controlador tem sua própria ajuda e informações sobre todos os comandos por meio do menu do controlador.

[ta4_icta_controller|image]

### Bateria

A bateria deve ser colocada bem próxima ao controlador, ou seja, em uma das 26 posições ao redor do controlador.

[ta4_battery|image]

### Exibição do TA4

O display mostra seu número após a colocação. O display pode ser endereçado por meio desse número. Os textos podem ser exibidos no visor, sendo que o visor pode exibir 5 linhas e, portanto, 5 textos diferentes.

As linhas de texto são sempre alinhadas à esquerda. Se o texto tiver que ser centralizado horizontalmente, deverá ser precedido pelo caractere "\t" (tabulador).

O visor é atualizado no máximo uma vez por segundo.

[ta4_display|image]

### TA4 Display XL

O TA4 Display XL tem o dobro do tamanho do display TA4.

As linhas de texto são sempre alinhadas à esquerda. Se o texto tiver que ser centralizado horizontalmente, deverá ser precedido pelo caractere "\t" (tabulador).

O visor é atualizado a cada dois segundos, no máximo.

[ta4_displayXL|image]


### Torre de sinalização TA4

A torre de sinalização pode exibir vermelho, verde e laranja. Não é possível uma combinação das três cores.

[ta4_signaltower|image]



## Controlador TA4 Lua

Como o nome sugere, o controlador Lua deve ser programado na linguagem de programação Lua. O manual em inglês está disponível aqui:

https://github.com/joe7575/techage/blob/master/manuals/ta4_lua_controller_EN.md

O controlador Lua também requer uma bateria. A bateria deve ser colocada bem próxima ao controlador, ou seja, em uma das 26 posições ao redor do controlador.

[ta4_lua_controller|image]

### Servidor TA4 Lua

O servidor é usado para o armazenamento central de dados de vários controladores Lua. Ele também salva os dados após a reinicialização do servidor.

[ta4_lua_server|image]

### Caixa do sensor TA4 / baú

A caixa de sensores TA4 é usada para configurar armazéns automáticos ou máquinas de venda automática em conjunto com o controlador Lua.
Se algo for colocado na caixa ou removido, ou se uma das teclas "F1"/"F2" for pressionada, um sinal de evento será enviado ao controlador Lua.
A caixa do sensor suporta os seguintes comandos:

- O status da caixa pode ser consultado por meio de `state = $send_cmnd(<num>, "state")`. As respostas possíveis são: "empty" (vazio), "loaded" (carregado), "full" (cheio)
- A última ação do jogador pode ser consultada por meio de `name, action = $send_cmnd(<num>, "action")`. `name` é o nome do jogador. Uma das seguintes opções é retornada como `action`: "put", "take", "f1", "f2".
- O conteúdo da caixa pode ser lido por meio de `stacks = $send_cmnd(<num>, "stacks")`. Consulte: https://github.com/joe7575/techage/blob/master/manuals/ta4_lua_controller_EN.md#sensor-chest
- Por meio de `$send_cmnd(<num>, "text", "pressione ambos os botões e coloque algo no peito")`, o texto pode ser definido no menu da caixa do sensor.

A caixa de seleção "Allow public chest access" (Permitir acesso público ao baú) pode ser usada para definir se a caixa pode ser usada por todos ou somente por jogadores que tenham direitos de acesso/proteção aqui.

[ta4_sensor_chest|image]

### Terminal do controlador TA4 Lua

O terminal é usado para entrada/saída do controlador Lua.

[ta4_terminal|image]



## Módulos de lógica/comutação TA4

### Botão/interruptor TA4

Apenas a aparência do botão/chave TA4 foi alterada. A funcionalidade é a mesma do botão/chave TA3. No entanto, com o menu da chave inglesa, os dados podem ser alterados posteriormente.

[ta4_button|image]

### Botão TA4 2x

Esse bloco tem dois botões que podem ser configurados individualmente por meio do menu de chave inglesa. A rotulagem e o endereço do bloco de destino podem ser configurados para cada botão. Além disso, o comando a ser enviado pode ser configurado para cada botão. 

[ta4_button_2x|image]


### Botão TA4 4x

Esse bloco tem quatro botões que podem ser configurados individualmente por meio do menu de chave inglesa. A rotulagem e o endereço do bloco de destino podem ser configurados para cada botão. Além disso, o comando a ser enviado pode ser configurado para cada botão. 

[ta4_button_4x|image]

### Lâmpada de sinalização TA4 2x

Esse bloco tem duas lâmpadas que podem ser controladas individualmente. Cada lâmpada pode exibir as cores "vermelho", "verde" e "âmbar". A rotulagem de ambas as lâmpadas pode ser configurada por meio do menu de chave inglesa. As lâmpadas podem ser controladas usando os seguintes comandos:

- Mudar a lâmpada 1 para vermelho: `$send_cmnd(1234, "red", 1)`
- Mude a lâmpada 2 para verde: `$send_cmnd(1234, "green ", 2)`
- Mudar a lâmpada 1 para laranja: `$send_cmnd(1234, "amber", 1)`
- Desligar a lâmpada 2: `$send_cmnd(1234, "off", 2)`

[ta4_signallamp_2x|image]

### Lâmpada de sinalização TA4 4x

Esse bloco tem quatro lâmpadas que podem ser controladas individualmente. Cada lâmpada pode exibir as cores "vermelho", "verde" e "âmbar". A rotulagem de todas as lâmpadas pode ser configurada por meio do menu de chave inglesa. As lâmpadas podem ser controladas usando os seguintes comandos:

- Mudar a lâmpada 1 para vermelho: `$send_cmnd(1234, "red", 1)`
- Mude a lâmpada 2 para verde: `$send_cmnd(1234, "green ", 2)`
- Mudar a lâmpada 3 para laranja: `$send_cmnd(1234, "amber", 3)`
- Desligar a lâmpada 4: `$send_cmnd(1234, "off", 4)`

[ta4_signallamp_4x|image]

### Detector de jogadores TA4

Apenas a aparência do detector de player TA4 foi alterada. A funcionalidade é a mesma do detector de player TA3.

[ta4_playerdetector|image]

### Coletor de estado TA4

[ta4_collector|image]

O coletor de status consulta todas as máquinas configuradas para obter o status. Se uma das máquinas tiver atingido ou excedido um status pré-configurado, um comando "on" será enviado. Por exemplo, muitas máquinas podem ser facilmente monitoradas quanto a falhas a partir de um controlador Lua.

### Detector TA4

A funcionalidade é a mesma do detector TA3. Além disso, o detector conta os itens passados adiante.
Esse contador pode ser consultado com o comando "count" e redefinido com "reset".

[ta4_detector|image]

### Detector de nó TA4

A funcionalidade é a mesma do TA3 Node Detector.

Ao contrário do detector de nós TA3, as posições a serem monitoradas podem ser configuradas individualmente aqui. Para fazer isso, o botão "Record" (Registrar) deve ser pressionado. Em seguida, todos os blocos devem ser clicados, cuja posição deve ser verificada. Em seguida, o botão "Done" (Concluído) deve ser pressionado.

Podem ser selecionados até 4 blocos.

[ta4_nodedetector|image]

### Detector de carga de armazenamento de energia TA4

O detector de carga mede o estado de carga do armazenamento de energia da rede elétrica a cada 8 s.

Se o valor ficar abaixo de um limite configurável (ponto de comutação), um comando (padrão: "off") será enviado. Se o valor subir novamente acima desse ponto de comutação, um segundo comando (padrão: "on") será enviado. Isso permite que os consumidores sejam desconectados da rede quando o nível de carga do dispositivo de armazenamento de energia cair abaixo do ponto de comutação especificado.

Para fazer isso, o detector de carga deve ser conectado à rede por meio de uma caixa de junção. O detector de carga é configurado por meio do menu da chave de boca.

[ta4_chargedetector|image]

### Sensor de olhar TA4

O sensor de olhar TA4 gera um comando quando o bloco é visto/focado pelo proprietário ou por outros jogadores configurados e envia um segundo comando quando o bloco não é mais focalizado. Assim, ele substitui os botões/interruptores, por exemplo, para abrir/fechar portas.

O TA4 Gaze Sensor só pode ser programado usando o menu da chave de boca. Se você tiver uma chave de boca na mão, o sensor não será acionado, mesmo que esteja focalizado.

[ta4_gaze_sensor|image]

### Sequenciador TA4

Processos inteiros podem ser programados usando o sequenciador TA4. Veja um exemplo:

```
-- este é um comentário
[1] send 1234 a2b
[30] send 1234 b2a
[60] goto 1
```

- Cada linha começa com um número que corresponde a um ponto no tempo `[<num>]`
- São permitidos valores de 1 a 50000 para os tempos
- 1 corresponde a 100 ms, 50000 corresponde a cerca de 4 dias de jogo
- Linhas vazias ou comentários são permitidos (`-- comment`)
- Com `send <num> <command> <data>`, você pode enviar um comando para um bloco
- Com `goto <num>` você pode pular para outra linha/ponto no tempo
- Com `stop` você pode parar o sequenciador com um atraso para que ele não receba um novo comando
  aceita de um botão ou outro bloco (para concluir um movimento)
  Sem `stop`, o sequenciador entra no modo parado imediatamente após o último comando.

O sequenciador TA4 suporta os seguintes comandos de tecnologia:

- `goto <num>` Salta para uma linha de comando e inicia o sequenciador
- `stop` Parar o sequenciador
- `on` e `off` como aliases para `goto 1` e `stop`

O comando `goto` só é aceito quando o sequenciador está parado.

O tempo de ciclo (padrão: 100 ms) pode ser alterado para o sequenciador por meio do menu da chave de boca.

[ta4_sequencer|image]



## Controlador de movimento/volta

### Controlador de movimento TA4

O TA4 Move Controller é semelhante ao "Door Controller 2", mas os blocos selecionados não são removidos, mas podem ser movidos.
Como os blocos móveis podem levar consigo os jogadores e as multidões que estão no bloco, é possível construir elevadores e sistemas de transporte semelhantes com eles.

Instruções:

- Defina o controlador e treine os blocos a serem movidos por meio do menu (até 16 blocos podem ser treinados)
- A "rota de voo" deve ser inserida por meio de uma especificação x, y, z (relativa) (a distância máxima (x+y+z) é de 200 m)
- O movimento pode ser testado com os botões de menu "Move A-B" e "Move B-A"
- Você também pode voar através de paredes ou outros blocos
- A posição de destino dos blocos também pode ser ocupada. Nesse caso, os blocos são salvos de forma "invisível". Isso se destina a portas deslizantes e similares

O Move Controller é compatível com os seguintes comandos de tecnologia:

- `a2b` Mover o bloco de A para B.
- `b2a` Mover o bloco de B para A.
- `move` Mover o bloco para o outro lado

Você pode alternar para o modo de operação `move xyz` por meio do menu de chave inglesa. Após a mudança, os seguintes comandos técnicos são suportados: 

- `move2` Com o comando, a rota de voo também deve ser especificada como um vetor x,y,z.
  Exemplo de controlador Lua: `$send_cmnd(MOVE_CTLR, "move2", "0,12,0")` 
- `reset` move o(s) bloco(s) de volta à posição inicial

**Instruções importantes:**

- Se vários blocos tiverem de ser movidos, o bloco que levará os jogadores/mobs deverá ser clicado primeiro durante o treinamento.
- Se o bloco que deve levar os jogadores/móbile tiver uma altura reduzida, a altura deverá ser definida no controlador usando o menu de chave de boca aberto (por exemplo, altura = 0,5). Caso contrário, o jogador/móbile não será "encontrado" e não será levado embora.

[ta4_movecontroller|image]

### Controlador de giro TA4

O controlador de giro do TA4 é semelhante ao "Move Controller", mas os blocos selecionados não são movidos, mas girados em torno de seu centro para a direita ou para a esquerda.

Instruções:

- Defina o controlador e treine os blocos a serem movidos por meio do menu (até 16 blocos podem ser treinados)
- O movimento pode ser testado com os botões de menu "Turn left" (Virar à esquerda) e "Turn right" (Virar à direita)

O controlador de giro suporta os seguintes comandos de tecnologia:

- `left` Vire à esquerda
- `direita` Vire à direita
- `uturn` Girar 180 graus 

[ta4_turncontroller|image]




## Lâmpadas TA4

O TA4 contém uma série de lâmpadas potentes que permitem uma melhor iluminação ou a realização de tarefas especiais.

### Luz de cultivo LED TA4

A lâmpada de cultivo TA4 LED permite o crescimento rápido e vigoroso de todas as plantas do modo `farming`. A lâmpada ilumina um campo de 3x3, de modo que as plantas também podem ser cultivadas no subsolo.
A lâmpada deve ser colocada um bloco acima do solo no meio do campo 3x3.

A lâmpada também pode ser usada para cultivar flores. Se a lâmpada for colocada sobre um canteiro de flores 3x3 feito de "Garden Soil" (Mod `compost`), as flores crescerão automaticamente (acima e abaixo do solo).

Você pode colher as flores com o Signs Bot, que também tem uma placa correspondente que deve ser colocada na frente do campo de flores.

A lâmpada requer 1 ku de eletricidade.

[ta4_growlight|image]

### Lâmpada de rua TA4

A lâmpada de rua de LED TA4 é uma lâmpada com iluminação particularmente forte. A lâmpada consiste no compartimento da lâmpada, no braço da lâmpada e nos blocos do poste da lâmpada.

A corrente deve ser conduzida de baixo para cima, através do mastro, até o compartimento da lâmpada. Primeiro, puxe o cabo de alimentação para cima e, em seguida, "engesse" o cabo de alimentação com blocos de postes de iluminação.

A lâmpada requer 1 ku de eletricidade.

[ta4_streetlamp|image]

### Lâmpada industrial de LED TA4

A lâmpada industrial de LED TA4 é uma lâmpada com iluminação particularmente forte. A lâmpada deve ser alimentada por cima.

A lâmpada requer 1 ku de eletricidade.

[ta4_industriallamp|image]




## Filtro líquido TA4

O filtro de líquidos filtra a lama vermelha.
Uma parte da lama vermelha se transforma em soda cáustica, que pode ser coletada no fundo de um tanque.
A outra parte se transforma em um paralelepípedo do deserto e obstrui o material do filtro.
Se o filtro estiver muito entupido, ele deverá ser limpo e enchido novamente.
O filtro consiste em uma camada de base, 7 camadas de filtro idênticas e uma camada de enchimento na parte superior.

[ta4_liquid_filter|image]

### Camada de base

Você pode ver a estrutura dessa camada no plano.

A soda cáustica é coletada no tanque.

[ta4_liquid_filter_base|plan]

### Camada de cascalho

Essa camada deve ser preenchida com cascalho, conforme mostrado no plano.
No total, deve haver sete camadas de cascalho.
O filtro ficará obstruído com o tempo, de modo que precisará ser limpo e preenchido novamente.

[ta4_liquid_filter_gravel|plan]

### Camada de enchimento

Essa camada é usada para preencher o filtro com lama vermelha.
A lama vermelha deve ser bombeada para o tubo de enchimento.

[ta4_liquid_filter_top|plan]




## Colisor TA4 (acelerador de partículas)

O Collider é uma instalação de pesquisa que realiza pesquisas básicas. É possível coletar pontos de experiência aqui, que são necessários para o TA5 (Future Age).

Como seu original no CERN em Genebra, o colisor deve ser construído no subsolo. A configuração padrão aqui é Y <= -28. O valor pode, no entanto, ser alterado pela equipe do servidor por meio da configuração. Pergunte ou tente o bloco "TA4 Collider Detector Worker".

Somente um colisor pode ser operado por jogador. Portanto, não faz sentido configurar dois ou mais colisores. Os pontos de experiência são creditados ao jogador que possui o colisor. Os pontos de experiência não podem ser transferidos.

Um colisor consiste em um "anel" feito de tubos e ímãs, além de um detector com um sistema de resfriamento.

- O detector é o coração do sistema. É nele que os experimentos científicos são realizados. O detector tem o tamanho de 3x3x7 blocos.
- 22 ímãs do colisor TA4 (não os ímãs do detector do colisor TA4!) devem ser conectados uns aos outros por meio de 5 blocos do tubo de vácuo TA4. Cada ímã também requer eletricidade e uma conexão de gás para resfriamento. O conjunto forma (como mostrado na planta à direita) um quadrado com um comprimento de borda de 37 metros.

A planta mostra a instalação vista de cima:

- O bloco cinza é o detector com o bloco de trabalho no meio
- Os blocos vermelhos são os ímãs, os azuis são os tubos de vácuo

[techage_collider_plan|plan]

### Detector

O detector é configurado automaticamente com a ajuda do bloco "TA4 Collider Detector Worker" (semelhante à torre). Todos os materiais necessários para isso devem ser colocados primeiro no bloco do trabalhador. O detector é mostrado simbolicamente no bloco do trabalhador. O detector é montado no bloco de trabalho.

O detector também pode ser desmontado novamente com a ajuda do bloco de trabalho.

As conexões para eletricidade, gás e tubos de vácuo estão localizadas nos dois lados frontais do detector. Uma bomba TA4 deve ser conectada na parte superior para sugar o tubo vazio/criar o vácuo.

O sistema de resfriamento deve ser conectado à parte traseira do detector. O sistema de resfriamento é mostrado na planta à direita. Além do trocador de calor TA4 da unidade de armazenamento de energia (que é usado aqui para resfriamento), também é necessário um bloco resfriador TA4.

Observação: A seta no trocador de calor deve apontar para longe do detector. O trocador de calor também deve ser alimentado com eletricidade.

[ta4_cooler|plan]


- Além disso, é necessário resfriamento, que também deve ser instalado no detector. O isobutano é necessário para o resfriamento.
- O sistema requer uma quantidade considerável de eletricidade. Portanto, faz sentido ter sua própria fonte de alimentação.

### Controle / Terminal TA4

O colisor é controlado por meio de um terminal TA4 (não por meio do terminal do controlador TA4 Lua).

Esse terminal deve ser conectado ao detector. O número do detector é exibido como texto informativo no bloco de trabalho.

O terminal suporta os seguintes comandos:

- `connect <número>` (conectar-se ao detector)
- `start` (iniciar o detector)
- `stop` (parar o detector)
- `test <número>` (verificação de um ímã)
- `points` (consulta dos pontos de experiência já obtidos)

Se ocorrer um erro em um ímã durante o `start`, o número do ímã será exibido. O comando `test` pode ser usado para solicitar mais informações sobre o erro do ímã.

[ta4_terminal|image]

### Resfriamento e energia

Cada ímã do Colisor TA4 também deve ser abastecido com eletricidade (conforme mostrado à direita na planta) e com isobutano para resfriamento:

- A conexão para a alimentação está na parte superior do ímã.
- A conexão para o resfriamento está na parte frontal do ímã.
- Uma bomba TA4 e um tanque TA4 com pelo menos 250 unidades de isobutano também são necessários para resfriar todo o sistema.
- O sistema também requer muita eletricidade. Portanto, faz sentido ter sua própria fonte de alimentação com pelo menos 145 ku.

[techage_collider_plan2|plan]

### Construção

A sequência a seguir é recomendada ao configurar o colisor:

- Coloque um bloco de carga forçada. Somente o detector com o sistema de resfriamento deve estar na área do bloco de carga forçada.
- Defina o bloco de trabalho, preencha-o com itens e configure o detector por meio do menu
- Construa o anel com tubos e ímãs
- Conecte todos os ímãs e o detector com os cabos de alimentação
- Conecte todos os ímãs e o detector com os tubos amarelos e bombeie o isobutano no sistema de tubos com uma bomba
- Instale uma bomba TA4 como uma bomba de vácuo no detector e ligue-a (não é necessário nenhum tanque adicional). Se a bomba entrar em "standby", o vácuo será estabelecido. Isso levará alguns segundos
- Monte o resfriador (trocador de calor) e conecte-o ao cabo de alimentação
- Coloque o terminal TA4 na frente do detector e conecte-o ao detector por meio de `connect <number>`
- Ligar/conectar a fonte de alimentação
- ligar o resfriador (trocador de calor)
- Ligue o detector por meio de `start` no terminal TA4. Após algumas etapas de teste, o detector entra em operação normal ou emite um erro.
- O colisor precisa ser executado continuamente e, em seguida, fornece gradualmente pontos de experiência. Para obter 10 pontos, o colisor precisa funcionar por algumas horas

[techage_ta4c|image]




## Mais blocos TA4

### Bloco de receitas TA4

Até 10 receitas podem ser salvas no bloco de receitas. Essas receitas podem então ser chamadas por meio de um comando do TA4 Autocrafter. Isso permite que a receita do autocrafter seja configurada por meio de um comando. As receitas no bloco de receitas também podem ser consultadas diretamente por meio de um comando.

`input <index>` lê uma receita do bloco de receitas do TA4. `<index>` é o número da receita. O bloco retorna uma lista de ingredientes da receita.

Exemplo: `$send_cmnd(1234, "input", 1)`

[ta4_recipeblock|image] 

### TA4 Autocrafter

A função corresponde à do TA3.

A capacidade de processamento é de 4 itens a cada 4 s. O autocrafter requer 9 ku de eletricidade para isso.

Além disso, o TA4 Autocrafter suporta a seleção de diferentes receitas usando os seguintes comandos:

`recipe "<number>.<index>"` muda o autocrafter para uma receita do bloco de receitas TA4. `<number>` é o número do bloco de receitas, `<index>` é o número da receita. Exemplo: `$send_cmnd(1234, "recipe", "5467.1")`

Como alternativa, uma receita também pode ser selecionada por meio da lista de ingredientes, por exemplo:
`$send_cmnd(1234, "recipe", "default:coal_lump,,,default:stick")`
Todos os nomes técnicos de uma receita devem ser especificados aqui, separados por vírgulas. Consulte também o comando `input` no bloco de receitas do TA4.

O comando `flush` move todos os itens do inventário de entrada para o inventário de saída. O comando retorna `true` se o inventário de entrada tiver sido completamente esvaziado. Se `false` for retornado (inventário de saída cheio), o comando deverá ser repetido em um momento posterior.

[ta4_autocrafter|image] 

### Tanque TA4

Consulte o tanque TA3.

Um tanque TA4 pode conter 2.000 unidades ou 200 barris de líquido.

[ta4_tank|image]

### Bomba TA4

Consulte a bomba TA3.

A bomba TA4 bombeia 8 unidades de líquido a cada dois segundos. 

No modo "Flow limiter" (Limitador de fluxo), o número de unidades bombeadas pela bomba pode ser limitado. O modo de limitador de fluxo pode ser ativado por meio do menu da chave de boca, configurando o número de unidades no menu. Quando o número configurado de unidades tiver sido bombeado, a bomba será desligada. Quando a bomba for ligada novamente, ela bombeará o número configurado de unidades novamente e, em seguida, será desligada.

O limitador de fluxo também pode ser configurado e iniciado usando um controlador Lua ou Beduino.

A bomba também é compatível com o comando `flowrate`. Isso permite que a taxa de fluxo total através da bomba seja consultada.

[ta4_pump|image]

### Aquecedor de forno TA4

Com o TA4, o forno industrial também tem seu aquecimento elétrico. O queimador de óleo e o soprador podem ser substituídos pelo aquecedor.

O aquecedor requer 14 ku de eletricidade.

[ta4_furnaceheater|image]

### Bomba d'água TA4 (obsoleta)

Esse bloco não poderá mais ser fabricado e será substituído pelo bloco de entrada de água TA4. 

### Entrada de água TA4

Algumas receitas requerem água. A água deve ser bombeada do mar com uma bomba (água em y = 1). Uma "piscina" composta de alguns blocos de água não é suficiente para isso! 

Para fazer isso, o bloco de entrada de água deve ser colocado na água e conectado à bomba por meio de tubos. Se o bloco for colocado na água, é preciso garantir que haja água sob o bloco (a água deve ter pelo menos 2 blocos de profundidade). 

[ta4_waterinlet|image]

### Tubo TA4

O TA4 também tem seus próprios tubos no design do TA4. Eles podem ser usados como os tubos padrão.
Mas: Os empurradores e distribuidores TA4 só atingem seu desempenho total quando usados com tubos TA4.

[ta4_tube|image]

### TA4 Pusher

A função corresponde basicamente à do TA2 / TA3. Além disso, um menu pode ser usado para configurar quais objetos devem ser retirados de um baú TA4 e transportados posteriormente.
A capacidade de processamento é de 12 itens a cada 2 s, se forem usados tubos TA4 em ambos os lados. Caso contrário, haverá apenas 6 itens a cada 2 s.

No modo "limitador de fluxo", o número de itens que são movidos pelo empurrador pode ser limitado. O modo limitador de fluxo pode ser ativado por meio do menu da chave de boca, configurando o número de itens no menu. Assim que o número configurado de itens tiver sido movido, o empurrador se desliga. Se o empurrador for ligado novamente, ele moverá o número configurado de itens novamente e depois se desligará.

O empurrador TA4 também pode ser configurado e iniciado usando um controlador Lua ou Beduino.

Aqui estão os comandos adicionais para o controlador Lua:

- O `config` é usado para configurar o empurrador, de forma análoga à configuração manual por meio do menu.
   Exemplo: `$send_cmnd(1234, "config", "default:dirt")`
   Com `$send_cmnd(1234, "config", "")`, a configuração é excluída
- `limit` é usado para definir o número de itens para o modo de limitador de fluxo:
   Exemplo: `$send_cmnd(1234, "init", 7)`

[ta4_pusher|image]

### Peito TA4

A função corresponde à do TA3. O baú pode conter mais conteúdo.

Além disso, o baú do TA4 tem um shadow inventory para configuração. Aqui, determinados locais de pilha podem ser pré-atribuídos a um item. As pilhas de inventário pré-atribuídas só são preenchidas com esses itens durante o preenchimento. É necessário um empurrador ou injetor TA4 com a configuração apropriada para esvaziar as pilhas de inventário pré-atribuídas.

[ta4_chest|image]

### Baú TA4 8x2000

O baú TA4 8x2000 não tem um inventário normal como os outros baús, mas tem 8 lojas, sendo que cada loja pode armazenar até 2.000 itens de um tipo. Os botões laranja podem ser usados para mover itens de ou para a loja. A caixa também pode ser preenchida ou esvaziada com um empurrador (TA2, TA3 ou TA4) como de costume.

Se o baú for preenchido com um empurrador, todos os depósitos serão preenchidos da esquerda para a direita. Se todos os 8 depósitos estiverem cheios e nenhum outro item puder ser adicionado, os itens adicionais serão rejeitados.

**Função de linha**

Vários baús TA4 8x2000 podem ser conectados a um baú grande com mais conteúdo. Para fazer isso, os baús devem ser colocados em uma fileira, um após o outro.

Primeiro, o baú da frente deve ser colocado e, em seguida, os baús empilhados são colocados atrás com a mesma direção de visão (todas as caixas têm a frente voltada para o jogador). Com 2 baús em uma fileira, o tamanho aumenta para 8x4000, etc.

As fileiras de baús não podem mais ser removidas. Há duas maneiras de desmontar os baús:

- Esvazie e remova o baú da frente. Isso desbloqueia o próximo baú e pode ser removido.
- Esvazie o baú da frente até o ponto em que todas as lojas contenham no máximo 2.000 itens. Isso desbloqueia o próximo baú e pode ser removido.

Os baús têm uma caixa de seleção de "pedido". Se essa caixa de seleção for ativada, os depósitos não serão mais completamente esvaziados por um empurrador. O último item permanece no depósito como padrão. Isso resulta em uma atribuição fixa de itens aos locais de armazenamento.

O baú só pode ser usado por jogadores que podem construir nesse local, ou seja, que têm direitos de proteção. Não importa quem coloca o baú.

O baú tem um comando adicional para o controlador Lua:

- `count` é usado para solicitar quantos itens estão no baú.
  Exemplo 1: `$send_cmnd(CHEST, "count")` -> Soma dos itens em todas as 8 lojas
  Exemplo 2: `$send_cmnd(CHEST, "count", 2)` -> número de itens na loja 2 (segunda a partir da esquerda)
- `storesize` é usado para ler o tamanho de um dos oito armazenamentos:
  Exemplo: `$send_cmnd(CHEST, "storesize")` -> a função retorna, por exemplo, 6000

[ta4_8x2000_chest|image]



### Distribuidor TA4

A função corresponde à do TA2.
A capacidade de processamento é de 24 itens a cada 4 s, desde que os tubos TA4 sejam usados em todos os lados. Caso contrário, haverá apenas 12 itens a cada 4 s.

[ta4_distributor|image]

### Distribuidor de alto desempenho TA4

A função corresponde à do distribuidor TA4 normal, com duas diferenças:
A capacidade de processamento é de 36 itens a cada 4 s, desde que os tubos TA4 sejam usados em todos os lados. Caso contrário, haverá apenas 18 itens a cada 4 s.
Além disso, até 8 itens podem ser configurados por direção.

[ta4_high_performance_distributor|image]

### Peneira de cascalho TA4

A função corresponde à do TA2.
A capacidade de processamento é de 4 itens a cada 4 s. O bloco requer 5 ku de eletricidade.

[ta4_gravelsieve|image]

### Moedor TA4

A função corresponde à do TA2.
A capacidade de processamento é de 4 itens a cada 4 s. O bloco requer 9 ku de eletricidade.

[ta4_grinder|image]

### Pedreira TA4

A função corresponde em grande parte à do TA2.

Além disso, o tamanho do furo pode ser definido entre blocos de 3x3 e 11x11.
A profundidade máxima é de 80 metros. A pedreira requer 14 ku de eletricidade.

[ta4_quarry|image]

### Fab. eletrônica TA4

A função corresponde à do TA2, apenas chips diferentes são produzidos aqui.
A capacidade de processamento é de um chip a cada 6 s. O bloco requer 12 ku de eletricidade para isso.

[ta4_electronicfab|image]

### Injetor TA4

A função corresponde à do TA3.

O poder de processamento é de até 8 vezes quatro itens a cada 4 segundos.

[ta4_injector|image]

### Reciclador TA4

O reciclador é uma máquina que processa todas as receitas de Techage de trás para frente, ou seja, pode desmontar máquinas e blocos e transformá-los em seus componentes. 

A máquina pode desmontar praticamente todos os blocos da Techage e do Hyperloop. Mas nem todos os itens/materiais da receita podem ser reciclados:

- A madeira se transforma em gravetos
- A pedra se transforma em areia ou cascalho
- Os semicondutores/chips não podem ser reciclados 
- As ferramentas não podem ser recicladas

A capacidade de processamento é de um item a cada 8 s. O bloco requer 16 ku de eletricidade para isso.

[ta4_recycler|image] 