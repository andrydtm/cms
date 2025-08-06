Berikut versi yang telah diperbaiki dan diformat dengan baik untuk ditaruh di file `README.md` GitHub:

## 🚀 Instalasi CMS (Wajib Ubuntu 24.04)

**Pastikan kamu menggunakan Ubuntu 24.04**

```bash
sudo mkdir -p /opt/cms \
&& sudo chown $USER:$USER /opt/cms \
&& cd /opt/cms
```
```bash
wget https://raw.githubusercontent.com/andrydtm/cms/refs/heads/main/install_docker.sh \
&& sudo chmod +x install_docker.sh \
&& sudo ./install_docker.sh
```

Saat diminta untuk memilih opsi, cukup pilih **n** (tidak) jika ragu.

### ⚠️ Catatan

- Login awal mungkin agak sulit — **coba beberapa kali hingga berhasil.**
