# TA1: Idade do Ferro
TA1 trata da extração de minérios suficientes e da produção de carvão com ferramentas e equipamentos simples, para que as máquinas TA2 possam ser fabricadas e operadas.

É claro que, para uma Idade do Ferro, deve haver ferro e não apenas aço, como em "Minetest Game". Como resultado, algumas receitas foram alteradas para que o ferro precise ser produzido primeiro e, posteriormente, o aço.

A durabilidade das ferramentas é baseada nas eras e, portanto, não corresponde ao jogo original do Minetest.
A durabilidade/dureza de um machado, por exemplo:

* Bronze: 20
* Aço: 30

[techage_ta1|image]

## Pilha de Carvão (queimador de carvão)
Você precisa da Pilha de Carvão para fazer carvão. O carvão é necessário para a fundição, mas também, por exemplo, em TA2 para a máquina a vapor.

Para o queimador de carvão, você precisa de:

* Um bloco de acendedor (`techage:lighter`)
* 26 blocos de madeira empilhados para formar um monte de madeira. O tipo de madeira é irrelevante.
* Terra para cobrir o monte de madeira
* Pedra lascada e Ferro (nome técnico: `fire:flint_and_steel`) para acender o bloco de acendedor

Instruções de construção (veja também o plano):

* Construa uma área de 5x5 de terra
* Coloque 7 blocos de madeira ao redor do acendedor, mas deixe um buraco para o acendedor
* Construa mais 2 camadas de madeira em cima, formando um cubo de madeira 3x3x3
* Cubra tudo com uma camada de terra formando um cubo de 5x5x5, mas mantenha o buraco para o acendedor aberto
* Acenda utilizando o isqueiro e feche imediatamente o buraco com um bloco de madeira e terra
* Se você fez tudo corretamente, o queimador de carvão começará a soltar fumaça após alguns segundos
* Só abra o queimador de carvão quando a fumaça tiver desaparecido (aproximadamente 20 minutos)
* Então você pode remover os 9 blocos de carvão e reabastecer a Pilha de Carvão.

[coalpile|plan]

## Forno de Fundição
Você precisa do forno de fundição, por exemplo, para fundir ferro e outros minérios no Vaso de fundição(cadinho). Existem receitas diferentes que requerem diferentes temperaturas. Quanto mais alto a torre de fusão, mais quente é a chama. Uma altura de 11 blocos acima da placa base é para todas as receitas, mas um queimador com essa altura também requer mais carvão.

Instruções de construção (veja também o plano):

* Construa uma torre de pedregulho (cobble) com uma base de 3x3 (7-11 blocos de altura)
* Deixe um buraco aberto de um lado na parte inferior
* Coloque um acendedor nele
* Encha a torre até a borda com carvão despejando o carvão no buraco de cima para baixo
* Acenda o acendedor através do buraco
* Coloque o Vaso de fundição(cadinho) no topo da torre diretamente na chama, um bloco acima da borda da torre
* Para parar o queimador, feche temporariamente o buraco com um bloco de terra, por exemplo.
* O Vaso de fundição(cadinho) tem seu próprio menu de receitas e um inventário onde você precisa colocar os minérios.

[coalburner|plan]

## Moinho d'Água
O moinho d'água pode ser usado para moer trigo e outros grãos para fazer farinha e depois assá-los no forno para fazer pão.
O moinho é alimentado por energia hidráulica. Para isso, um curso de água deve ser conduzido até a roda do moinho através de um canal.
O fluxo de água e, portanto, a roda do moinho, podem ser controlados por meio de uma comporta. A comporta é composta pelo bloqueio de comporta e pela alavanca de comporta.

A imagem à direita (clique em "Plano") mostra a estrutura do moinho d'água.

[watermill1|plan]

### Moinho d'Água TA1
O moinho d'água pode ser usado para moer trigo e outros grãos para fazer farinha e depois assá-los no forno para fazer pão. O moinho deve ser conectado à roda do moinho com um eixo TA1. A potência da roda do moinho é apenas suficiente para um moinho.

O moinho pode ser automatizado com a ajuda de um Funil(Minecart Hopper), para que a farinha, por exemplo, seja transportada diretamente do moinho para um forno para assar pão.

[watermill2|plan]

### Comporta TA1
A válvula de comporta deve ser colocada diretamente ao lado de um lago ou em um riacho na mesma altura que a superfície da água.
Quando a comporta é aberta, a água flui através do canal. Essa água deve ser conduzida até a roda do moinho, onde movimenta o moinho.

[ta1_sluice|image]

### Alavanca de Comporta TA1
A alavanca de comporta TA1 deve ser colocada na comporta. A comporta pode ser aberta com a ajuda da alavanca de comporta (clique com o botão direito).

[ta1_sluice_handle|image]

### Placa de Madeira de Maçã TA1
Podem ser usados bloco de diferentes tipos de madeira para construir o canal do curso d'água. No entanto, qualquer outro material também pode ser usado.

[ta1_board1|image]

### Placa de Curso d'Água de Maçã TA1
Podem ser utilizados blocos em diferentes tipos de madeira para construir o canal do curso d'água. Este bloco é especialmente adequado em conexão com postes da cerca de madeira para construir um suporte do canal.

[ta1_board2|image]

# Minérios e Ferramentas
O TA1 possui suas próprias ferramentas, como martelo e peneira de cascalho, mas o Funil(Minecart Hopper) também pode ser utilizado.


## Martelo
O martelo TA1 pode ser utilizado para bater/escavar pedra em uma mina, mas também para quebrar pedregulho(cobble) em cascalho(gravel). O martelo está disponível em diferentes versões, cada uma com propriedades distintas: bronze, aço, latão e diamante.


## Peneira de Cascalho(Sieve)
Minérios podem ser peneirados do cascalho com a peneira de cascalho. Para fazer isso, clique na peneira com o cascalho. O cascalho peneirado e os minérios caem abaixo.

Para não ficar horas na peneira, é possível automatizar o processo com o Funil(Minecart Hopper).


## Funil (Minecart Hopper)
O funil do mod "Minecart Hopper" é utilizado principalmente para carregar e descarregar carrinhos de mineração. Ele suga itens de cima e os passa para a direita. Portanto, ao posicionar o funil, preste atenção na direção de dispensa.

O funil também pode puxar itens de baús, desde que a caixa esteja ao lado ou em cima do funil.

O funil também pode colocar itens em baús se a caixa estiver ao lado do funil.


## Peneirando sete cascalhos com Funil
Com a ajuda de dois baús, dois funis e uma peneira de cascalho, o processo de peneiração pode ser automatizado. O plano à direita mostra a estrutura.

Certifique-se de que os baús são protegidos, caso contrário, alguém pode roubar os minérios valiosos do baú abaixo.


Meridium
O TA1 possui sua própria liga metálica, o Meridium. Lingotes de meridium podem ser feitos com a caldeira a carvão, utilizando aço e cristais de mesecons. O meridium brilha no escuro. Ferramentas feitas de meridium também emitem luz, sendo, portanto, muito úteis na mineração subterrânea.
