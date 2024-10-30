# IEEE 802.11-2007 (WLAN) Mini PHY

A basic 802.11 OFDM PHY layer,
including packet detection, synchronization, channel estimation, modulation and demodulation
using MATLAB.

> [!NOTE]
> This is a mini project of UCSD ECE257A (Fall 2024) implemented by [Wuqiong Zhao](https://wqzhao.org).

## Features
- [x] QPSK modulation and demodulation
- [x] OFDM symbol construction
- [x] packet detection and boundary detection (synchronization)
- [x] carrier frequency offset (CFO) estimation and correction
- [x] channel estimation

## Usage
Run the `main_dot11_OFDM.m` script to simulate the 802.11 OFDM PHY layer.
All used functions are included in the [`functions`](functions) folder.

> [!TIP]
> You will need the Signal Processing Toolbox to use the `pwelch` function in [`dot11_plot_PSD.m`](functions/dot11_plot_PSD.m).

### Plot Output
The plots are auto saved as `.eps` files in the [`plots`](plots) folder.

### Special Notes About QPSK Modulation
The QPSK modulation and demodulation are implemented in the [`dot11_QPSK_modulate.m`](functions/dot11_QPSK_modulate.m) and [`dot11_QPSK_demodulate.m`](functions/dot11_QPSK_demodulate.m) functions, respectively.
It is worth noting the implemented ones are **NOT** Gray-coded QPSK,
due to the requirement of this assignment.
The constellation mapping can be easily adjusted for other QPSK mappings.

## Acknowledgments
The code completion is assisted by ChatGPT o1-preview and GitHub Copilot.

## License
This project is distributed under the [MIT License](LICENSE).
