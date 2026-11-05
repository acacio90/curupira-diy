# CURUPIRA DIY — guia da placa ESP32-S3

Objetivo da v0: aprender o fluxo completo do KiCad (esquemático → PCB → Gerber → JLCPCB)
com uma placa simples, que já é o "esqueleto" do CURUPIRA:

- ESP32-S3-DevKitC-1 **N16R8** encaixado em barras de pinos fêmea (nada de soldar o chip)
- Conector para módulo de tela **ST7789** (8 pinos)
- 4 botões táteis (navegação: cima, baixo, OK, voltar)
- 1 LED + resistor (o "hello world" do hardware)
- Conector **Qwiic/Grove I2C** (para o CardKB ou um PN532)
- Conectores 2×4 para CC1101 (J3) e NRF24 (J9)

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
| CC1101 CS | 15 | J3 pino 4 (CSN) |
| NRF24 CS | 16 | J9 pino 4 (CSN) |
| CC1101 GDO0 (IRQ) | 17 | J3 pino 3 |
| NRF24 CE | 40 | J9 pino 3 |
| I2C SDA | 8 | Qwiic/Grove |
| I2C SCL | 18 | |
| Botão CIMA | 4 | botão → GND, usar pull-up interno |
| Botão BAIXO | 5 | |
| Botão OK | 6 | |
| Botão VOLTAR | 7 | |
| LED | 2 | LED → resistor 330 Ω → GND |
| **v0.1** microSD CS | 41 | J4 **(v0.4)**: 3V3, CS, MOSI, SCK, MISO, GND — remapeado p/ o módulo comprado (3,3 V nativo, 18,5×17,5 mm) |
| **v0.1** IR TX | 47 | R3 1k → base do Q1 (BC337); **2 LEDs IR em paralelo** no coletor — D3+R2 22Ω (topo-esq) e D5+R10 22Ω (topo-dir), ambos dobrados apontando p/ a borda de cima. Corrente ~160 mA no TX |
| **v0.1** IR RX | 42 | saída do TSOP38238 |
| **v0.1** Bateria (ADC) | 1 | divisor 100k/100k → lê metade da tensão da bateria |
| **v0.1** VIN | pino 5V | J5 (OUT do TP4056) → chave LIGA → 1N5817 → 5V do DevKit |
| **v0.1** GPS_TX (ESP RX) | 39 | J6 pino 3 → **TX** do GPS |
| *(livre)* | 3 | **buzzer removido** (eram BZ1+Q2+R9+D4); GPIO3 é strapping → deixado **sem uso** (no-connect no esquemático) p/ boot seguro |
| *(livres)* | 45, 46 | liberados com a saída do alto-falante (eram LRC/DIN do MAX98357A) |
| **v0.2** I2C extra | 8 / 18 | J8 em paralelo com o J2 (GND, 3V3, SDA, SCL) |
| LED RGB do DevKit | 38 | só no DevKit **v1.1** (no v1.0 ele fica no 48, junto com o GPS) |
| **v0.1** GPS_RX (ESP TX) | 48 | J6 pino 2 → **RX** do GPS (em algumas versões do DevKit o 48 também aciona o LED RGB — inofensivo) |

Alimentação: tudo em **3V3** (pino 3V3 do DevKit). Não use 5V nos módulos de rádio.

---

## Passo 0 — preparar o KiCad (uma vez só)

1. Abra o KiCad → **Plugin and Content Manager** (Gerenciador de plugins e conteúdo).
2. Instale:
   - **Fabrication Toolkit** (gera os arquivos da JLCPCB)
   - **Espressif KiCad Library** (símbolos/footprints do ESP32-S3)
3. Feche e reabra o KiCad.

## Passo 1 — criar o projeto

1. *File → New Project* → salve **nesta pasta** (a raiz do repositório `curupira-diy`),
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

> *(Histórico.)* A placa roteada da v0.3 está na tag git `v0.3.0`. Nesta fase, o `.kicad_pcb` estava
> **sem trilhas e sem plano de GND** (90 ligações pendentes no DRC), porque os componentes
> estão sendo reposicionados.

- **Serigrafia da frente corrigida**: cada rótulo (CIMA, OK, BAIXO, VOLTAR, I2C, SPI, GPS,
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
- **Som removido (sem buzzer)**: primeiro o MAX98357A (J7, I2S em GPIO 3/45/46) saiu, liberando os
  GPIO **45 e 46**. Depois o buzzer passivo que o substituía (BZ1 + Q2 BC337 + R9 1k + D4 1N4148, no
  GPIO3) foi **retirado também** — o dispositivo não tem saída sonora. Isso libera o **GPIO3**, que é
  pino de **strapping**: deixá-lo **sem uso** (marcado *no-connect* no esquemático) é o estado de boot
  mais seguro. Ao remover o buzzer no PCB, 2 pads THT do +3V3 que serviam de via F↔B foram substituídos
  por 2 vias (106,95) e (106,104) para manter o +3V3 do microSD J4. DRC/paridade OK.

## Arranjo em dois lados (tudo dentro do contorno)

Requisito: com os módulos **encaixados** (barra macho no módulo → barra fêmea na placa), nada passa da
borda de 100 × 100 mm. Para fora do case saem só: USB do DevKit, USB-C do TP4056, 2 antenas SMA,
cartão microSD, chave LIGA e a janela do IR.

| Lado | Peça | Conector | Ordem dos pinos (= ordem do módulo) |
|---|---|---|---|
| Frente | Tela ST7789 (deitada, barra em L) | J1 1×8 | GND, VCC, SCL, SDA, RES, DC, CS, BLK |
| Frente | GPS GY-NEO6MV2 (antena para cima) | J6 1×4 | VCC, RX, TX, GND |
| Frente | Bateria LiPo (área livre embaixo dos botões) | J5 (fios do TP4056) | + , − |
| Verso | ESP32-S3-DevKitC-1, **USB rente à borda esquerda** | U1 2×22 | — |
| Verso | PN532 V3 (I2C) | J2 1×4 | **1 SCL · 2 SDA · 3 VCC · 4 GND** (módulo encaixado de face pra fora inverte a ordem impressa nele) |
| Verso | CC1101 E07-M1101D + SMA (borda direita) | J3 2×4 | módulo encaixado de face pra fora → **pino do J3 ≠ pino do módulo**: J3-1 MISO(7) · J3-2 livre(8) · J3-3 SCK(5) · J3-4 MOSI(6) · J3-5 GDO0(3) · J3-6 CSN(4) · J3-7 GND(1) · J3-8 VCC(2) |
| Verso | NRF24L01+PA+LNA + SMA (borda direita) | J9 2×4 | 1 GND · 2 VCC · 3 CE · 4 CSN · 5 SCK · 6 MOSI · 7 MISO · 8 IRQ (livre) |
| Verso | microSD 3,3 V (cartão na borda esquerda) | J4 1×6 | 3V3, CS, MOSI, CLK, MISO, GND |
| Verso | CardKB (cabo Grove) | J8 1×4 | GND, 3V3, SDA, SCL |

> ⚠️ As ordens de CC1101 e GY-NEO6MV2 são as dos módulos mais comuns — **confira no seu módulo**
> antes de soldar a barra macho. Medidas usadas no estudo: tela 1,9" ~53×30 mm, PN532 ~43×41,
> CC1101 ~41×15 (com SMA), NRF24 PA+LNA ~41×15,5, GPS 25×36, microSD 18,5×17,5, TP4056 28×17.
> A zona "ANTENA" (sem cobre) acompanha a ponta da antena do DevKit no verso.
>
> **Modelos 3D** (pasta `3d/`, baixados do GrabCAD/SnapMagic): DevKit, tela GMT020-02, CC1101 E07-M1101D,
> NRF24L01+PA+LNA, PN532 V3, TP4056 USB-C, GPS NEO-6M. O microSD usa um **substituto visual** (OpenLog da SparkFun,
> mesmo tamanho e barra de 6 pinos) até achar o modelo do módulo real. GPS: NEO-6M (GY-NEO6MV2) no J6.
> O TP4056 vai colado no verso (fita dupla-face), USB-C na borda direita, ligado por fios ao J5 —
> fica a ~1–2 mm da zona da antena do ESP32: se o Wi-Fi ficar fraco, afastar.

## Furos de fixação (v0.2)

Placa 100 × 100 mm com 4 furos **M3 (3,2 mm, sem cobre)** nos cantos, a 3,5 mm das bordas → **93 × 93 mm entre centros**. Use espaçadores de ≥10 mm embaixo.

## Depois da v0

- v1: bateria LiPo + TP4056 + chave liga/desliga + leitura de tensão no ADC
- v2: teclado (CardKB no Qwiic → depois matriz própria com TCA8418)
- v3: microSD, buzzer, IR, case
