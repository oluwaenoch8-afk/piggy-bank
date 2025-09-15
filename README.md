# 🔒 TimeLock – Delayed STX Vault

TimeLock is a **simple, authentic smart contract** that lets users **lock STX** until a future block height.  
Once the time is reached, they can safely **withdraw their funds**.  

---

## ✨ Features
- 🔒 **Lock STX** for a set duration  
- ⏳ **Withdraw only after unlock block**  
- 📜 **Transparent vault records**  

---

## 🚀 Example Usage

### Lock STX until block 5000
```clarity
(contract-call? .timelock lock u200 u5000)
### Withdraw STX
(contract-call? .timelock withdraw)
```

---
## 🛠️ Deployment
Deploy the contract using the Stacks CLI or a compatible wallet.

```bash
stx deploy ./timelock.clar --network testnet --sender <your-address>
```

---
## 📜 License
This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---
## 🤝 Contributing
Contributions are welcome! Please open an issue or submit a pull request.
---