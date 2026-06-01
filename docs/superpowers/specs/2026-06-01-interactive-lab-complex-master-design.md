# Design Spec - Interactive Lab Complex Expansion

## 1. Graphics Lab Refinements 🖼️
- **Bidirectional Encoding**: Make the "Real-time encoded data" field editable. Changing the 0s and 1s should immediately update the pixel grid.
- **Clarification**: Label the output as "Bits" for 1-bit mode and "Bytes" for Grayscale/RGB modes.
- **RLE to Huffman**: Add a button to "Forward to Huffman" after RLE compression.

## 2. Huffman Coding (Advanced Compression) 🌳
- **Integration**: Accepts input from Graphics Lab or manual text.
- **Visualization**: Dynamic Huffman Tree generation and branch animation.

## 3. PCM Audio Improvements 🔊
- **Quantization Noise**: Add a toggle to play only the "Error Signal" (Difference between analog and quantized waves).
- **Dynamic Speed**: Sync scan line speed with Sampling Rate (Done).

## 4. Hamming Code (Error Correction) 🛡️
- **Visualization**: Venn Diagram (7,4) and Noisy Channel simulation for both graphics and audio.

## 5. Security & Historical Ciphers 🔐
- **Historical**: Caesar Cipher (with shift slider) and Vigenere Cipher.
- **Hashes**: Support for file hashing (MD5/SHA-256) via file picker.

## 6. QR & Barcode Tools 📱
- **Barcodes**: Add EAN-13 barcode generation.
- **QR Robustness**: Slider for Error Correction Levels (L, M, Q, H).

## 7. Audio Spectrogram & Frequency Steganography 🌊
- **Features**: Real-time FFT visualization and "Image to Sound" hidden message tool.

## 5. Implementation Roadmap
1. **Huffman Screen**: Core logic + Tree drawing.
2. **Hamming Screen**: Venn diagram + Bit flipping.
3. **Color Screen**: Mixing simulation.
4. **Spectrogram Screen**: FFT integration + Stegano tool.
5. **Main Menu Update**: Reorganize navigation to accommodate new laboratory tools.
