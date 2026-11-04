<div align="center">
  <img src="arte/curupira_logo.png" alt="CURUPIRA" width="160">

  # CURUPIRA

  **Dispositivo portátil estilo Cardputer rodando [Bruce](https://github.com/pr3y/Bruce) — ESP32-S3, feito pra montar à mão (THT).**
</div>

---

## O que é

CURUPIRA é uma PCB DIY, inspirada no M5Stack Cardputer, projetada no **KiCad** para rodar o firmware **Bruce** num **ESP32-S3-DevKitC-1 (N16R8)**. O foco é um "canivete suíço" de RF/pentest de estudo, **soldável à mão** (componentes through-hole + DevKit encaixável, sem SMD).

> ⚠️ **Uso educacional / laboratório próprio.** Rádio e RF têm regras legais — use só em equipamentos e redes seus, para estudo.

## Recursos

| Bloco | Hardware | Conector |
|---|---|---|
| Cérebro | ESP32-S3-DevKitC-1 N16R8 (WiFi + BLE nativos) | U1 |
| Tela | ST7789 SPI (IPS) | J1 |
| Sub-GHz | CC1101 (433 MHz) | J3 |
| 2.4 GHz | NRF24L01+PA+LNA | J3 |
| NFC/RFID | PN532 (I2C) | J2 |
| Armazenamento | microSD (SPI, 3,3 V) | J4 |
| Infravermelho | TSOP38238 (RX) + LED IR 940 nm (TX) | U2/D3 |
| Áudio | MAX98357A (I2S) + alto-falante | J7 |
| Teclado | M5Stack CardKB (I2C) | J8 |
| GPS (opcional) | NEO-6M / NEO-M8N (UART) | J6 |
| Energia | TP4056 (USB-C) + LiPo 3,7 V | J5 |
| Entrada | 4 botões (Prev/Sel/Next/Esc) + chave liga/desliga | SW1–SW5 |

## Estado do projeto

- **v0.3** — placa 100×100 mm, 4 furos M3, roteada, Gerbers em `production/`.
- **Em andamento:** remapeamento do microSD (J4 → módulo 3,3 V real) e novo **arranjo "handheld"** (DevKit na base, tela ao centro, botões no polegar). **Ainda não fabricada.**
- Plano: validar tudo na **protoboard** antes de mandar fabricar.

## Estrutura

```
cardputer-v0.kicad_pro / .kicad_sch / .kicad_pcb   → projeto KiCad
GUIA.md                 → mapa de pinos (GPIO ↔ cada conector)
production/             → Gerbers (JLCPCB), BOM, renders 3D
arte/                   → logo CURUPIRA
production/LISTA_DE_COMPRAS.md → lista de compras com links e preços
```

## Como fabricar

1. Envie `production/curupira-v0.3-gerbers-jlcpcb.zip` para a JLCPCB (2 camadas, 1,6 mm, HASL).
2. Compre as peças pela `production/LISTA_DE_COMPRAS.md`.
3. Solde os THT à mão; encaixe o DevKit nas barras fêmea.
4. Confira continuidade **3V3 ↔ GND** com multímetro **antes** de ligar.

## Créditos

- Firmware: **Bruce** (pr3y e colaboradores).
- Projeto de hardware: CURUPIRA.

## Licença

A definir (sugestão: hardware em **CERN-OHL-S**, docs em **CC BY-SA 4.0**).
