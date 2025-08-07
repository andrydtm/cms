## 🚀 Instalasi CMS C-data (Wajib Ubuntu 24.04)

**1. Buat Folder CMS**
```bash
sudo mkdir -p /opt/cms \
&& sudo chown $USER:$USER /opt/cms \
&& cd /opt/cms
```
**2. Install Docker**
```bash
wget https://raw.githubusercontent.com/andrydtm/cms/refs/heads/main/install_docker.sh \
&& sudo chmod +x install_docker.sh \
&& sudo ./install_docker.sh
```
**3. Install CMS**
```bash
cd /opt/cms && sudo ./cms_install.sh install --version <cms_version>
```
- _Versi saat ini 3.6.24_
- _Saat diminta untuk memilih opsi, cukup pilih **n** (tidak) jika ragu._

**4. Upgrade CMS**
```bash
cd /opt/cms && sudo ./cms_install.sh upgrade --version <cms_version>
```
**5. Restart CMS**
```bash
cd /opt/cms \
&& sudo docker compose down \
&& sudo docker compose up -d
```
### ⚠️ Catatan
- Login awal mungkin agak sulit — **coba beberapa kali hingga berhasil.**
- Silahkan sesuaikan tempat folder **/opt/cms** sesuai keinginan.
