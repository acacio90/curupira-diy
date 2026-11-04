# CURUPIRA DIY — guia da placa ESP32-S3

Objetivo da v0: aprender o fluxo completo do KiCad (esquemático → PCB → Gerber → JLCPCB)
com uma placa simples, que já é o "esqueleto" do CURUPIRA:

- ESP32-S3-DevKitC-1 **N16R8** encaixado em barras de pinos fêmea (nada de soldar o chip)
- Conector para módulo de tela **ST7789** (8 pinos)
- 4 botões táteis (navegação: cima, baixo, OK, voltar)
- 1 LED + resistor (o "hello world" do hardware)
- Conector **Qwiic/Grove I2C** (para o CardKB ou um PN532)
- Barra de expansão SPI (para CC1101 / NRF24 no futuro)

Tudo componente PTH (furo passante) → fácil de soldar com ferro comum.

---

## Pinagem (ESP32-S3 N16R8)

> Evite: GPIO 26–32 (flash), **33–37 (PSRAM octal no R8)**, 19/20 (USB),
> 43/44 (UART de gravação), 0/3/45/46 (strapping — afetam o boot).

| Função | GPIO | Observação |
|---|---|---|
| SPI SCK | 12 | barramento compartilhado (tela, SD, módulos) |
| SPI MOSI | 11 | |
| SPI MISO | 13 | |
| Tela CS | 10 | |
| Tela DC | 9 | |
| Tela RST | 14 | |
| Tela BLK (backlight) | 21 | dá para usar PWM para brilho |
| Expansão CS1 | 15 | ex.: CC1101 |
| Expansão CS2 | 16 | ex.: NRF24 |
| Expansão extra (GDO0/IRQ) | 17 | interrupção do módulo (GDO0 do CC1101) |
| Expansão NRF_CE | 40 | J3 pino 9 → CE do NRF24 |
| I2C SDA | 8 | Qwiic/Grove |
| I2C SCL | 18 | |
| Botão CIMA | 4 | botão → GND, usar pull-up interno |
| Botão BAIXO | 5 | |
| Botão OK | 6 | |
| Botão VOLTAR | 7 | |
| LED | 2 | LED → resistor 330 Ω → GND |
| **v0.1** microSD CS | 41 | J4 **(v0.4)**: 3V3, CS, MOSI, SCK, MISO, GND — remapeado p/ o módulo comprado (3,3 V nativo, 18,5×17,5 mm) |
| **v0.1** IR TX | 47 | R3 1k → base do BC337; LED IR + R2 22 Ω no coletor |
| **v0.1** IR RX | 42 | saída do TSOP38238 |
| **v0.1** Bateria (ADC) | 1 | divisor 100k/100k → lê metade da tensão da bateria |
| **v0.1** VIN | pino 5V | J5 (OUT do TP4056) → chave LIGA → 1N5817 → 5V do DevKit |
| **v0.1** GPS_TX (ESP RX) | 39 | J6 pino 3 → ligar no **TX** do GPS |
| **v0.2** Alto-falante BCLK | 3 | J7 pino 3 → BCLK do MAX98357A |
| **v0.2** Alto-falante WS/LRC | 45 | J7 pino 4 → LRC do MAX98357A |
| **v0.2** Alto-falante DIN | 46 | J7 pino 5 → DIN do MAX98357A (J7 pino 2 = VIN, alimentação do módulo) |
| **v0.2** I2C extra | 8 / 18 | J8 em paralelo com o J2 (GND, 3V3, SDA, SCL) |
| LED RGB do DevKit | 38 | só no DevKit **v1.1** (no v1.0 ele fica no 48, junto com o GPS) |
| **v0.1** GPS_RX (ESP TX) | 48 | J6 pino 4 → ligar no **RX** do GPS (em algumas versões do DevKit o 48 também aciona o LED RGB — inofensivo) |

Alimentação: tudo em **3V3** (pino 3V3 do DevKit). Não use 5V nos módulos de rádio.

---

## Passo 0 — preparar o KiCad (uma vez só)

1. Abra o KiCad → **Plugin and Content Manager** (Gerenciador de plugins e conteúdo).
2. Instale:
   - **Fabrication Toolkit** (gera os arquivos da JLCPCB)
   - **Espressif KiCad Library** (símbolos/footprints do ESP32-S3)
3. Feche e reabra o KiCad.

## Passo 1 — criar o projeto

1. *File → New Project* → salve **nesta pasta** (a raiz do repositório `curupira`),
   nome `curupira-diy`.
2. Vão aparecer `curupira-diy.kicad_sch` (esquemático) e `curupira-diy.kicad_pcb` (placa).

## Passo 2 — esquemático (Schematic Editor)

Atalhos que você vai usar o tempo todo:
`A` adicionar símbolo · `W` fio · `L` label (nome de rede) · `P` símbolo de energia
`R` girar · `M` mover · `E` editar propriedades · `Ins` repetir último

1. **DevKit**: procure "ESP32-S3-DevKitC" na biblioteca da Espressif (`A`).
   Se não achar, use 2× `Conn_01x22_Socket` (biblioteca `Connector`) e rotule os pinos
   conforme o datasheet do DevKitC-1.
2. **Tela**: `Conn_01x08_Socket` → pinos GND, VCC, SCL, SDA, RES, DC, CS, BLK
   (confira a ordem impressa no SEU módulo — varia entre fabricantes!).
   Obs.: no módulo ST7789, "SCL" = SCK e "SDA" = MOSI (não é I2C).
3. **Botões**: `SW_Push` ×4. Um lado no GPIO, outro no GND.
4. **LED**: `LED` + `R` (330 Ω) do GPIO 2 até o GND.
5. **Qwiic**: `Conn_01x04` → GND, 3V3, SDA, SCL.
6. **Expansão**: `Conn_01x08` → 3V3, GND, SCK, MOSI, MISO, CS1, CS2, GPIO17.
7. Em vez de puxar fio longo para tudo, use **labels** (`L`) com o mesmo nome
   (ex.: `SCK` no DevKit e `SCK` na tela = conectados).
8. **Anotar** (*Tools → Annotate*) → dá nomes R1, SW1, J1…
9. **ERC** (*Inspect → Electrical Rules Checker*) → corrija os erros.
   Dica: coloque um símbolo `PWR_FLAG` na rede 3V3 e no GND para calar o aviso clássico.
10. **Atribuir footprints** (*Tools → Assign Footprints*):
    - Conectores: `PinSocket_1x22_P2.54mm_Vertical` / `PinHeader_1x0X_P2.54mm_Vertical`
    - Botão: `SW_PUSH_6mm`
    - LED: `LED_D3.0mm` · Resistor: `R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal`
    - Qwiic: `JST_SH_SM04B-SRSS-TB_1x04-1MP_P1.00mm_Horizontal` (ou um header 1x4 se preferir)

## Passo 3 — PCB (PCB Editor)

1. *Tools → Update PCB from Schematic* (`F8`) → os componentes aparecem amontoados.
2. Desenhe o contorno da placa na camada **Edge.Cuts** (ex.: 90 × 60 mm, cantos arredondados).
3. Posicione: DevKit no meio, tela em cima, botões embaixo, conectores na borda.
   - **Meça o espaçamento entre as duas fileiras do seu DevKit** com paquímetro/régua
     antes de fixar — erro aqui = placa perdida.
   - Antena do ESP32 **para fora da placa** ou sobre área sem cobre.
4. Roteie (`X`): trilhas de sinal 0,25 mm; alimentação (3V3/GND) 0,5 mm ou mais.
5. Plano de terra: *Add Filled Zone* na camada B.Cu, rede GND (`B` para preencher).
   Desenhe uma zona proibida (*Rule Area*) embaixo da antena.
6. **DRC** (*Inspect → Design Rules Checker*) até zerar.
7. Veja em 3D: `Alt+3`.

## Passo 4 — fabricar

1. Clique no botão do **Fabrication Toolkit** → gera um `.zip` com os Gerbers.
2. jlcpcb.com → *Order now* → envie o zip. Padrão: 2 camadas, 1,6 mm, HASL.
3. 5 placas costumam sair por ~US$ 2 + frete.

## Passo 5 — testar (enquanto a placa não chega, faça na protoboard!)

Mesma pinagem acima, com jumpers. Primeiro firmware: piscar o LED do GPIO 2 e
ler os botões; depois a tela com TFT_eSPI ou LovyanGFX.

---

## Mudanças da v0.3

- **USB do DevKit na borda esquerda**: o DevKit foi girado e as portas USB ficam rentes à borda, para dar para plugar o cabo com a placa dentro do case. A antena fica sobre a placa, em cima de uma área **sem cobre** (zona "ANTENA") nas duas faces — não coloque nada metálico ali.
- **R6/R7/R8 (10k)**: pull-ups em SD_CS (41), CS1 (15) e CS2 (16) → 3V3. Mantêm os módulos SPI "desligados" enquanto o firmware não os inicializa, evitando que atrapalhem o cartão SD.
- Texto "BAT" aumentado para o mínimo da JLCPCB (1,0 mm).
- Projeto renomeado para **CURUPIRA** (frente: "CURUPIRA v0.3"; verso: logo do Curupira — cabelo em chamas e pés virados — atrás da tela).

## Depois da v0.3 (em andamento — arranjo "handheld")

> A placa roteada da v0.3 está só nos Gerbers (`production/`). O `.kicad_pcb` atual está
> **sem trilhas e sem plano de GND** (90 ligações pendentes no DRC), porque os componentes
> estão sendo reposicionados.

- **Serigrafia da frente corrigida**: cada rótulo (CIMA, OK, BAIXO, VOLTAR, I2C, SPI, GPS, SOM,
  microSD, IR, LIGA, BAT +/−) agora fica junto da peça certa. O nome saiu da frente.
- **Identidade no verso**: rosto do Curupira + "CURUPIRA" na fonte **Bungee** (polígonos, não
  depende da fonte instalada) + linha "v0.3 – ESP32-S3 – Bruce" (texto normal, fácil de editar).
  Fica na faixa livre entre as fileiras de pinos do DevKit. Arte em `arte/curupira_verso_pcb.png`;
  fonte e licença (SIL OFL) em `arte/fontes/`.
- **Modelo 3D do DevKit**: `3d/ESP32-S3-DevKitC-1.step` (SnapMagic; o arquivo "N16" é o modelo
  do N8R2 — mesmas dimensões). Ligado ao U1 com `${KIPRJMOD}`, girado 90°, deslocado 3,34 mm e
  elevado 8,5 mm, em cima de 2× barras fêmea 1x22 (só no 3D).
- **Altura**: com o DevKit encaixado, o conjunto fica com ~16 mm acima da placa — considerar no case.
- **USB**: no arranjo atual as portas USB do DevKit ficam a ~15 mm da borda direita, **não**
  rentes à borda como na v0.3. Corrigir isso no arranjo final, senão o cabo não entra com a placa no case.
- **Renders**: `renders/` (fundo transparente), recriados com `./renders/gerar.sh`.
- **Atenção — strapping**: o alto-falante (J7) usa GPIO **3, 45 e 46**, que estão na lista "Evite"
  acima. O mais delicado é o **GPIO45** (nível alto no boot muda a tensão da flash e o ESP32 pode
  não iniciar). Testar na protoboard com o MAX98357A ligado antes de fabricar.

## Furos de fixação (v0.2)

Placa 100 × 100 mm com 4 furos **M3 (3,2 mm, sem cobre)** nos cantos, a 3,5 mm das bordas → **93 × 93 mm entre centros**. Use espaçadores de ≥10 mm embaixo.

## Depois da v0

- v1: bateria LiPo + TP4056 + chave liga/desliga + leitura de tensão no ADC
- v2: teclado (CardKB no Qwiic → depois matriz própria com TCA8418)
- v3: microSD, áudio I2S (MAX98357A), IR, case
