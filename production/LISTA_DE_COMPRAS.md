# CURUPIRA v0.4 — lista de compras

Preços são **estimativas** (AliExpress / Mercado Livre, nov/2026) — variam bastante.
Componentes passivos saem muito mais baratos em kits/sortimentos.

## 1. Placa (JLCPCB)

| Item | Qtd | Obs. | ~Preço |
|---|---|---|---|
| PCB 100 × 100 mm, 2 camadas, 1,6 mm, HASL | 5 (mínimo) | enviar `production/curupira-v0.4-gerbers-jlcpcb.zip` | US$ 2–5 + frete + impostos (~R$ 70–180 no total) |

## 2. Componentes da placa (BOM — `production/bom.csv`)

| Ref | Item | Qtd | O que pedir | ~Preço |
|---|---|---|---|---|
| U1 | **ESP32-S3-DevKitC-1 N16R8** | 1 | 16 MB flash + 8 MB PSRAM. Confira: 2 fileiras de 22 pinos, **22,86 mm** entre fileiras; verificar se o anúncio expõe o **GPIO48** (GPS opcional). [🔗 Anúncio AliExpress](https://pt.aliexpress.com/item/1005012743014502.html) | R$ 46,90 |
| — | **Barra fêmea 1×40, 2,54 mm — pacote c/ 10** | 1 pacote | **de onde saem TODOS os encaixes fêmea abaixo** (usa ~3 das 10 tiras). [🔗 Anúncio AliExpress](https://pt.aliexpress.com/item/4001198421663.html) | R$ 7,35 |
| U1 | ↳ cortar **2× 1×22** fêmea | 2 | DevKit (2 fileiras) | ↑ incluso |
| J1 | ↳ cortar **1×8** fêmea | 1 | tela | ↑ |
| J2 | ↳ cortar **1×4** fêmea | 1 | I2C / PN532 | ↑ |
| J3 | ↳ cortar **2× 1×4** fêmea (lado a lado = 2×4) | 2 | CC1101 (encaixe direto) | ↑ |
| J4 | ↳ cortar **1×6** fêmea | 1 | módulo microSD | ↑ |
| J6 | ↳ cortar **1×4** fêmea | 1 | GPS (opcional) | ↑ |
| J8 | ↳ cortar **1×4** fêmea | 1 | I2C extra (paralelo c/ J2) | ↑ |
| J9 | ↳ cortar **2× 1×4** fêmea (lado a lado = 2×4) | 2 | NRF24L01+PA+LNA (encaixe direto) | ↑ |
| J5 | Barra **macho** 1×2 *(ou 2 fios soldados)* | 1 | saída do TP4056 (bateria) — **item à parte** | centavos |
| — | Barra **macho 90° (em L)** 1×8 | 1 | soldada **na tela**, pra ela deitar — **item à parte** | R$ 2–5 |
| SW1–SW4 | Botão táctil 6×6 mm THT (4 pinos) | 4 | altura 5–7 mm | R$ 5 (kit) |
| SW5 | Chave deslizante SPDT, passo 2,54 mm (tipo SS12D00 / OS102011MS2Q) | 1 | | R$ 2–5 |
| D1 | LED 3 mm (qualquer cor) | 1 | | centavos |
| D2 | Diodo Schottky **1N5817** | 1 | | centavos |
| D3, D5 | LED **infravermelho 940 nm 5 mm** | 2 | não confundir com 850 nm; os 2 em paralelo (cantos de cima) | R$ 2–6 |
| Q1 | Transistor **BC337** (TO-92) | 1 | ordem dos pinos **C-B-E** | centavos |
| U2 | Receptor IR **TSOP38238** (38 kHz) | 1 | VS1838B é alternativa barata (confira a pinagem: OUT-GND-VCC) | R$ 3–8 |
| R1 | Resistor 330 Ω ¼ W | 1 | | |
| R2, R10 | Resistor **22 Ω** ¼ W | 2 | 1 por LED IR (D3, D5) | |
| R3 | Resistor 1 kΩ ¼ W | 1 | | |
| R4, R5 | Resistor 100 kΩ ¼ W | 2 | | |
| R6, R7, R8 | Resistor **10 kΩ** ¼ W | 3 | pull-ups dos CS do SPI (SD, CC1101, NRF24) | |
| — | *Kit de resistores ¼ W* | 1 | cobre todos acima | R$ 15–25 |
| C1, C2 | Capacitor cerâmico 100 nF (104), passo 2,5 mm | 2 | | centavos |

> **Plano de corte da barra fêmea 1×40** — regra: pra ter **N** pinos, corte **no furo N+1** (perde 1 posição por corte).
> - **Tira 1:** 22 → 8 → 6  → *(U1 fileira 1, J1, J4)*
> - **Tira 2:** 22 → 4 → 4 → 4  → *(U1 fileira 2, J2, J6, J8)*
> - **Tira 3:** 4 → 4 → 4 → 4  → *(J3 e J9: duas 1×4 lado a lado em cada)*
>
> Alternativa para J3/J9: comprar **barra fêmea 2×4 (dupla)** pronta — fica mais alinhada que duas 1×4.
>
> Usa só ~3 das 10 tiras do pacote; o resto é folga pra treinar o corte. Lixe a ponta cortada pra ficar reta.
> **J5 e a barra 90° da tela são MACHO** — não saem dessa barra fêmea, compre à parte (ou J5 com fio direto).

## 3. Tela

| Item | Qtd | Obs. | ~Preço |
|---|---|---|---|
| Tela IPS **ST7789** SPI, 8 pinos (GND VCC SCL SDA RES DC CS BLK) | 1 | 1,9" (170×320) ou 1,14"/1,3". **Confira a ordem dos pinos** contra o J1 e meça antes de ajustar a "área da tela" na PCB | R$ 20–40 |
| Barra de pinos **macho 90° (em L)**, 1×8 | 1 | soldar na tela no lugar da barra reta, para ela ficar **deitada** sobre a área da tela (apoie a outra ponta com espaçador/fita dupla-face) | R$ 2–5 |

## 4. Módulos (Bruce)

| Item | Qtd | Liga em | Obs. | ~Preço |
|---|---|---|---|---|
| **Módulo microSD SPI 3,3 V** ✅ *(escolhido)* | 1 | J4 | 3,3 V nativo (SEM AMS1117), 18,5×17,5 mm. Ordem **3V3, CS, MOSI, CLK, MISO, GND** — **J4 já remapeado p/ ele**. ⚠️ NÃO usar o de 5V (HW-125) | R$ 8–15 |
| Cartão microSD 4–32 GB (FAT32) | 1 | — | | R$ 20–30 |
| **CC1101** (Sub-GHz) | 1 | J3 (CS1, GDO0) — encaixe direto, antena SMA pra fora da borda | escolha a frequência da antena (433 MHz é o comum) | R$ 15–30 |
| **NRF24L01+PA+LNA** | 1 | J9 (CS2, CE) — encaixe direto | + **capacitor eletrolítico 10–100 µF** soldado no VCC/GND do módulo | R$ 15–35 |
| **PN532** NFC/RFID (placa vermelha) | 1 | J2 (I2C) | coloque a chave do módulo em **I2C** | R$ 30–50 |
| **M5Stack CardKB** (teclado I2C, endereço 0x5F) | 1 | J8 | vem com cabo Grove: use um cabo **Grove → dupont fêmea** (ou corte e crimpe). Preto=GND→pino 1, vermelho=VCC→pino 2 (3V3), amarelo=SDA→pino 3, branco=SCL→pino 4 | US$ 10–15 |
| Cabos jumper fêmea-fêmea 10–20 cm | 1 pacote | módulos ↔ J2/J6 (PN532, GPS) | | R$ 8–15 |
| *(opcional, futuro)* GPS **NEO-6M / NEO-M8N** | 1 | J6 (UART) | TX do GPS → J6 pino 3, RX do GPS → J6 pino 4. Confira se funciona em 3,3 V | R$ 30–60 |

## 5. Bateria

| Item | Qtd | Obs. | ~Preço |
|---|---|---|---|
| Módulo **TP4056 com proteção** (6 terminais: IN+, IN−, B+, B−, OUT+, OUT−), USB-C | 1 | **OUT+ → J5 "+"**, **OUT− → J5 "−"** | R$ 5–10 |
| Bateria **LiPo 3,7 V 1000–2000 mAh** (de preferência com proteção) | 1 | B+/B− do TP4056 | R$ 30–60 |

## 5b. Fixação (case)

| Item | Qtd | Obs. | ~Preço |
|---|---|---|---|
| Parafuso M3 × 6–8 mm | 4 | furos H1–H4 nos cantos (93 mm entre centros) | R$ 5 (kit) |
| Espaçador/standoff M3 de **≥10 mm** (latão ou nylon) | 4 | embaixo da placa — as soldas THT ficam salientes no verso | R$ 5–10 |
| *(se o case for impresso)* Inserto de latão M3 para calor | 4 | ou furo de 2,5–2,8 mm para o parafuso abrir rosca | R$ 5–10 |

## 6. Ferramentas / consumíveis (se ainda não tiver)

| Item | Obs. |
|---|---|
| Estanho 0,8 mm com fluxo (Sn63/Pb37 ou sem chumbo) | |
| Sugador ou malha dessoldadora | para corrigir erros |
| Multímetro | para conferir curtos entre 3V3/GND **antes** de ligar |
| Alicate de corte rente | para cortar as pernas dos THT |

---

**Total aproximado** (sem ferramentas, sem frete da JLCPCB): **R$ 280–510**, dependendo dos módulos e de onde comprar.

### Ordem de montagem sugerida
1. Componentes baixos primeiro: resistores, diodos, capacitores, BC337.
2. Botões, chave, LEDs, TSOP (pernas compridas no IR, para dobrar para fora da borda).
3. Barras fêmea (dica: encaixe o DevKit nelas **antes** de soldar, para ficarem alinhadas).
4. **Antes de ligar:** multímetro em continuidade entre 3V3 e GND — **não pode apitar**.
5. Primeiro teste só com USB do DevKit (sem bateria): pisca o LED (GPIO2), lê os botões.
