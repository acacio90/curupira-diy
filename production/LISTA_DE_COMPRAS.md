# CURUPIRA v0.4.1 — lista de compras

Componentes passivos saem mais baratos em kits/sortimentos.

Na coluna **Comprado**, troque ⬜ por ✅ quando comprar o item.

## 1. Placa (JLCPCB)

| Comprado | Item | Qtd | Obs. |
|---|---|---|---|
| ⬜ | PCB 100 × 100 mm, 2 camadas, 1,6 mm, HASL | 5 (mínimo) | enviar `production/curupira-v0.4.1-gerbers-jlcpcb.zip` |

## 2. Componentes da placa (BOM — `production/bom.csv`)

| Comprado | Ref | Item | Qtd | O que pedir |
|---|---|---|---|---|
| ✅ | U1 | **ESP32-S3-DevKitC-1 N16R8** | 1 | 16 MB flash + 8 MB PSRAM. Confira: 2 fileiras de 22 pinos, **22,86 mm** entre fileiras; verificar se expõe o **GPIO48** (GPS opcional) |
| ✅ | U1, J1–J4, J6, J8, J9 | **Barra fêmea 2,54 mm** | 1 pacote | para todos os encaixes fêmea (DevKit, tela, módulos). O corte das tiras a gente vê na montagem |
| ⬜ | J5 | Barra **macho** 1×2 *(ou 2 fios soldados)* | 1 | saída do TP4056 (bateria) |
| ✅ | SW1–SW4 | Botão táctil 6×6 mm THT (4 pinos) | 4 | altura 5–7 mm |
| ✅ | SW5 | Chave deslizante SPDT, passo 2,54 mm (tipo SS12D00 / OS102011MS2Q) | 1 | |
| ✅ | D1 | LED 3 mm (qualquer cor) | 1 | |
| ⬜ | D2 | Diodo Schottky **1N5817** | 1 | |
| ⬜ | D3, D5 | LED **infravermelho 940 nm 5 mm** | 2 | não confundir com 850 nm; os 2 em paralelo (cantos de cima) |
| ⬜ | Q1 | Transistor **BC337** (TO-92) | 1 | ordem dos pinos **C-B-E** |
| ⬜ | U2 | Receptor IR **TSOP38238** (38 kHz) | 1 | VS1838B é alternativa (confira a pinagem: OUT-GND-VCC) |
| ✅ | R1 | Resistor 330 Ω ¼ W | 1 | |
| ✅ | R2, R10 | Resistor **22 Ω** ¼ W | 2 | 1 por LED IR (D3, D5) |
| ✅ | R3 | Resistor 1 kΩ ¼ W | 1 | |
| ✅ | R4, R5 | Resistor 100 kΩ ¼ W | 2 | |
| ✅ | R6, R7, R8 | Resistor **10 kΩ** ¼ W | 3 | pull-ups dos CS do SPI (SD, CC1101, NRF24) |
| ✅ | — | *Kit de resistores ¼ W* | 1 | cobre todos acima |
| ✅ | C1, C2 | Capacitor cerâmico 100 nF (104), passo 2,5 mm | 2 | |

## 3. Tela

| Comprado | Item | Qtd | Obs. |
|---|---|---|---|
| ✅ | Tela IPS **ST7789** SPI, 8 pinos (GND VCC SCL SDA RES DC CS BLK) | 1 | 1,9" (170×320) ou 1,14"/1,3". **Confira a ordem dos pinos** contra o J1 e meça antes de ajustar a "área da tela" na PCB |
| ✅ | Barra de pinos **macho 90° (em L)**, 1×8 | 1 | soldar na tela no lugar da barra reta, para ela ficar **deitada** sobre a área da tela (apoie a outra ponta com espaçador/fita dupla-face) |

## 4. Módulos (Bruce)

| Comprado | Item | Qtd | Liga em | Obs. |
|---|---|---|---|---|
| ✅ | **Módulo microSD SPI 3,3 V** (leitor) | 1 | J4 | 3,3 V nativo (SEM AMS1117), 18,5×17,5 mm. Ordem **3V3, CS, MOSI, CLK, MISO, GND** — **J4 já remapeado p/ ele**. ⚠️ NÃO usar o de 5V (HW-125) |
| ⬜ | Cartão microSD 4–32 GB (FAT32) — o cartão de memória que vai no leitor | 1 | — | |
| ✅ | **CC1101** (Sub-GHz) | 1 | J3 (CS1, GDO0) — encaixe direto, antena SMA pra fora da borda | escolha a frequência da antena (433 MHz é o comum) |
| ✅ | **NRF24L01+PA+LNA** | 1 | J9 (CS2, CE) — encaixe direto | + **capacitor eletrolítico 10–100 µF** soldado no VCC/GND do módulo |
| ⬜ | **PN532** NFC/RFID (placa vermelha) | 1 | J2 (I2C) | coloque a chave do módulo em **I2C** |
| ⬜ | **M5Stack CardKB** (teclado I2C, endereço 0x5F) | 1 | J8 | vem com cabo Grove: use um cabo **Grove → dupont fêmea** (ou corte e crimpe). Preto=GND→pino 1, vermelho=VCC→pino 2 (3V3), amarelo=SDA→pino 3, branco=SCL→pino 4 |
| ✅ | Cabos jumper fêmea-fêmea 10–20 cm | 1 pacote | módulos ↔ J2/J6 (PN532, GPS) | |
| ⬜ | GPS **NEO-6M / NEO-M8N** | 1 | J6 (UART) | TX do GPS → J6 pino 3, RX do GPS → J6 pino 4. Confira se funciona em 3,3 V |

## 5. Bateria

| Comprado | Item | Qtd | Obs. |
|---|---|---|---|
| ✅ | Módulo **TP4056 com proteção** (6 terminais: IN+, IN−, B+, B−, OUT+, OUT−), USB-C | 1 | **OUT+ → J5 "+"**, **OUT− → J5 "−"** |
| ⬜ | Bateria **LiPo 3,7 V 1000–2000 mAh** (de preferência com proteção) | 1 | B+/B− do TP4056 |

## 5b. Fixação (case)

| Comprado | Item | Qtd | Obs. |
|---|---|---|---|
| ⬜ | Parafuso M3 × 6–8 mm | 4 | furos H1–H4 nos cantos (93 mm entre centros) |
| ⬜ | Espaçador/standoff M3 de **≥10 mm** (latão ou nylon) | 4 | embaixo da placa — as soldas THT ficam salientes no verso |
| ⬜ | *(se o case for impresso)* Inserto de latão M3 para calor | 4 | ou furo de 2,5–2,8 mm para o parafuso abrir rosca |

## 6. Ferramentas / consumíveis (se ainda não tiver)

| Comprado | Item | Obs. |
|---|---|---|
| ⬜ | Estanho 0,8 mm com fluxo (Sn63/Pb37 ou sem chumbo) | |
| ⬜ | Sugador ou malha dessoldadora | para corrigir erros |
| ⬜ | Multímetro | para conferir curtos entre 3V3/GND **antes** de ligar |
| ⬜ | Alicate de corte rente | para cortar as pernas dos THT |

---

### Ordem de montagem sugerida
1. Componentes baixos primeiro: resistores, diodos, capacitores, BC337.
2. Botões, chave, LEDs, TSOP (pernas compridas no IR, para dobrar para fora da borda).
3. Barras fêmea (dica: encaixe o DevKit nelas **antes** de soldar, para ficarem alinhadas).
4. **Antes de ligar:** multímetro em continuidade entre 3V3 e GND — **não pode apitar**.
5. Primeiro teste só com USB do DevKit (sem bateria): pisca o LED (GPIO2), lê os botões.
