
# Face Detection Beta (Flutter)

Este é um projeto experimental em Flutter com o objetivo de **entender e demonstrar o funcionamento básico da biblioteca `google_mlkit_face_detection`**, utilizando câmera em tempo real.

---

## 🎯 Objetivo

Explorar o uso do ML Kit (Google) para:

- 📸 Capturar imagem da câmera frontal.
- 😎 Detectar se há um **rosto presente** em tempo real.
- 🔄 Controlar fluxo de UI baseado na detecção facial.

---

## 🧠 Tecnologias utilizadas

- **Flutter 3.29.3** (gerenciado via FVM)
- [`google_mlkit_face_detection`](https://pub.dev/packages/google_mlkit_face_detection)
- [`camera`](https://pub.dev/packages/camera)
- [`permission_handler`](https://pub.dev/packages/permission_handler)

---

## 📂 Estrutura

```bash
lib/
├── main.dart                      # Tela inicial com botão
├── screens/
│   └── face_verification_screen.dart   # Verificação facial com câmera em tempo real
├── services/
│   ├── camera_service.dart        # Abstração da câmera
│   └── face_detector_service.dart # Lógica do ML Kit
```

---

## ▶️ Como rodar com FVM

1. Instale o FVM:
   ```bash
   dart pub global activate fvm
   ```

2. Instale a versão usada no projeto:
   ```bash
   fvm install 3.29.3
   fvm use 3.29.3
   ```

3. Rode o projeto:
   ```bash
   fvm flutter pub get
   fvm flutter run
   ```

---

## ❗ Importante

Este projeto **não realiza reconhecimento facial ou autenticação**. Ele apenas identifica se **existe um rosto** em frente à câmera usando o modelo local do ML Kit.

---

## 📘 Licença

Este projeto é apenas para fins educacionais e não está pronto para produção.