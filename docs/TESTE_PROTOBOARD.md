# CURUPIRA v0.4 — plano de teste na protoboard

Objetivo: provar **cada bloco do circuito** com as peças reais, antes de mandar a PCB pra JLCPCB.
Tudo que der errado aqui custa um jumper; na placa custa um pedido novo.

**Regra de ouro:** um bloco por vez. Só passe pro próximo quando o atual estiver ✅ —
e **não desmonte** os blocos anteriores: o teste final é tudo ligado junto.

Pinagem de referência: [`GUIA.md`](../GUIA.md) e `docs/pinagem.html`.
Ligue os módulos **pelo nome do pino impresso neles** (VCC, CSN, MOSI…), nunca pela posição.

---

## 0. Antes de começar

**Material:** DevKit N16R8, **2 protoboards de 830 furos** (o DevKitC-1 é largo: numa só ele cobre
quase tudo — junte duas lado a lado e ponha uma fileira de pinos em cada), jumpers M-M e M-F,
multímetro, cabo USB-C **de dados**, os módulos e passivos da `production/LISTA_DE_COMPRAS.md`.

**Software:** Arduino IDE 2 ou PlatformIO, com o core **esp32 (Espressif)**.
Placa: *ESP32S3 Dev Module* → `Flash Size: 16MB`, `PSRAM: OPI PSRAM`, `USB CDC On Boot: Enabled`.

**Segurança:**
- Módulos **só em 3V3** (pino 3V3 do DevKit). 5V queima CC1101/NRF24/SD.
- Ligue/desligue fios **com o USB desconectado**.
- Antes de cada energização: multímetro em continuidade **3V3 ↔ GND — não pode apitar**.
- Não use os GPIO 0, 3, 45 e 46 (strapping), 19/20 (USB) nem 26–37 (flash/PSRAM).

---

## 1. DevKit sozinho

| Teste | Como | ✅ Passou se |
|---|---|---|
| Gravar | sketch vazio com `Serial.println("oi")` em loop | aparece "oi" no Monitor Serial |
| Memórias | `ESP.getFlashChipSize()`, `ESP.getPsramSize()` | **16 MB** de flash e **~8 MB** de PSRAM |
| Versão do DevKit | `neopixelWrite(38, 0, 0, 20)` | LED RGB acende azul → DevKit **v1.1** (RGB no 38). Se não acender, teste no 48 → v1.0 (conflita com o GPS_RX, ver §11) |

## 2. LED de status + 4 botões

| Ligação | GPIO |
|---|---|
| GPIO → R 330 Ω → LED (perna longa) → GND | **2** |
| botão CIMA → GND | **4** |
| botão BAIXO → GND | **5** |
| botão OK → GND | **6** |
| botão VOLTAR → GND | **7** |

Botões com `pinMode(x, INPUT_PULLUP)` (sem resistor externo, igual à PCB).
✅ LED pisca; cada botão imprime o próprio nome **uma vez** por toque (veja se não tem leitura fantasma).
> Botão 6×6 tem 4 pernas em 2 pares já ligados — use pernas em **diagonal** pra não errar o par.

## 3. Tela ST7789 (SPI)

| Tela | GND | VCC | SCL | SDA | RES | DC | CS | BLK |
|---|---|---|---|---|---|---|---|---|
| DevKit | GND | 3V3 | **12** | **11** | **14** | **9** | **10** | **21** |

> "SCL/SDA" da tela = SCK/MOSI do SPI (não é I2C). Ordem do J1 na PCB: GND, VCC, SCL, SDA, RES, DC, CS, BLK.

Teste com **TFT_eSPI** ou **LovyanGFX** (ajuste o driver pra ST7789 e a resolução do SEU módulo).
✅ Cores certas (vermelho é vermelho — se vier invertido, `invertDisplay`), sem tela branca,
backlight responde ao GPIO 21. **Anote a resolução e o offset** — o Bruce vai precisar.

## 4. microSD (mesmo barramento SPI da tela)

| Módulo SD | 3V3 | CS | MOSI | CLK | MISO | GND |
|---|---|---|---|---|---|---|
| DevKit | 3V3 | **41** | 11 | 12 | **13** | GND |

\+ **pull-up 10 kΩ de CS(41) → 3V3** (é o R6 da PCB).

Teste: exemplo `SD_Test` (`SD.begin(41)`), cartão FAT32.
✅ lista os arquivos, escreve e lê de volta um `.txt`.
✅ **com a tela já ligada:** desenha na tela, grava no SD, desenha de novo — os dois funcionam alternados.

## 5. I2C — PN532 e CardKB

| Sinal | GPIO |
|---|---|
| SDA | **8** |
| SCL | **18** |

- PN532: **chaves do módulo em I2C** (geralmente SW1=ON, SW2=OFF — confira na serigrafia).
- CardKB: cabo Grove — preto GND, vermelho 3V3, amarelo SDA, branco SCL.
- Os dois no mesmo barramento (na PCB, J2 e J8 estão em paralelo).

> Ordem dos pinos na PCB — **J2:** SCL, SDA, 3V3, GND · **J8:** GND, 3V3, SDA, SCL.
> São diferentes entre si: confira contra o PN532 e o cabo do CardKB.

Teste: *I2C scanner* com `Wire.begin(8, 18)`.
✅ aparecem **0x24** (PN532) e **0x5F** (CardKB).
✅ PN532 lê o UID de um cartão/tag (lib Adafruit_PN532); CardKB imprime as teclas apertadas.

## 6. Infravermelho

**RX — TSOP38238:** OUT → **42**, GND, VS → 3V3 (VS1838B tem outra ordem: OUT-GND-VCC).

**TX — 2 LEDs em paralelo, igual à PCB:**
```
GPIO 47 ── R3 1kΩ ── base Q1 (BC337)
3V3 ── R2 22Ω ── D3 (anodo→catodo) ─┐
3V3 ── R10 22Ω ── D5 (anodo→catodo) ─┴── coletor Q1 ; emissor Q1 ── GND
```
BC337 com a face reta pra você: **C-B-E**.

Teste com **IRremoteESP8266**: receba o código de um controle remoto (RX), depois reenvie (TX).
- ✅ RX decodifica o protocolo (NEC, Samsung…) de um controle de TV.
- ✅ Câmera do celular (a frontal costuma não ter filtro IR) mostra os **2 LEDs** piscando.
- ✅ A TV obedece ao comando reenviado; meça a distância máxima.
- ⚠️ Corrente ~160 mA no total. Só em pulsos (portadora de 38 kHz) — **não deixe o GPIO 47 em HIGH
  parado** por muito tempo, senão os resistores de 22 Ω e os LEDs esquentam.

## 7. CC1101 (Sub-GHz)

| Módulo | VCC | GND | CSN | SCK | MOSI | MISO | GDO0 | GDO2 |
|---|---|---|---|---|---|---|---|---|
| DevKit | 3V3 | GND | **15** | 12 | 11 | 13 | **17** | — (solto) |

\+ **pull-up 10 kΩ de CSN(15) → 3V3** (R7 da PCB).

Teste: lib **SmartRC-CC1101-Driver-Lib** (ELECHOUSE) → `ELECHOUSE_cc1101.getCC1101()` retorna true.
✅ detecta o chip; ✅ recebe o sinal de um controle 433 MHz seu (portão/tomada RF) em modo RX.

> ### ⚠️ Conferir o J3 antes de fabricar
> No esquemático, o J3 (2×4) está assim: **1=MISO, 2=livre, 3=SCK, 4=MOSI, 5=GDO0, 6=CSN, 7=GND, 8=3V3**.
> Os módulos CC1101 2×4 mais comuns têm: 1=GND, 2=VCC, 3=GDO0, 4=CSN, 5=SCK, 6=MOSI, 7=MISO, 8=GDO2
> (é essa ordem que o `GUIA.md` cita). O J3 é **essa ordem com as fileiras espelhadas**, o que faz
> sentido se for de propósito, já que o CC1101 fica no **verso** da placa.
> **Com o SEU módulo na mão:** veja a serigrafia dele e, no KiCad (3D, `Alt+3`, vista de baixo),
> confira que ao encaixá-lo no J3 o pino **VCC cai no 3V3 e o GND no GND**. Se não bater,
> 3V3 vai pro MISO — corrija o J3 **antes** de pedir a placa.

## 8. NRF24L01+PA+LNA (2,4 GHz)

| Módulo | GND | VCC | CE | CSN | SCK | MOSI | MISO | IRQ |
|---|---|---|---|---|---|---|---|---|
| DevKit | GND | 3V3 | **40** | **16** | 12 | 11 | 13 | — (solto) |

\+ **pull-up 10 kΩ de CSN(16) → 3V3** (R8 da PCB) + **eletrolítico 10–100 µF** colado no VCC/GND do módulo.
(J9 na PCB segue a ordem padrão do módulo: 1=GND, 2=VCC, 3=CE, 4=CSN, 5=SCK, 6=MOSI, 7=MISO.)

Teste: lib **RF24** → `radio.begin()` e `radio.isChipConnected()` = true; `printPrettyDetails()` mostra
registradores com valores coerentes (não tudo 0x00 ou 0xFF).
✅ chip detectado; ✅ exemplo *scanner* mostra atividade nos canais do seu WiFi.
> O PA+LNA puxa picos altos: se ele "some" de vez em quando, é alimentação — capacitor maior / fio mais curto.

## 9. Barramento SPI completo (o teste mais importante)

Agora com **tela + SD + CC1101 + NRF24** todos no mesmo SCK/MOSI/MISO, cada um com seu CS e pull-up.

Sketch que, em loop: desenha na tela → grava no SD → lê o chip ID do CC1101 → `isChipConnected()` do NRF24.
✅ roda **10 minutos** sem nenhum módulo falhar.
✅ Tire o cartão SD com tudo ligado: os outros continuam funcionando.
> Se algum falhar só quando os outros estão ligados: CS sem pull-up, fio de MISO comprido demais,
> ou falta de corrente no 3V3 (veja §10).

## 10. Energia (bateria)

```
TP4056 OUT+ ── chave LIGA ── 1N5817 (anodo→catodo, faixa = catodo) ── pino 5V do DevKit
                           └─ 100 kΩ ─┬─ 100 kΩ ── GND
                                      └── GPIO 1 (BAT_ADC)  + 100 nF pro GND
TP4056 OUT− ── GND
```

| Teste | ✅ Passou se |
|---|---|
| Ligar só na bateria (sem USB) | DevKit liga, tela acende |
| BAT_ADC | `analogReadMilliVolts(1) × 2` ≈ tensão da bateria no multímetro (±0,1 V) |
| USB + bateria juntos | sem esquentar nada; o 1N5817 impede o 5V do USB de voltar pra bateria |
| Carga | LED do TP4056 muda de vermelho pra azul/verde quando carrega |
| Consumo | multímetro em série na saída do TP4056: anote o consumo com WiFi + NRF24 + CC1101 ativos |
| Queda de tensão | 3V3 do DevKit não cai abaixo de ~3,2 V com tudo transmitindo |

## 11. GPS (opcional)

| GPS | VCC | TX | RX | GND |
|---|---|---|---|---|
| DevKit | 3V3 (confira se o módulo aceita) | **39** (RX do ESP) | **48** (TX do ESP) | GND |

Teste: `Serial1.begin(9600, SERIAL_8N1, 39, 48)` e repetir pro Serial.
✅ chegam frases NMEA (`$GPGGA…`); ao ar livre, ✅ fix em alguns minutos.
> DevKit v1.0: o GPIO 48 também acende o LED RGB — inofensivo, mas pode piscar junto.

## 12. Bruce com tudo ligado

Compile o Bruce com esta pinagem (configuração de placa custom para ESP32-S3) e teste pelos menus:
navegação pelos 4 botões, tela, SD (arquivos), IR (receber/enviar), RF/CC1101, NRF24, NFC/PN532,
teclado CardKB, GPS, leitura de bateria.
✅ todos os módulos aparecem e funcionam pelo firmware real — **isso libera a fabricação**.

---

## Resultado

| # | Bloco | Status | Anotações (valores medidos, problemas, ajustes) |
|---|---|---|---|
| 1 | DevKit (flash/PSRAM/versão) | ⬜ | |
| 2 | LED + botões | ⬜ | |
| 3 | Tela ST7789 | ⬜ | resolução/offset: |
| 4 | microSD | ⬜ | |
| 5 | I2C (PN532 + CardKB) | ⬜ | |
| 6 | IR RX/TX | ⬜ | alcance: |
| 7 | CC1101 + **conferência do J3** | ⬜ | |
| 8 | NRF24 | ⬜ | |
| 9 | SPI completo | ⬜ | |
| 10 | Energia | ⬜ | consumo: · ADC: |
| 11 | GPS (opcional) | ⬜ | |
| 12 | Bruce | ⬜ | |

Algo deu errado e precisa mudar a placa? Corrija esquemático + PCB, rode ERC/DRC, regenere os
Gerbers e só então faça o pedido.
