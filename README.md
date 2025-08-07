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
- _Versi saat ini 3.6.26_
- _Saat diminta untuk memilih opsi, cukup pilih **n** (tidak) jika ragu._

**4. Upgrade CMS**
```bash
cd /opt/cms && sudo ./cms_install.sh upgrade --version <cms_version>
```
- _Sebelum mengupgrade CMS, harap konfirmasikan versi CMS yang Anda perlukan dan ganti **"<cms_version>"**_
- _Upgred CMS hanya bisa di direktori atau folder tempat CMS di install._
  
**5. Reset root password**
```bash
cd /opt/cms \
&& sudo docker exec -it cms-mysql sh -c 'mysql -uroot -p"${MYSQL_ROOT_PASSWORD}" ccssx_boot -e "source /reset_pwd/reset_pwd.sql"'
```
- _Setelah mereset root password, Anda perlu me-restart CMS._

**6. Reset CMS Host**
```bash
cd /opt/cms \
&& sudo docker exec -it cms-mysql sh -c 'mysql -uroot -p"${MYSQL_ROOT_PASSWORD}" ccssx_boot -e "update sys_tenant set ip = \"<host>\" "'
```
- _Sebelum Reset CMS Host, harap konfirmasikan CMS Host yang Anda perlukan dan ganti **"<host>"** berikut ini._
- _Setelah mereset Host CMS, Anda perlu me-restart CMS._

**7. Restart CMS**
```bash
cd /opt/cms \
&& sudo docker compose down \
&& sudo docker compose up -d

```
**8. Uninstall CMS**
```bash
cd /opt/cms \
&& sudo docker compose down \
&& sudo rm -rf /opt/cms

```

### ⚠️ Catatan
- Login awal mungkin agak sulit — **coba beberapa kali hingga berhasil.**
- Silahkan sesuaikan tempat folder **/opt/cms** sesuai keinginan.
