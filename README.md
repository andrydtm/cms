# 🚀 Instalasi CMS C-Data (Wajib Ubuntu 24.04)

## Persyaratan Minimum
- **CPU**: 2 Core
- **Memori**: 8 GB
- **Free Hard Disk Space**: 64 GB

---

## 1. Buat Folder CMS
```bash
sudo mkdir -p /opt/cms \
&& sudo chown -R $USER:$USER /opt/cms \
&& sudo chmod -R 755 /opt/cms \
&& cd /opt/cms
```

---

## 2. Install Docker
```bash
wget https://raw.githubusercontent.com/andrydtm/cms/refs/heads/main/install_docker.sh \
&& sudo chmod +x install_docker.sh \
&& sudo ./install_docker.sh
```

---

## 3. Download & Install CMS
```bash
sudo curl -o cms_install.sh https://cms.s.cdatayun.com/cms_linux/cms_install.sh \
&& sudo chmod +x ./cms_install.sh \
&& sudo ./cms_install.sh install --version <cms_version>
```
> **Versi saat ini:** `3.6.26`  
> Saat diminta untuk memilih opsi, jika ragu **pilih `n` (tidak)**.

---

## 4. Upgrade CMS
```bash
cd /opt/cms \
&& sudo ./cms_install.sh upgrade --version <cms_version>
```
> Pastikan mengganti **`<cms_version>`** dengan versi CMS yang ingin digunakan.  
> Upgrade CMS **hanya bisa dilakukan di folder instalasi CMS**.

---

## 5. Reset Root Password
```bash
cd /opt/cms \
&& sudo docker exec -it cms-mysql sh -c 'mysql -uroot -p"${MYSQL_ROOT_PASSWORD}" ccssx_boot -e "source /reset_pwd/reset_pwd.sql"'
```
> Setelah mereset root password, **restart CMS**.

---

## 6. Reset CMS Host
```bash
cd /opt/cms \
&& sudo docker exec -it cms-mysql sh -c 'mysql -uroot -p"${MYSQL_ROOT_PASSWORD}" ccssx_boot -e "update sys_tenant set ip = \"<host>\" "'
```
> Ganti **`<host>`** dengan host yang diinginkan.  
> Setelah mereset host, **restart CMS**.

---

## 7. Restart CMS
```bash
cd /opt/cms \
&& sudo docker compose down \
&& sudo docker compose up -d
```

---

## 8. Uninstall CMS
```bash
cd /opt/cms \
&& sudo docker compose down \
&& sudo rm -rf /opt/cms/*
```

---

## ⚠️ Catatan
- Login awal mungkin agak sulit — **coba beberapa kali hingga berhasil**.  
- Folder instalasi default adalah **`/opt/cms`**, tetapi dapat disesuaikan sesuai kebutuhan.
