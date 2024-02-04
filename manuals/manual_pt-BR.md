# Mod Tech Age
O Tech Age é um mod de tecnologia com 5 estágios de desenvolvimento:

## TA1: Idade do Ferro
Utilize ferramentas e instrumentos auxiliares como queimadores de carvão, peneiras de cascalho, martelos e funis para extrair e processar minérios e metais necessários.

## TA2: Idade do Vapor
Construa uma máquina a vapor com eixos de transmissão e use-a para operar suas primeiras máquinas de processamento de minérios.

## TA3: Idade do Petróleo
Encontre e extraia óleo, construa ferrovias para transporte de óleo. Uma usina fornece a eletricidade necessária para suas máquinas. A luz elétrica ilumina suas instalações industriais.

## TA4: Tempos atuais (Presente)
Fontes de energia renovável, como vento, sol e biocombustíveis, ajudam você a sair da era do petróleo. Com tecnologias modernas e máquinas inteligentes, você parte para o futuro.

## TA5: Futuro
Máquinas para superar espaço e tempo, novas fontes de energia e outras conquistas moldam sua vida.

Nota: Clicando no sinal de adição, você acessa os subcapítulos deste manual.

[techage_ta4|image]

# Dicas
Esta documentação está disponível tanto "dentro do jogo" (plano de construção de blocos) quanto no GitHub como arquivos MD.

* Link: https://github.com/joe7575/techage/wiki
Os planos de construção (diagramas) para a construção das máquinas e as imagens estão disponíveis apenas no jogo.

Com o Tech Age, você precisa começar do zero. Você só pode criar blocos TA2 com os itens do TA1, para o TA3 você precisa dos resultados do TA2, e assim por diante.

No TA2, as máquinas só funcionam com eixos de transmissão.

A partir do TA3, as máquinas funcionam com eletricidade e têm uma interface de comunicação para controle remoto.

O TA4 adiciona mais fontes de energia, mas também desafios logísticos mais altos (linhas de energia, transporte de itens).

# Mudanças a partir da versão 1.0
A partir da V1.0 (17/07/2021), as seguintes alterações foram feitas:

* O algoritmo para calcular a distribuição de energia foi alterado. Isso torna os sistemas de armazenamento de energia mais importantes. Eles compensam as flutuações, o que é importante em redes maiores com vários geradores.
* Por esse motivo, o TA2 recebeu seu próprio sistema de armazenamento de energia.
* Os blocos de bateria do TA3 também servem como armazenamento de energia. Sua funcionalidade foi adaptada de acordo.
* O sistema de armazenamento do TA4 foi revisado. O permutador de calor recebeu um novo número porque a funcionalidade foi movida do bloco inferior para o bloco central. Se eles estiverem sendo controlados remotamente, o número do nó deve ser adaptado. Os geradores não têm mais um menu próprio, mas são ligados/desligados apenas através do permutador de calor. O permutador de calor e o gerador agora devem estar conectados à mesma rede!
* Vários sistemas de energia podem agora ser acoplados via blocos transformadores TA4.
* Um novo bloco medidor de eletricidade TA4 para sub-redes também foi adicionado.
* Pelo menos um bloco de bateria ou um sistema de armazenamento em cada rede.

## Dicas sobre a troca
Muitos outros blocos receberam alterações menores. Portanto, é possível que máquinas ou sistemas não reiniciem imediatamente após a troca. Em caso de falhas, as seguintes dicas ajudarão:

* Desligue e ligue as máquinas novamente.
* Remova um bloco de cabo de energia e coloque-o de volta no lugar.
* Remova completamente o bloco e coloque-o de volta no lugar.

# Minérios e Minerais
Techage adiciona novos itens ao jogo:

* Meridium - uma liga para a produção de ferramentas luminosas no TA1
* Usmium - um minério que é extraído no TA2 e necessário para o TA3
* Baborium - um metal necessário para receitas no TA3
* Petróleo - necessário no TA3
* Bauxita - um minério de alumínio necessário no TA4 para produzir alumínio
* Basalto - surge quando água e lava se encontram

## Meridium
O Meridium é uma liga de aço e cristais de mesecons. Lingotes de Meridium podem ser feitos com a caldeira a carvão a partir de aço e cristais de mesecons. O Meridium brilha no escuro. Ferramentas feitas de Meridium também emitem luz e são, portanto, muito úteis na mineração subterrânea.

[meridium|image]

## Usmium
O Usmium ocorre apenas como pepitas e só pode ser obtido lavando cascalho com o sistema de lavagem de cascalho TA2/TA3.

[usmium|image]

## Baborium
O Baborium só pode ser obtido através da mineração subterrânea. Essa substância só pode ser encontrada a uma profundidade de -250 a -340 metros.

O Baborium só pode ser derretido na Fornalha Industrial TA3.

[baborium|image]

## Petróleo
O Petróleo só pode ser encontrado com a ajuda do Explorer e extraído com a ajuda de máquinas apropriadas do TA3. Veja TA3.

[oil|image]

## Bauxita
A Bauxita é extraída apenas na mineração subterrânea. A Bauxita só é encontrada na pedra a uma altura entre -50 e -500 metros.
É necessária para a produção de alumínio, que é principalmente usada no TA4.

[bauxite|image]

## Basalto
O Basalto só é criado quando lava e água se encontram.
A melhor coisa a fazer é montar um sistema onde uma fonte de lava e uma fonte de água se encontram.
O Basalto é formado onde ambos os líquidos se encontram.
Você pode construir um gerador automático de basalto com o Sign Bot.

[basalt|image]


## History

- 28.09.2019: Solar system added
- 05.10.2019: Data on the solar system and description of the inverter and the power terminal changed
- 18.11.2019: Chapter for ores, reactor, aluminum, silo, bauxite, furnace heating, gravel washing system added
- 22.02.2020: corrections and chapters on the update
- 29.02.2020: ICTA controller added and further corrections
- 14.03.2020 Lua controller added and further corrections
- 22.03.2020 More TA4 blocks added
