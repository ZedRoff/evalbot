# 🤖 Hexarium - EvalBot

## ESIEE EvalBot Project

---

This project is made for the unit **3I - ARM Architecture**. The objective was to insert **Assembly instructions** into a given **SoC (System on a Chip)**. The goal was to utilize various components such as **motors, bumpers, switches, and LEDs** to give the project a functional purpose.

The project involves programming an **EvalBot** to develop a robot that must infiltrate another fictitious EvalBot to purge a **virus** from its system. This robot interacts with various EvalBot board components, including LEDs, switches, motors, and bumpers. The goal is to create a robot capable of **following a path, solving puzzles, and navigating obstacles** to purify the system.

---

## 📖 Table of Contents
- [📥 User Guide](#-user-guide)
- [👨‍💻 Developer](#-developer)
- [✨ Features](#-features)
- [© Copyright](#-copyright)

---

## 📥 User Guide

To make this project work, you need to install **Keil uVision** and have the **EvalBot SoC** provided by **Texas Instruments**. We are using the **LS92XXXX runtime**.

### 🔄 Clone the Repository
```sh
git clone https://github.com/ZedRoff/evalbot.git
cd evalbot
```

---

## 👨‍💻 Developer
- **Aman GHAZANFAR**

---

## ✨ Features

### 🦾 Robot Capabilities
- 🚀 Controls all key components:
  - 🔧 Right Motor & Left Motor
  - 💡 4 LEDs
  - 🎛️ 2 Front Switches
  - 🔌 2 Back RJ45 Switches
- 🛤️ **Follows a predefined path** using a cardboard and obstacles
- 🤖 **Detects collisions** using two front bumpers
- 🎮 **Accepts user input** from switches
- 🧠 **Solves four challenges** to progress

### 🧩 Challenges
1. **🔢 Registry Puzzle**
   - Perform **XOR, ADD, and LEFT SHIFT** operations to get a **binary result**
   - Input the binary result using switches, turning LEDs on/off to simulate a **4-bit number**

2. **⚡ Speed Test**
   - LEDs start **blinking**
   - Follow the path in the shortest time possible
   - Similar to the classic **SIMON** game (look it up in French!)

3. **✅ Yes or No Question 1**
   - Answer using the **switches**

4. **✅ Yes or No Question 2**
   - Another question requiring a switch-based response

---

## © Copyright

I hereby declare on my honor that the code provided was produced by myself.

> 🌟 *Hope you can get something out of it!*
